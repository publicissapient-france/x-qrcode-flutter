import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xqr_code/constants.dart';
import 'package:xqr_code/screens/login/login_screen.dart';
import 'package:xqr_code/screens/organization_screen.dart';
import 'routes.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(Constants(child: XQRCodeApp()));
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
