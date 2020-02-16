import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/auth/login_screen.dart';
import 'package:x_qrcode/organization/user.dart';

import '../constants.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final storage = FlutterSecureStorage();

  Future<User> user;

  @override
  void initState() {
    user = _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: FutureBuilder<User>(
          future: user,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${snapshot.data.firstName} ${snapshot.data.lastName}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          snapshot.data.tenant,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          snapshot.data.company.name,
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

  Future<User> _getUser() async =>
      User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));

  _logout() async {
    await storage.deleteAll();
    Navigator.pushNamed(context, loginRoute);
  }
}
