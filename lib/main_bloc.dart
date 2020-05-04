import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:x_qrcode/bloc/bloc.dart';

class MainBloc implements Bloc {
  FirebaseAnalytics _firebaseAnalytics;

  MainBloc(this._firebaseAnalytics);

  @override
  void dispose() {}

  setUserId(String username) async => _firebaseAnalytics.setUserId(username);

  setCurrentScreen(String name) async =>
      _firebaseAnalytics.setCurrentScreen(screenName: name);

  logLogin() async => _firebaseAnalytics.logLogin();

  logEvent(name) async => _firebaseAnalytics.logEvent(name: name);

  setUserProperty(String name, String value) async =>
      _firebaseAnalytics.setUserProperty(
        name: name,
        value: value,
      );
}
