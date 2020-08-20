import 'dart:async';

import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc.dart';
import 'package:x_qrcode/constants.dart';

enum HOMES { EVENTS, ORGANIZATIONS, LOGIN }

class HomeBloc implements Bloc {
  final ApiService apiService;
  final FlutterSecureStorage storage;
  final Auth0 auth0;

  final _homeController = StreamController<HOMES>();

  HomeBloc(this.apiService, this.storage, this.auth0);

  Stream<HOMES> get home => _homeController.stream;

  void getAppropriateHome() async {
    var token = await _getOrRefreshAuthToken();
    if (token != null) {
      final user = await storage.read(key: STORAGE_KEY_USER);
      if (user != null) {
        _homeController.sink.add(HOMES.EVENTS);
      } else {
        _homeController.sink.add(HOMES.ORGANIZATIONS);
      }
    } else {
      _homeController.sink.add(HOMES.LOGIN);
    }
  }

  @override
  void dispose() {
    _homeController.close();
  }

  _getOrRefreshAuthToken() async {
    var expiresIn = await storage.read(key: STORAGE_KEY_TOKEN_EXPIRES_IN);
    if (expiresIn != null &&
        DateTime.parse(expiresIn).isBefore(DateTime.now())) {
      var refreshToken = await storage.read(key: STORAGE_KEY_REFRESH_TOKEN);
      try {
        var response =
            await auth0.auth.refreshToken({'refreshToken': refreshToken});
        await storage.write(
            key: STORAGE_KEY_ACCESS_TOKEN, value: response['access_token']);
        await storage.write(
            key: STORAGE_KEY_TOKEN_EXPIRES_IN,
            value: DateTime.fromMillisecondsSinceEpoch(response['expires_in'] +
                    DateTime.now().millisecondsSinceEpoch)
                .toIso8601String());
      } catch (ignored) {
        await storage.deleteAll();
      }
    }
    return await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
  }
}
