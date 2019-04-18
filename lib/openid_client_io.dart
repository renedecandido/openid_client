library openid_client.io;

import 'openid_client.dart';
import 'dart:async';
import 'dart:io';

export 'openid_client.dart';

class Authenticator {
  final Flow flow;

  final Function(String url) urlLancher;

  final int port;

  Authenticator(Client client,
      {this.urlLancher: _runBrowser,
      Iterable<String> scopes: const [],
      Uri redirectUri})
      : flow = redirectUri == null
            ? new Flow.authorizationCodeWithPKCE(client)
            : new Flow.authorizationCode(client)
          ..scopes.addAll(scopes)
          ..redirectUri = redirectUri;

  Future<Credential> authorize() async {
    var state = flow.authenticationUri.queryParameters["state"];

    _requestsByState[state] = new Completer();

    var response = await urlLancher(flow.authenticationUri.toString());

    return flow.callback(response);
  }

  static Map<int, Future<HttpServer>> _requestServers = {};
  static Map<String, Completer<Map<String, String>>> _requestsByState = {};

}
