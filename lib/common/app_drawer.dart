import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/auth/login_screen.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/organization/user.dart';

import '../constants.dart';

class _AppDrawerData {
  final User user;
  final Event event;

  _AppDrawerData(this.user, this.event);
}

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final storage = FlutterSecureStorage();

  Future<_AppDrawerData> data;

  @override
  void initState() {
    data = _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Drawer(
    child: FutureBuilder<_AppDrawerData>(
      future: data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 75,
                          margin: EdgeInsets.only(bottom: 8),
                          child: Image.network(snapshot.data.event.image),
                        ),
                        Text(
                          "${snapshot.data.user.firstName} ${snapshot.data.user
                              .lastName}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          snapshot.data.user.company.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          snapshot.data.event.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.black),
                    title: Text('Se déconnecter'),
                    onTap: _logout,
                  )
                ],
              );
            }
            return Container();
          },
        ),
      );

  Future<_AppDrawerData> _getData() async =>
      _AppDrawerData(
          User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER))),
          Event.fromJson(
              jsonDecode(await storage.read(key: STORAGE_KEY_EVENT))));

  _logout() async {
    await storage.deleteAll();
    Navigator.pushNamed(context, loginRoute);
  }
}
