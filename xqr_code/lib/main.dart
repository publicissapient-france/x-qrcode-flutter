import 'package:flutter/material.dart';
import 'package:xqr_code/screens/login/login_screen.dart';
import 'package:xqr_code/screens/organization_screen.dart';
import 'routes.dart';

void main() => runApp(XQRCodeApp());

class XQRCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XQRCode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.login,
      routes:  <String, WidgetBuilder>{
        Routes.login: (context) => LoginScreen(),
        Routes.organization: (context) => OrganizationScreen(),
      },
    );
  }
}