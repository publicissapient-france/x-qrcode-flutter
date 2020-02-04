import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_auth0/flutter_auth0.dart';

import '../constants.dart';

class OrganizationScreen extends StatefulWidget {
  OrganizationScreen({Key key}) : super(key: key);

  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  Auth0 auth0;
  Future<UserInfo> userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 56, 75),
      body: Padding(
        padding: EdgeInsets.all(48),
        child: FutureBuilder<UserInfo>(
          future: userInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 64, bottom: 16),
                    child: RichText(
                      text: TextSpan(
                          text: '',
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                                text: 'Bonjour ${snapshot.data.nickname}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                              text:
                                  ', sélectionnez une organisation pour continuer.',
                            ),
                          ]),
                    ),
                  ),
                  ListBody(
                      children: snapshot.data.tenants
                          .map((tenant) => RaisedButton(
                                onPressed: () {},
                                child: Text(tenant),
                              ))
                          .toList()),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<UserInfo> _getUserInfo() async {
    auth0 = Auth0(
        baseUrl: DotEnv().env[ENV_KEY_AUTH_URL],
        clientId: DotEnv().env[ENV_KEY_CLIENT_ID]);
    var token =
        await FlutterSecureStorage().read(key: STORAGE_KEY_ACCESS_TOKEN);
    var auth0Auth = Auth0Auth(auth0.auth.clientId, auth0.auth.client.baseUrl,
        bearer: token);
    var _info = await auth0Auth.getUserInfo();
    return UserInfo(
        _info['nickname'],
        List<String>.from(
            _info['$APP_NAMESPACE/claims/app_metadata']['tenants']));
  }
}

class UserInfo {
  final String nickname;
  final List<String> tenants;

  UserInfo(this.nickname, this.tenants);
}
