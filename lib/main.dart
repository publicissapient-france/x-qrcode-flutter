import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:x_qrcode/screen/events_screen.dart';
import 'package:x_qrcode/screen/visitors_screen.dart';
import 'routes.dart';
import 'screen/login_screen.dart';
import 'screen/organization_screen.dart';

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
      initialRoute: Routes.login,
      routes: <String, WidgetBuilder>{
        Routes.login: (context) => LoginScreen(),
        Routes.organizations: (context) => OrganizationsScreen(),
        Routes.events: (context) => EventsScreen(),
        Routes.visitors: (context) => VisitorsScreen(),
      },
    );
  }
}
