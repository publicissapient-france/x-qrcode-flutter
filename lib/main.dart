import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:x_qrcode/visitors/consent_screen.dart';
import 'package:x_qrcode/screen/events_screen.dart';
import 'package:x_qrcode/visitors/visitors_screen.dart';
import 'auth/login_screen.dart';
import 'routes.dart';
import 'organization/organization_screen.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(XQRCodeApp());
}

class XQRCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-QRCode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        Routes.login: (context) => LoginScreen(),
        Routes.organizations: (context) => OrganizationsScreen(),
        Routes.events: (context) => EventsScreen(),
        Routes.visitors: (context) => VisitorsScreen(),
        Routes.consent: (context) => ConsentScreen(visitorId: '18436310'),
      },
    );
  }
}
