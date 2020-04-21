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
    clientId: DotEnv().env[ENV_KEY_OAUTH_CLIENT_ID],
  );
  final FlutterSecureStorage storage = FlutterSecureStorage();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool error = false;
  bool loading = false;

  @override
  void initState() {
    _pushOrganizationIfTokenExists();
    usernameController.addListener(() {
      setState(() {
        error = false;
      });
    });
    passwordController.addListener(() {
      setState(() {
        error = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
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
                  error
                      ? Container(
                          margin: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Connexion échouée, veuillez vérifier vos identifiants.',
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Container(),
                  TextFormField(
                    controller: usernameController,
                    focusNode: _usernameFocus,
                    enabled: !loading,
                    decoration: InputDecoration(
                        labelText: "Email",
                        contentPadding: EdgeInsets.only(top: 8, bottom: 4)),
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (_) {
                      _usernameFocus.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: TextFormField(
                      controller: passwordController,
                      focusNode: _passwordFocus,
                      enabled: !loading,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        contentPadding: EdgeInsets.only(top: 8, bottom: 4),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _connect(
                        context,
                        usernameController.text,
                        passwordController.text,
                      ),
                    ),
                  ),
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
                          onPressed: loading
                              ? () {}
                              : () => _connect(
                                    context,
                                    usernameController.text,
                                    passwordController.text,
                                  ),
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

  void _connect(BuildContext context, String username, String password) async {
    try {
      setState(() {
        loading = true;
      });
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
    } catch (_) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }
}
