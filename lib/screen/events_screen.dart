import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class EventsScreen extends StatefulWidget {
  EventsScreen({Key key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  Future<List<Event>> events;

  @override
  void initState() {
    super.initState();
    events = _getEventsByTenant();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color.fromARGB(255, 45, 56, 75),
        body: Padding(
            padding: EdgeInsets.all(48),
            child: FutureBuilder<List<Event>>(
                future: events,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 64, bottom: 16),
                          child: Text(
                            '👌 Veuillez sélectionner l’événement.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ListBody(
                            children: snapshot.data
                                .map((event) => Card(
                                    elevation: 2,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Column(
                                      children: <Widget>[
                                        Image.network(event.image),
                                        Container(
                                            margin: EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                Text(
                                                  event.name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(event.tagline),
                                              ],
                                            ))
                                      ],
                                    )))
                                .toList()),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
      );

  Future<List<Event>> _getEventsByTenant() async {
    final storage = FlutterSecureStorage();
    final tenant = await storage.read(key: STORAGE_KEY_TENANT);
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/$tenant/events',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    if (response.statusCode == 200) {
      final _rawEvents = jsonDecode(response.body);
      final _events = List<Event>();
      for (var rawEvent in _rawEvents) {
        _events.add(Event.fromJson(rawEvent));
      }
      return _events;
    } else {
      throw Exception('Failed to load events');
    }
  }
}

class Event {
  final String id;
  final String name;
  final String tagline;
  final String image;

  Event(this.id, this.name, this.tagline, this.image);

  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        tagline = json['metadata']['header']['tagline'],
        image = json['metadata']['header']['logo'];
}
