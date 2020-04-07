import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/common/circle_gravatar_widget.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/organization/model/user_model.dart';
import 'package:x_qrcode/visitor/widget/scan_floating_action_widget.dart';
import 'package:x_qrcode/visitor/visitor_screen.dart';
import 'package:x_qrcode/visitor/widget/search_input_widget.dart';

import '../constants.dart';
import 'consent_screen.dart';
import 'model/attendee_model.dart';

const visitorsRoute = '/visitors';

class VisitorsScreen extends StatefulWidget {
  VisitorsScreen({Key key}) : super(key: key);

  @override
  _VisitorsScreeState createState() => _VisitorsScreeState();
}

class _VisitorsScreeState extends State<VisitorsScreen> {
  final storage = FlutterSecureStorage();
  final searchTextEditingController = TextEditingController();

  List<Attendee> visitors;

  List<Attendee> filteredVisitors;

  String barcode;

  @override
  void initState() {
    super.initState();
    searchTextEditingController.addListener(_searchVisitors);
    _loadVisitors();
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (filteredVisitors != null) {
      body = Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(12),
              child: ClipRRect(
                child: SearchInput(
                  searchTextEditingController: searchTextEditingController,
                ),
                borderRadius: BorderRadius.circular(4),
              )),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: filteredVisitors.length,
                  itemBuilder: (context, index) {
                    Attendee visitor = filteredVisitors[index];
                    return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, visitorRoute,
                              arguments: VisitorScreenArguments(visitor.id));
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
                  }))
        ],
      );
    } else {
      body = Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        backgroundColor: Color(BACKGROUND_COLOR),
        appBar: AppBar(
          title: Text('Visiteurs'.toUpperCase()),
        ),
        body: body,
        floatingActionButton: ScanFloatingActionButton(
          onPressed: _scanQrCode,
        ));
  }

  void _scanQrCode(ctx) async {
    try {
      String barcode = await BarcodeScanner.scan();
      Map<String, dynamic> attendee = jsonDecode(barcode);
      var visitorId = attendee['attendee_id'];
      final visitorConsent = await Navigator.pushNamed(context, consentRoute,
          arguments: ConsentScreenArguments(visitorId));
      if (visitorConsent == true) {
        _loadVisitors();
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

  void _loadVisitors() async {
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
      final _visitors = List<Attendee>();
      for (var rawEvent in _rawVisitors) {
        _visitors.add(Attendee.fromJson(rawEvent));
      }
      _visitors.sort((a, b) => a.firstName.compareTo(b.firstName));
      setState(() {
        visitors = _visitors;
        filteredVisitors = _visitors;
      });
    } else {
      throw Exception('Failed to load visitors');
    }
  }

  void _searchVisitors() {
    final query = searchTextEditingController.text.toLowerCase();
    setState(() {
      filteredVisitors = visitors
          .where((v) => v.firstName.toLowerCase().contains(query))
          .toList();
    });
  }
}
