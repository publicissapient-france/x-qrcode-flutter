import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/attendees/attendees_screen.dart';
import 'package:x_qrcode/common/app_drawer.dart';
import 'package:x_qrcode/common/constants.dart';
import 'package:x_qrcode/organization/model/user_model.dart';
import 'package:x_qrcode/visitors/visitors_screen.dart';

import '../constants.dart';

const eventsRoute = '/events';

class EventsScreen extends StatefulWidget {
  EventsScreen({Key key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final storage = FlutterSecureStorage();

  Future<List<Event>> events;

  @override
  void initState() {
    super.initState();
    events = _getEventsByTenant();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color(BACKGROUND_COLOR),
        appBar: AppBar(
          title: Text('Evenements'.toUpperCase()),
        ),
        drawer: AppDrawer(),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: FutureBuilder<List<Event>>(
                future: events,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          Event event = snapshot.data[index];
                          return GestureDetector(
                              onTap: () async {
                                await storage.write(
                                    key: STORAGE_KEY_EVENT,
                                    value: jsonEncode(event));
                                String mode =
                                    await storage.read(key: STORAGE_KEY_MODE);
                                if (mode == MODE_CHECK_IN) {
                                  Navigator.pushNamed(context, attendeeRoute);
                                } else {
                                  Navigator.pushNamed(context, visitorsRoute);
                                }
                              },
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                child: Column(
                                  children: <Widget>[
                                    Image.network(
                                      event.image,
                                      height: 120,
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: 0,
                                          left: 16,
                                          right: 16,
                                          bottom: 16,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              event.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(event.tagline),
                                          ],
                                        ))
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
      );

  Future<List<Event>> _getEventsByTenant() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    if (response.statusCode == 200) {
      final _rawEvents = jsonDecode(response.body);
      final _events = List<Event>();
      for (var rawEvent in _rawEvents) {
        _events.add(Event.fromNetwork(rawEvent));
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

  Event.fromNetwork(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        tagline = json['metadata']['header']['tagline'],
        image = json['metadata']['header']['logo'];

  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        tagline = json['tagline'],
        image = json['image'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'tagline': tagline, 'image': image};
}
