import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:x_qrcode/attendee/attendee_screen.dart';
import 'package:x_qrcode/attendees/scan_error_screen.dart';
import 'package:x_qrcode/bloc/bloc_provider.dart';
import 'package:x_qrcode/constants.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/home/home_screen.dart';
import 'package:x_qrcode/main_bloc.dart';
import 'package:x_qrcode/visitor/visitor_screen.dart';
import 'package:x_qrcode/visitor/consent_screen.dart';
import 'package:x_qrcode/visitors/visitors_screen.dart';

import 'attendees/attendees_screen.dart';
import 'auth/login_screen.dart';
import 'organization/organization_screen.dart';

void main() async {
  await DotEnv().load('.env');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(XQRCodeApp(FirebaseAnalytics()));
}

class XQRCodeApp extends StatelessWidget {
  final FirebaseAnalytics _analytics;
  final MainBloc _bloc;

  XQRCodeApp(this._analytics) : _bloc = MainBloc(_analytics);

  @override
  Widget build(BuildContext context) => BlocProvider<MainBloc>(
        bloc: MainBloc(_analytics),
        child: MaterialApp(
          title: 'X-QRCode',
          theme: ThemeData(
            scaffoldBackgroundColor: Color(BACKGROUND_COLOR),
            primaryColor: Color(PRIMARY_COLOR),
            cursorColor: Color(PRIMARY_COLOR),
            accentColor: Color(PRIMARY_COLOR),
            textTheme: TextTheme(
              subtitle2: TextStyle(fontSize: 16),
              bodyText2: TextStyle(fontSize: 16, height: 1.5),
              button: TextStyle(fontSize: 16),
            ),
            fontFamily: 'FuturaNext',
          ),
          onGenerateRoute: (settings) {
            _bloc.setCurrentScreen(settings.name);
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
              case scanErrorRoute:
                return MaterialPageRoute(builder: (_) => ScanErrorScreen());
              default:
                return MaterialPageRoute(builder: (_) => Container());
            }
          },
        ),
      );
}
