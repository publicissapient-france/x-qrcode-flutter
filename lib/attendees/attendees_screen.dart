import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/common/circle_gravatar.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/organization/user.dart';
import 'package:x_qrcode/visitors/attendee.dart';

import '../constants.dart';

const attendeeRoute = '/attendees';

class AttendeesScreen extends StatefulWidget {
  AttendeesScreen({Key key}) : super(key: key);

  @override
  _AttendeesScreeState createState() => _AttendeesScreeState();
}

class _AttendeesScreeState extends State<AttendeesScreen> {
  final storage = FlutterSecureStorage();

  Future<List<Attendee>> attendees;
  String barcode;

  @override
  void initState() {
    super.initState();
    attendees = _getAttendees();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color(BACKGROUND_COLOR),
      appBar: AppBar(
        title: Text('Check-in'.toUpperCase()),
      ),
      body: FutureBuilder<List<Attendee>>(
          future: attendees,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Attendee attendee = snapshot.data[index];
                    return GestureDetector(
                        onTap: () async {
                          try {
                            bool check = await _toggleCheck(
                                attendee.id, !attendee.checkIn);
                            setState(() {
                              snapshot.data[index] = Attendee(
                                  attendee.id,
                                  attendee.firstName,
                                  attendee.lastName,
                                  attendee.email,
                                  check,
                                  attendee.comments);
                            });
                          } catch (ignored) {}
                        },
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          child: Container(
                            child: ListTile(
                              title: Text(
                                  "${attendee.firstName} ${attendee.lastName}"),
                              leading: CircleGravatar(
                                uid: attendee.email,
                                placeholder:
                                    '${attendee.firstName.substring(0, 1)}${attendee.lastName.substring(0, 1)}',
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                size: 30,
                                color: attendee.checkIn
                                    ? Color(PRIMARY_COLOR)
                                    : Color(0xFFD3D3D3),
                              ),
                            ),
                          ),
                        ));
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
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
      _showLoading(ctx);
      await _toggleCheck(barcode, true);
      Navigator.pop(ctx);
      _showSuccess(ctx);
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(ctx);
      _scanQrCode(ctx);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _onScanError(ctx, 'Vous devez accepter la permission 📸');
      } else {
        _onScanError(ctx, 'Une erreur s‘est produite 😭');
      }
    } on FormatException {
      setState(() {
        attendees = _getAttendees();
      });
    } on CheckInException {
      Navigator.pop(ctx);
      _showError(ctx);
      await Future.delayed(Duration(milliseconds: 750));
      Navigator.pop(ctx);
      _scanQrCode(ctx);
    } catch (e) {
      _onScanError(ctx, 'Une erreur s‘est produite 😭');
    }
  }

  void _showSuccess(ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(32),
              color: Colors.green,
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 152,
              ),
            ),
          );
        });
  }

  void _showError(ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(32),
              color: Colors.red,
              child: Icon(
                Icons.not_interested,
                color: Colors.white,
                size: 152,
              ),
            ),
          );
        });
  }

  void _showLoading(ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  )));
        });
  }

  void _onScanError(ctx, message) {
    Scaffold.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red[900], content: Text(message)));
  }

  Future<List<Attendee>> _getAttendees() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/attendees',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

    if (response.statusCode == 200) {
      final _rawAttendees = jsonDecode(response.body);
      final _events = List<Attendee>();
      for (var rawEvent in _rawAttendees) {
        _events.add(Attendee.fromJson(rawEvent));
      }
      _events.sort((a, b) => a.firstName.compareTo(b.firstName));
      return _events;
    } else {
      throw Exception('Failed to load attendees');
    }
  }

  Future<bool> _toggleCheck(String id, bool check) async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.patch(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/attendees/$id',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
        body: {'checked': '$check'});

    if (response.statusCode == 200) {
      return check;
    } else {
      throw CheckInException(
          'Cannot check-in attendee, status: ${response.statusCode}, message: ${response.body}');
    }
  }
}

class CheckInException implements Exception {
  final String message;

  CheckInException(this.message);

  @override
  String toString() {
    return message;
  }
}
