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
import 'package:x_qrcode/common/circle_gravatar_widget.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/organization/model/user_model.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';
import 'package:x_qrcode/visitor/widget/scan_floating_action_widget.dart';
import 'package:x_qrcode/visitor/widget/search_input_widget.dart';

import '../constants.dart';

const attendeeRoute = '/attendees';

class AttendeesScreen extends StatefulWidget {
  AttendeesScreen({Key key}) : super(key: key);

  @override
  _AttendeesScreeState createState() => _AttendeesScreeState();
}

class _AttendeesScreeState extends State<AttendeesScreen> {
  final storage = FlutterSecureStorage();
  final searchTextEditingController = TextEditingController();

  List<Attendee> attendees;

  List<Attendee> filteredAttendees;

  String barcode;

  @override
  void initState() {
    super.initState();
    searchTextEditingController.addListener(_searchAttendees);
    _loadAttendees();
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (filteredAttendees != null) {
      final attendeesChecked = attendees.where((a) => a.checkIn).length;
      body = Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                SearchInput(
                  searchTextEditingController: searchTextEditingController,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFD3D3D3),
                    value: attendeesChecked / attendees.length,
                  ),
                ),
                Container(
                  height: 8,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        attendeesChecked.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(PRIMARY_COLOR),
                            fontSize: 16),
                      ),
                    ),
                    Text(
                      attendees.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E8E8E),
                          fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: filteredAttendees.length,
                itemBuilder: (context, index) {
                  Attendee attendee = filteredAttendees[index];
                  return GestureDetector(
                      onTap: () async {
                        try {
                          bool check = await _toggleCheck(
                              attendee.id, !attendee.checkIn);
                          setState(() {
                            filteredAttendees[index] = Attendee(
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
                }),
          )
        ],
      );
    } else {
      body = Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        backgroundColor: Color(BACKGROUND_COLOR),
        appBar: AppBar(
          title: Text('Check-in'.toUpperCase()),
        ),
        body: body,
        floatingActionButton: ScanFloatingActionButton(
          onPressed: _scanQrCode,
        ));
  }

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
        _loadAttendees();
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

  void _loadAttendees() async {
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
      final _attendees = List<Attendee>();
      for (var rawEvent in _rawAttendees) {
        _attendees.add(Attendee.fromJson(rawEvent));
      }
      _attendees.sort((a, b) => a.firstName.compareTo(b.firstName));
      setState(() {
        attendees = _attendees;
        filteredAttendees = _attendees;
      });
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

  void _searchAttendees() {
    final query = searchTextEditingController.text.toLowerCase();
    setState(() {
      filteredAttendees = attendees
          .where((a) => a.firstName.toLowerCase().contains(query))
          .toList();
    });
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
