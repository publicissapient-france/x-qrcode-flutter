import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/organization/user.dart';
import 'package:x_qrcode/visitors/attendee.dart';

import '../constants.dart';

class VisitorsScreen extends StatefulWidget {
  VisitorsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VisitorsScreeState();
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
      drawer: Drawer(),
      appBar: AppBar(
        title: Text('Visiteurs'),
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
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
        onPressed: () {
          //_addVisitor(Visitor('18436310', 'Michel', 'Parpaillon', ''),
          //    'data:image/png;base64,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');
        },
        child: Icon(Icons.camera_alt),
      ));

  Future<List<Attendee>> _getVisitors() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event = await storage.read(key: STORAGE_KEY_EVENT);

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/$event/visitors',
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
