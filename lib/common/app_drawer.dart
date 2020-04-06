import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_qrcode/auth/login_screen.dart';
import 'package:x_qrcode/common/circle_gravatar.dart';
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
  Future<String> fMode;

  @override
  void initState() {
    fUser = _getUser();
    fMode = _getMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          children: <Widget>[
            _buildHeader(),
            ListTile(
              title: Center(child: _buildUserInfo()),
            ),
            _buildModeToggleButtons(),
          ],
        ),
      );

  _buildHeader() => FutureBuilder(
      future: fUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;
          return Container(
            height: 120,
            child: Stack(
              children: <Widget>[
                Container(
                  height: 80,
                  color: Color(BACKGROUND_COLOR),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF707070),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(1),
                    child: CircleGravatar(
                      placeholder: '${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}',
                      uid: user.email,
                      radius: 42
                    ),
                  ),
                ),
                Positioned(
                  top: 56,
                  right: 16,
                  child: Container(
                      height: 32,
                      width: 32,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color(PRIMARY_COLOR),
                          borderRadius: BorderRadius.circular(24)),
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: _logout,
                        icon: SvgPicture.asset(
                          'images/disconnect.svg',
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          );
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
                margin: EdgeInsets.only(top: 48, left: 8, right: 8),
                height: 40,
                alignment: Alignment.center,
                child: ToggleButtons(
                  borderColor: Color(0xFFCCCCCC),
                  selectedBorderColor: Color(PRIMARY_COLOR),
                  selectedColor: Colors.white,
                  fillColor: Color(PRIMARY_COLOR),
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  isSelected: modes,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: Text('Check-in'.toUpperCase()),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: Text('Sponsor'.toUpperCase()),
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

  FutureBuilder<User> _buildUserInfo() => FutureBuilder(
      future: fUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
              padding: EdgeInsets.only(top: 32),
              child: Column(children: <Widget>[
                Text(
                  '${snapshot.data.firstName} ${snapshot.data.lastName}'
                      .toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('${snapshot.data.email}'),
                )
              ]));
        }
        return Text('');
      });

  _logout() async {
    await storage.deleteAll();
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
  }

  Future<User> _getUser() async =>
      User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));

  Future<String> _getMode() async => await storage.read(key: STORAGE_KEY_MODE);
}
