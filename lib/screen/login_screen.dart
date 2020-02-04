import 'package:flutter/material.dart';
import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Auth0 auth0;
  FlutterSecureStorage storage;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    auth0 = Auth0(
        baseUrl: DotEnv().env[ENV_KEY_OAUTH_AUTH_URL],
        clientId: DotEnv().env[ENV_KEY_OAUTH_CLIENT_ID]);
    storage = FlutterSecureStorage();
    _pushOrganizationIfTokenExists();
    super.initState();
  }

  void _pushOrganizationIfTokenExists() {
    // Todo check appropriate first screen in main.dart
    Future(() {
      storage.read(key: STORAGE_KEY_ACCESS_TOKEN).then((token) {
        if (token != null) {
          Navigator.pushNamed(context, Routes.events);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 56, 75),
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 16),
                child:
                    SvgPicture.asset('images/xqrcode_logo.svg', height: 150)),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
            ),
            Padding(
                padding: EdgeInsets.only(top: 16),
                child: RaisedButton(
                  child: Text(
                    "Sign in",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => onPressed(),
                  color: Colors.blue,
                )),
            Padding(
                padding: EdgeInsets.only(top: 16),
                child: SvgPicture.asset(
                  'images/byxebia_logo.svg',
                  height: 50,
                ))
          ],
        ),
      ));

  void onPressed() {
    _connect(usernameController.text, passwordController.text);
  }

  void _connect(String username, String password) async {
    try {
      var response = await auth0.auth.passwordRealm({
        'username': '$username',
        'password': '$password',
        'audience': DotEnv().env[ENV_KEY_OAUTH_AUTH_URL],
        'scope': DotEnv().env[ENV_KEY_OAUTH_SCOPE],
        'realm': DotEnv().env[ENV_KEY_OAUTH_REALM]
      });
      final token = response['access_token'];
      await storage.write(
          key: STORAGE_KEY_ACCESS_TOKEN, value: token);
      Navigator.pushNamed(context, Routes.organizations);
    } catch (e) {
      print(e);
    }
  }
}
