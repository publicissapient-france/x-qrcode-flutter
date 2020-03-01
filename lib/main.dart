import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/home/home_screen.dart';
import 'package:x_qrcode/profile/profile_screen.dart';
import 'package:x_qrcode/visitors/consent_screen.dart';
import 'package:x_qrcode/visitors/visitors_screen.dart';

import 'auth/login_screen.dart';
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case loginRoute:
          case organisationsRoute:
          case eventsRoute:
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case visitorRoute:
            return MaterialPageRoute(builder: (_) => VisitorsScreen());
          case consentRoute:
            return MaterialPageRoute(builder: (_) {
              final ConsentScreenArguments args = settings.arguments;
              return ConsentScreen(visitorId: args.visitorId);
            });
          case profileRoute:
            return MaterialPageRoute(builder: (_) {
              final ProfileScreenArguments args = settings.arguments;
              return ProfileScreen(visitorId: args.visitorId);
            });
          default:
            return MaterialPageRoute(builder: (_) => Container());
        }
      },
    );
  }
}
