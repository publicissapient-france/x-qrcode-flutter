import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/auth/login_screen.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/organization/user.dart';

import '../constants.dart';
import 'common_models.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final storage = FlutterSecureStorage();
  final modes = List.generate(2, (_) => false);

  Future<User> fUser;
  Future<Event> fEvent;
  Future<String> fMode;

  @override
  void initState() {
    fUser = _getUser();
    fEvent = _getEvent();
    fMode = _getMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildUserAccountsDrawerHeader(),
                  _buildModeToggleButtons(),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(16),
              child: RaisedButton.icon(
                icon: Icon(Icons.exit_to_app),
                label: Text('Se déconnecter'),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      );

  _buildUserAccountsDrawerHeader() => FutureBuilder(
      future: fUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return UserAccountsDrawerHeader(
              accountName: Text(
                  "${snapshot.data.firstName} ${snapshot.data.lastName} - ${snapshot.data.company.name}"),
              accountEmail: _buildEventName(),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  snapshot.data.firstName.substring(0, 1),
                  style: TextStyle(fontSize: 40),
                ),
              ));
        }
        return Container();
      });

  _buildModeToggleButtons() => FutureBuilder(
        future: Future.wait([fUser, fMode]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data[0];
            if (user.roles.contains(ROLE_ADMIN)) {
              var mode = snapshot.data[1];
              if (mode == MODE_CHECK_IN) {
                modes[0] = true;
                modes[1] = false;
              } else {
                modes[0] = false;
                modes[1] = true;
              }
              return Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: ToggleButtons(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  isSelected: modes,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text('Check-in'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text('Sponsor'),
                    ),
                  ],
                  onPressed: (index) async {
                    await storage.write(
                        key: STORAGE_KEY_MODE, value: MODE[index]);
                    setState(() {
                      modes[index] = true;
                      modes[index + 1 % 1] = false;
                      mode = index == 0 ? MODE_CHECK_IN : MODE_SPONSOR;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              );
            }
          }
          return Container();
        },
      );

  FutureBuilder<Event> _buildEventName() {
    return FutureBuilder(
        future: fEvent,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data.name);
          }
          return Text('');
        });
  }

  _logout() async {
    await storage.deleteAll();
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
  }

  Future<User> _getUser() async =>
      User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));

  Future<Event> _getEvent() async {
    final event = await storage.read(key: STORAGE_KEY_EVENT);
    if (event != null) {
      return Event.fromJson(jsonDecode(event));
    }
    return null;
  }

  Future<String> _getMode() async => await storage.read(key: STORAGE_KEY_MODE);
}
