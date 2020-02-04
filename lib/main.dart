import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xqr_code/screen/login_screen.dart';
import 'package:xqr_code/screen/organization_screen.dart';
import 'routes.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(XQRCodeApp());
}

class XQRCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XQRCode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.login,
      routes: <String, WidgetBuilder>{
        Routes.login: (context) => LoginScreen(),
        Routes.organization: (context) => OrganizationScreen(),
      },
    );
  }
}
