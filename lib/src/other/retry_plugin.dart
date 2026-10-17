import 'dart:async';
import 'dart:io';

import 'package:discord/discord.dart';
import 'package:retry/retry.dart';

final class RetryPlugin extends NyxxPlugin<NyxxGateway> {
  @override
  Future<HttpResponse> interceptRequest(NyxxGateway client, HttpRequest request, Future<HttpResponse> Function(HttpRequest) next) async {
    return await retry(
      () async {
        final response = await super.interceptRequest(client, request, next);
        if (response is HttpResponseError && response.statusCode == 503) throw response;
        return response;
      },
      retryIf: (e) {
        return
          (e is HttpResponseError && e.statusCode == 503) ||
          e is SocketException ||
          e is TimeoutException
        ;
      },
      onRetry: (e) {
        client.logger.warning('Retrying request: $e');
      },
    );
  }
}
