import 'package:flutter/material.dart';
import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/auth/login_screen.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/home/home_bloc.dart';
import 'package:x_qrcode/organization/organization_screen.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeBloc bloc = HomeBloc(
      ApiService(),
      FlutterSecureStorage(),
      Auth0(
        baseUrl: DotEnv().env[ENV_KEY_OAUTH_AUTH_URL],
        clientId: DotEnv().env[ENV_KEY_OAUTH_CLIENT_ID],
      ));

  @override
  void initState() {
    bloc.getAppropriateHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<HOMES>(
        stream: bloc.home,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case HOMES.EVENTS:
                return EventsScreen();
              case HOMES.ORGANIZATIONS:
                return OrganizationsScreen();
              case HOMES.LOGIN:
                return LoginScreen();
            }
          }
          return Container();
        },
      );
}
