import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

final StreamController<PaginationData> paginationController = .broadcast();

final class PaginationData({
  required final Snowflake messageId,
  required final Snowflake userId,
  required final PaginationAction action,
  final int? jumpTo,
});

enum PaginationAction {
  jumpBack(0),
  back(1),
  forward(2),
  jumpForward(3),
  input(4),
  stop(5),
  ;

  final int code;
  const new(this.code);
}

Future<void> initializePagination(DiscordBot bot, NyxxGateway client) async {
  client.onMessageComponentInteraction.listen((event) async {
    final interaction = event.interaction;
    final data = interaction.data;
    final id = data.customId;
    final user = interaction.user ?? interaction.member?.user;

    if (user == null) return;
    if (isIgnored(bot.store, user.id)) return;
    if (!id.startsWith("pagination-")) return;

    final iterator = id.split("-").iterator;

    late Snowflake messageId;
    late PaginationAction action;

    if (!iterator.moveNext() || !iterator.moveNext()) {
      return Logger.warn("Pagination", "Invalid ID (0) '$id'");
    }

    try {
      messageId = .parse(iterator.current);
    } catch (e) {
      return Logger.warn("Pagination", "Invalid ID (messageId) '$id': $e");
    }

    if (!iterator.moveNext()) {
      return Logger.warn("Pagination", "Invalid ID (1) '$id'");
    }

    try {
      final value = int.parse(iterator.current);
      action = .values.firstWhere((x) => x.code == value);
    } catch (e) {
      return Logger.warn("Pagination", "Invalid ID (action) '$id': $e");
    }

    if (action == .input) {
      await interaction.respondModal(.new(
        customId: "pagination-input-$messageId",
        title: "Enter Page Number",
        components: [
          LabelComponentBuilder(
            label: "Page Number",
            component: TextInputBuilder(
              customId: "page",
              style: .short,
              minLength: 1,
              isRequired: true,
            ),
          ),
        ],
      ));

      return;
    }

    try {
      await interaction.acknowledge(updateMessage: true);
    } catch (e) {
      Logger.warn("Pagination", "Unable to acknowledge interaction ${interaction.id} '$id': $e");
    }

    paginationController.sink.add(.new(messageId: messageId, userId: user.id, action: action));
  });

  client.onModalSubmitInteraction.listen((event) async {
    final interaction = event.interaction;
    final data = interaction.data;
    final user = interaction.user ?? interaction.member?.user;
    final guild = interaction.guild;

    if (user == null || guild == null) return;
    if (isIgnored(bot.store, user.id)) return;
    if (!data.customId.startsWith("pagination-input-")) return;

    final input = data.customId.replaceFirst("pagination-input-", "");
    final messageId = tryCatch(() => Snowflake.parse(input));

    if (messageId == null) return;
    await interaction.acknowledge(isEphemeral: true);
    late final int page;

    for (final x in data.components) {
      final component = x is SubmittedLabelComponent ? x.component : x;
      if (component is! SubmittedTextInputComponent) continue;

      try {
        page = .parse(component.value!);
      } catch (e) {
        await interaction.respond(.new(
          content: "Invalid number.",
        ));

        return;
      }

      if (page <= 0) {
        await interaction.respond(.new(
          content: "Invalid number. Must be at least 1.",
        ));

        return;
      }
    }

    paginationController.sink.add(.new(messageId: messageId, userId: user.id, action: .input, jumpTo: page - 1));
    await interaction.deleteOriginalResponse();
  });
}

Future<void> startPagination({
  required NyxxGateway client,
  required DiscordBot bot,
  required PaginatedEmbedBuilder builder,
  required Snowflake userId,
  required Future<Message> Function(MessageBuilder builder) onCreate,
  required Future<void> Function(MessageUpdateBuilder) onEdit,
  int maxSeconds = 120,
}) async {
  try {
    if (builder.pages.length <= 1) {
      await onCreate(.new(
        embeds: [builder.build(0)],
      ));

      return;
    }

    int page = 0;
    int timeSinceLastInteraction = 0;

    final message = await onCreate(.new(content: "Loading..."));
    String buildId(PaginationAction action) => "pagination-${message.id}-${action.code}";

    TextEmoji emoji(String name) {
      return TextEmoji(id: Snowflake.zero, manager: client.guilds[Snowflake.zero].emojis, name: name);
    }

    List<ComponentBuilder> components() {
      ButtonBuilder blank(int i) {
        return .secondary(label: "\u3164", customId: "blank$i", isDisabled: true);
      }

      return [
        ActionRowBuilder(components: [
          ButtonBuilder.primary(emoji: emoji("\u23EA"), customId: buildId(.jumpBack), isDisabled: page == 0),
          ButtonBuilder.primary(emoji: emoji("\u25C0\uFE0F"), customId: buildId(.back), isDisabled: page == 0),
          ButtonBuilder.primary(emoji: emoji("\u25B6\uFE0F"), customId: buildId(.forward), isDisabled: page == builder.pages.length - 1),
          ButtonBuilder.primary(emoji: emoji("\u23E9"), customId: buildId(.jumpForward), isDisabled: page == builder.pages.length - 1),
        ]),
        ActionRowBuilder(components: [
          blank(0),
          ButtonBuilder.primary(emoji: emoji("\u{1F522}"), customId: buildId(.input)),
          ButtonBuilder.primary(emoji: emoji("\u23F9\uFE0F"), customId: buildId(.stop)),
          blank(1),
        ]),
      ];
    }

    Future<void> update() async {
      try {
        await onEdit(.new(
          content: null,
          embeds: [builder.build(page)],
          components: components(),
        ));
      } catch (e) {
        Logger.warn("Pagination", "Unable to update message ${message.id} (user=$userId, page=$page): $e");
      }
    }

    late final StreamSubscription<PaginationData> subscription;
    late final Timer timer;

    void cancel() async {
      subscription.cancel();
      timer.cancel();

      try {
        await onEdit(.new(
          content: null,
          embeds: [builder.build(page)],
          components: [],
        ));
      } catch (e) {
        Logger.warn("Pagination", "Unable to update message ${message.id} (user=$userId, page=$page): $e");
      }
    }

    Logger.print("Pagination", "Starting pagination for user $userId and message ${message.id} with ${builder.pages.length} pages...");
    await update();

    timer = .periodic(.new(seconds: 1), (_) {
      timeSinceLastInteraction++;

      if (timeSinceLastInteraction > maxSeconds) {
        cancel();
        return;
      }
    });

    subscription = paginationController.stream.listen((data) async {
      if (data.messageId != message.id) return;
      if (data.userId != userId) return;

      switch (data.action) {
        case .back:
          if (page > 0) page--;
          break;

        case .forward:
          if (page < builder.pages.length - 1) page++;
          break;

        case .jumpBack:
          page = 0;
          break;

        case .jumpForward:
          page = builder.pages.length - 1;
          break;

        case .input:
          page = data.jumpTo ?? page;
          break;

        case .stop:
          cancel();
          return;
      }

      update();
    });
  } catch (e) {
    Logger.warn("Pagination", "Error (user=$userId): $e");
  }
}

