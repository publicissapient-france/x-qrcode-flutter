import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:x_qrcode/attendee/attendee_screen.dart';
import 'package:x_qrcode/constants.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/home/home_screen.dart';
import 'package:x_qrcode/visitor/visitor_screen.dart';
import 'package:x_qrcode/visitor/consent_screen.dart';
import 'package:x_qrcode/visitors/visitors_screen.dart';

import 'attendees/attendees_screen.dart';
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
          scaffoldBackgroundColor: Color(BACKGROUND_COLOR),
          primaryColor: Color(PRIMARY_COLOR),
          cursorColor: Color(PRIMARY_COLOR),
          accentColor: Color(PRIMARY_COLOR),
          textTheme: TextTheme(subhead: TextStyle(fontSize: 14)),
          fontFamily: 'FuturaNext'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case loginRoute:
          case organisationsRoute:
          case eventsRoute:
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case visitorsRoute:
            return MaterialPageRoute(builder: (_) => VisitorsScreen());
          case attendeesRoute:
            return MaterialPageRoute(builder: (_) => AttendeesScreen());
          case attendeeRoute:
            return MaterialPageRoute(builder: (_) {
              final AttendeeScreenArguments args = settings.arguments;
              return AttendeeScreen(attendee: args.attendee);
            });
          case consentRoute:
            return MaterialPageRoute(builder: (_) {
              final ConsentScreenArguments args = settings.arguments;
              return ConsentScreen(visitorId: args.visitorId);
            });
          case visitorRoute:
            return MaterialPageRoute(builder: (_) {
              final VisitorScreenArguments args = settings.arguments;
              return VisitorScreen(visitorId: args.visitorId);
            });
          default:
            return MaterialPageRoute(builder: (_) => Container());
        }
      },
    );
  }
}
