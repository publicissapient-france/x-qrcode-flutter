import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/common/app_drawer.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/organization/user.dart';
import 'package:x_qrcode/visitors/attendee.dart';
import 'package:x_qrcode/visitors/consent_screen.dart';

import '../constants.dart';

const visitorRoute = '/visitors';

class VisitorsScreen extends StatefulWidget {
  VisitorsScreen({Key key}) : super(key: key);

  @override
  _VisitorsScreeState createState() => _VisitorsScreeState();
}

class _VisitorsScreeState extends State<VisitorsScreen> {
  final storage = FlutterSecureStorage();

  Future<List<Attendee>> visitors;

  @override
  void initState() {
    super.initState();
    visitors = _getVisitors();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Visiteurs'),
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
                        return Card(
                          elevation: 2,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: ListTile(
                              title: Text(
                                  "${snapshot.data[index].firstName} ${snapshot.data[index].lastName}"),
                            ),
                          ),
                        );
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final visitorConsent = await Navigator.pushNamed(
              context, consentRoute,
              arguments: ConsentScreenArguments('22073757'));
          if (visitorConsent == true) {
            this.visitors = _getVisitors();
          }
        },
        child: Icon(Icons.camera_alt),
      ));

  Future<List<Attendee>> _getVisitors() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
    Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event
            .id}/visitors',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

    if (response.statusCode == 200) {
      final _rawVisitors = jsonDecode(response.body);
      final _events = List<Attendee>();
      for (var rawEvent in _rawVisitors) {
        _events.add(Attendee.fromJson(rawEvent));
      }
      return _events;
    } else {
      throw Exception('Failed to load visitors');
    }
  }
}
