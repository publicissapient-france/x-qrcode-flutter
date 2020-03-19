import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/common/circle_gravatar.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/organization/user.dart';
import 'package:x_qrcode/visitors/visitor_screen.dart';
import 'package:x_qrcode/visitors/attendee.dart';

import '../constants.dart';
import 'consent_screen.dart';

const visitorsRoute = '/visitors';

class VisitorsScreen extends StatefulWidget {
  VisitorsScreen({Key key}) : super(key: key);

  @override
  _VisitorsScreeState createState() => _VisitorsScreeState();
}

class _VisitorsScreeState extends State<VisitorsScreen> {
  final storage = FlutterSecureStorage();

  Future<List<Attendee>> visitors;
  String barcode;

  @override
  void initState() {
    super.initState();
    visitors = _getVisitors();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color(BACKGROUND_COLOR),
      appBar: AppBar(
        title: Text('Visiteurs'.toUpperCase()),
      ),
      body: Padding(
          padding: EdgeInsets.all(8),
          child: FutureBuilder<List<Attendee>>(
              future: visitors,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        Attendee visitor = snapshot.data[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, visitorRoute,
                                  arguments:
                                      VisitorScreenArguments(visitor.id));
                            },
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              child: Container(
                                child: ListTile(
                                  leading: CircleGravatar(
                                    uid: visitor.email,
                                    placeholder:
                                        '${visitor.firstName.substring(0, 1)}${visitor.lastName.substring(0, 1)}',
                                  ),
                                  title: Text(
                                      "${visitor.firstName} ${visitor.lastName}"),
                                ),
                              ),
                            ));
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })),
      floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
                elevation: 0,
                backgroundColor: Color(PRIMARY_COLOR),
                onPressed: () => _scanQrCode(ctx),
                child: Icon(Icons.crop_free),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white, width: 4),
                    borderRadius: BorderRadius.circular(45)),
              )));

  void _scanQrCode(ctx) async {
    try {
      String barcode = await BarcodeScanner.scan();
      Map<String, dynamic> attendee = jsonDecode(barcode);
      var visitorId = attendee['attendee_id'];
      final visitorConsent = await Navigator.pushNamed(context, consentRoute,
          arguments: ConsentScreenArguments(visitorId));
      if (visitorConsent == true) {
        this.visitors = _getVisitors();
        Navigator.pushNamed(context, visitorsRoute,
            arguments: VisitorScreenArguments(visitorId));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _onScanError(ctx, 'Vous devez accepter la permission 📸');
      } else {
        _onScanError(ctx, 'Une erreur s‘est produite 😭');
      }
    } on FormatException {
      // do nothing on back press.
    } catch (e) {
      _onScanError(ctx, 'Une erreur s‘est produite 😭');
    }
  }

  void _onScanError(ctx, message) {
    Scaffold.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red[900], content: Text(message)));
  }

  Future<List<Attendee>> _getVisitors() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/visitors',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

    if (response.statusCode == 200) {
      final _rawVisitors = jsonDecode(response.body);
      final _events = List<Attendee>();
      for (var rawEvent in _rawVisitors) {
        _events.add(Attendee.fromJson(rawEvent));
      }
      _events.sort((a, b) => a.firstName.compareTo(b.firstName));
      return _events;
    } else {
      throw Exception('Failed to load visitors');
    }
  }
}
