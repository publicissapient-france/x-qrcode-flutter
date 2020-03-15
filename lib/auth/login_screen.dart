import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_qrcode/organization/organization_screen.dart';

import '../constants.dart';

const loginRoute = '/';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Auth0 auth0 = Auth0(
      baseUrl: DotEnv().env[ENV_KEY_OAUTH_AUTH_URL],
      clientId: DotEnv().env[ENV_KEY_OAUTH_CLIENT_ID]);
  final FlutterSecureStorage storage = FlutterSecureStorage();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    _pushOrganizationIfTokenExists();
    super.initState();
  }

  void _pushOrganizationIfTokenExists() {
    Future(() {
      storage.read(key: STORAGE_KEY_ACCESS_TOKEN).then((token) {
        if (token != null) {
          Navigator.pushNamed(context, organisationsRoute);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Expanded(
              flex: 6,
              child: ListView(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * .1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 8,
                        child: SvgPicture.asset(
                          'images/logo_xqrcode.svg',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: SvgPicture.asset(
                            'images/logo_mark.svg',
                            color: Color(PRIMARY_COLOR),
                            height: 120,
                          ),
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                        labelText: "E-mail",
                        contentPadding: EdgeInsets.only(top: 8, bottom: 4)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Mot de passe",
                              contentPadding:
                                  EdgeInsets.only(top: 8, bottom: 4)))),
                  SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: FlatButton(
                          color: Color(PRIMARY_COLOR),
                          child: Text(
                            "Suivant".toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => onPressed(),
                        ),
                      )),
                  Container(
                    height: MediaQuery.of(context).size.height * .15,
                  ),
                  Image.asset(
                    'images/logo_pse.png',
                    height: 120,
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ],
        ),
      );

  void onPressed() {
    _connect(usernameController.text, passwordController.text);
  }

  void _connect(String username, String password) async {
    try {
      var response = await auth0.auth.passwordRealm({
        'username': '$username',
        'password': '$password',
        'audience': DotEnv().env[ENV_KEY_OAUTH_AUDIENCE],
        'scope': DotEnv().env[ENV_KEY_OAUTH_SCOPE],
        'realm': DotEnv().env[ENV_KEY_OAUTH_REALM]
      });
      final token = response['access_token'];
      await storage.write(key: STORAGE_KEY_ACCESS_TOKEN, value: token);
      Navigator.of(context)
          .pushNamedAndRemoveUntil(organisationsRoute, (_) => false);
    } catch (e) {
      print(e);
    }
  }
}
