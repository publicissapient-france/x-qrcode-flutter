import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/auth/login_screen.dart';
import 'package:x_qrcode/organization/organization_screen.dart';
import 'package:x_qrcode/screen/events_screen.dart';
import 'package:x_qrcode/visitors/visitors_screen.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Widget> home;

  @override
  void initState() {
    home = _getAppropriateHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
        future: home,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          }
          return Container();
        },
      );

  Future<Widget> _getAppropriateHome() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final token = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    if (token != null) {
      final user = await storage.read(key: STORAGE_KEY_USER);
      if (user != null) {
        final event = await storage.read(key: STORAGE_KEY_EVENT);
        if (event != null) {
          return VisitorsScreen();
        }
        return EventsScreen();
      }
      return OrganizationsScreen();
    }
    return LoginScreen();
  }
}
