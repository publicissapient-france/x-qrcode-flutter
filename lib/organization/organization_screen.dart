import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:x_qrcode/constants.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/organization/model/user_model.dart';

import '../constants.dart';
import 'model/company_model.dart';

const organisationsRoute = '/organizations';

class OrganizationsScreen extends StatefulWidget {
  OrganizationsScreen({Key key}) : super(key: key);

  @override
  _OrganizationsScreenState createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  final auth0 = Auth0(
      baseUrl: DotEnv().env[ENV_KEY_OAUTH_AUTH_URL],
      clientId: DotEnv().env[ENV_KEY_OAUTH_CLIENT_ID]);
  final storage = FlutterSecureStorage();

  Future<UserInfo> userInfo;

  @override
  void initState() {
    userInfo = _getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: EdgeInsets.all(48),
          child: FutureBuilder<UserInfo>(
            future: userInfo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 96, bottom: 16),
                      child: RichText(
                        text: TextSpan(
                            text: 'Bonjour',
                            style: Theme.of(context).textTheme.body1,
                            children: [
                              TextSpan(
                                  text: ' ${snapshot.data.firstName}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text:
                                    ', sélectionnez une organisation pour continuer :',
                              ),
                            ]),
                      ),
                    ),
                    Flexible(
                        child: ListView.builder(
                            itemCount: snapshot.data.tenants.length,
                            itemBuilder: (context, index) => Container(
                                padding: EdgeInsets.only(bottom: 16),
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.all(15),
                                  color: Color(PRIMARY_COLOR),
                                  onPressed: () async {
                                    var company = await _getCompany(
                                        snapshot.data.tenants[index]);
                                    var user = User(
                                        snapshot.data.firstName,
                                        snapshot.data.lastName,
                                        snapshot.data.email,
                                        snapshot.data.tenants[index],
                                        company,
                                        snapshot.data.roles);
                                    await storage.write(
                                        key: STORAGE_KEY_USER,
                                        value: jsonEncode(user));
                                    if (user.roles.contains(ROLE_ADMIN)) {
                                      await storage.write(
                                          key: STORAGE_KEY_MODE,
                                          value: MODE_CHECK_IN);
                                    }
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      eventsRoute,
                                      (_) => false,
                                    );
                                  },
                                  child: Text(
                                    snapshot.data.tenants[index].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )))),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Image.asset(
                        'images/logo_pse.png',
                        height: 120,
                      ),
                    )
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );

  Future<UserInfo> _getUserInfo() async {
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final auth0Auth = Auth0Auth(auth0.auth.clientId, auth0.auth.client.baseUrl,
        bearer: accessToken);
    final info = await auth0Auth.getUserInfo();
    return UserInfo.fromJson(info);
  }

  Future<Company> _getCompany(tenant) async {
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    try {
      final response = await http.get(
          '${DotEnv().env[ENV_KEY_API_URL]}/$tenant/companies/my-company',
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
      return Company.fromJson(jsonDecode(response.body));
    } catch (error) {
      throw Exception('Cannot get company: ${error.toString()}');
    }
  }
}

class UserInfo {
  final String firstName;
  final String lastName;
  final String email;
  final List<String> roles;
  final List<String> tenants;

  UserInfo(this.firstName, this.lastName, this.email, this.roles, this.tenants);

  UserInfo.fromJson(Map<dynamic, dynamic> json)
      : firstName = json['$APP_NAMESPACE/claims/user_metadata']['firstName'],
        lastName = json['$APP_NAMESPACE/claims/user_metadata']['lastName'],
        email = json['email'],
        roles = List<String>.from(
            json['$APP_NAMESPACE/claims/app_metadata']['roles']),
        tenants = List<String>.from(
            json['$APP_NAMESPACE/claims/app_metadata']['tenants']);
}
