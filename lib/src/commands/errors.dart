import 'package:discord/discord.dart';

class UnknownUserFacingException implements Exception {
  final String userMessage;

  new(this.userMessage);

  @override
  String toString() {
    return "UnknownUserFacingException: $userMessage";
  }
}

class ExpectedUserFacingException implements Exception {
  final String userMessage;

  new(this.userMessage);

  @override
  String toString() {
    return "ExpectedUserFacingException: $userMessage";
  }
}

final class ResponseException extends UnknownUserFacingException {
  final Snowflake userId;
  final Snowflake interactionId;

  new(super.userMessage, {required this.userId, required this.interactionId});

  @override
  String toString() {
    return "ResponseException(userId=$userId, interactionId=$interactionId): $userMessage";
  }
}