class PaginatedEmbedBuilder {
  String? title;
  String? description;
  Uri? url;
  DateTime? timestamp;
  DiscordColor? color;
  ElementBasedEmbedFooterBuilder? footer;
  EmbedImageBuilder? image;
  EmbedThumbnailBuilder? thumbnail;
  EmbedAuthorBuilder? author;
  List<EmbedPage> pages;

  new({
    this.title,
    this.description,
    this.url,
    this.timestamp,
    this.color,
    this.footer,
    this.image,
    this.thumbnail,
    this.author,
    required this.pages,
  });

  EmbedBuilder build(int page, {List<String> extraFooterElements = const []}) {
    return EmbedBuilder(
      title: title,
      description: description,
      url: url,
      timestamp: timestamp,
      color: color,
      footer: EmbedFooterBuilder(text: [...?footer?.elements, if (pages.length > 1) "Page ${page + 1}/${pages.length}", ...extraFooterElements].join(" - "), iconUrl: footer?.iconUrl),
      image: image,
      thumbnail: thumbnail,
      author: author,
      fields: pages.elementAtOrNull(page)?.fields,
    );
  }

  EmbedBuilder buildFull() {
    return EmbedBuilder(
      title: title,
      description: description,
      url: url,
      timestamp: timestamp,
      color: color,
      footer: EmbedFooterBuilder(text: [...?footer?.elements].join(" - "), iconUrl: footer?.iconUrl),
      image: image,
      thumbnail: thumbnail,
      author: author,
      fields: pages.map((x) => x.fields).flattenedToList,
    );
  }
}

final class EmbedPage({required final List<EmbedFieldBuilder> fields}) {
  static List<EmbedPage> fromFields(List<EmbedFieldBuilder> fields, {int maxLinesPerPage = 15}) {
    List<EmbedPage> pages = [];
    List<EmbedFieldBuilder> currentPage = [];
    int currentPageLength = 0;

    for (int i = 0; i < fields.length; i++) {
      final f = fields[i];
      currentPage.add(f);
      currentPageLength += f.value.split("\n").length + 1;

      if (currentPageLength >= maxLinesPerPage) {
        pages.add(EmbedPage(fields: List.of(currentPage)));
        currentPage = [];
        currentPageLength = 0;
      }
    }

    if (currentPage.isNotEmpty) pages.add(EmbedPage(fields: List.of(currentPage)));
    return pages;
  }

  static List<EmbedPage> fromItems(List<String> lines, {int maxLinesPerPage = 15, String separator = "\n"}) {
    final Map<int, List<String>> pages = {};
    List<String> currentPage = [];
    int currentPageLength = 0;

    for (int i = 0; i < lines.length; i++) {
      final v = lines[i];
      currentPage.add(v);
      currentPageLength++;

      if (currentPageLength >= maxLinesPerPage) {
        pages[pages.length] = .of(currentPage);
        currentPage = [];
        currentPageLength = 0;
      }
    }

    if (currentPage.isNotEmpty) {
      pages[pages.length] = .of(currentPage);
    }

    return pages.mapToList((k, v) => .new(fields: [
      .new(name: "Items ${maxLinesPerPage * k + 1} - ${(maxLinesPerPage * k) + v.length}", value: v.join(separator), isInline: false),
    ]));
  }

  static List<EmbedPage> fromText(String text, {int maxCharactersPerPage = 1024}) {
    if (text.isEmpty) return [];
    final Map<int, String> chunks = {};

    for (int i = 0; i < text.length; i += maxCharactersPerPage) {
      final end = (i + maxCharactersPerPage < text.length) ? i + maxCharactersPerPage : text.length;
      chunks[i] = (text.substring(i, end));
    }

    return chunks.mapToList((i, v) => .new(fields: [
      .new(name: "Characters ${i + 1} - ${i + v.length}", value: v, isInline: false),
    ]));
  }
}

final class ElementBasedEmbedFooterBuilder({final List<String>? elements, final Uri? iconUrl});
