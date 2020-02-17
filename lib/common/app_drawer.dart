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
                  UserAccountsDrawerHeader(
                      accountName: Text(
                          "${snapshot.data.user.firstName} ${snapshot.data.user
                              .lastName} - ${snapshot.data.user.company.name}"),
                      accountEmail: Text(snapshot.data.event.name),
                      currentAccountPicture: CircleAvatar(
                        child: Text(
                          snapshot.data.user.firstName.substring(0, 1),
                          style: TextStyle(fontSize: 40),
                        ),
                      )),
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
