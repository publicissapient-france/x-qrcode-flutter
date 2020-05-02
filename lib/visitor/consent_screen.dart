import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/organization/model/user_model.dart';
import 'package:x_qrcode/visitor/visitor_screen.dart';

import '../constants.dart';
import 'model/attendee_model.dart';

class ConsentScreenArguments {
  final String visitorId;

  ConsentScreenArguments(this.visitorId);
}

const consentRoute = '/consent';

class ConsentScreen extends StatefulWidget {
  final String visitorId;

  ConsentScreen({Key key, @required this.visitorId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConsentScreenState(this.visitorId);
}

class _ConsentScreenState extends State<ConsentScreen> {
  final storage = FlutterSecureStorage();
  final String visitorId;

  final signature = SignatureController();

  var consent = false;
  var signed = false;
  Future<Data> screenData;

  _ConsentScreenState(this.visitorId);

  @override
  void initState() {
    signature.addListener(() => setState(() => signed = true));
    screenData = _getScreenData(visitorId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('🔏 Consentement'),
      ),
      body: FutureBuilder<Data>(
          future: screenData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final visitor = snapshot.data.visitor;
              return SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Container(
                              height: 100,
                              alignment: Alignment(0, 1),
                              child: Image.network(
                                  snapshot.data.user.company.logo),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Je souhaite partager avec ',
                                style: Theme.of(context).textTheme.body1,
                                children: [
                                  TextSpan(
                                      text: snapshot.data.user.company.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          ' les données personnelles suivantes :'),
                                ]),
                          ),
                          Container(
                              alignment: Alignment(-1, -1),
                              color: Colors.white,
                              margin: EdgeInsets.only(top: 16, bottom: 16),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      '${visitor.firstName} ${visitor.lastName}'),
                                  Text(visitor.email),
                                  visitor.company != null
                                      ? Text(visitor.company)
                                      : Container(),
                                  visitor.jobTitle != null
                                      ? Text(visitor.jobTitle)
                                      : Container(),
                                ],
                              )),
                          Row(
                            children: <Widget>[
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.79,
                                  child: RichText(
                                    text: TextSpan(
                                        text:
                                            'Je déclare avir pris connaissance de la ',
                                        style:
                                            Theme.of(context).textTheme.body1,
                                        children: [
                                          TextSpan(
                                              text:
                                                  'politique de confidentialité',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(text: ' de la société '),
                                          TextSpan(
                                              text: snapshot
                                                  .data.user.company.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  ', et j‘accepte que mes informations détaillées ci-avant lui soient communiquées directement par l‘Organisateur.'),
                                        ]),
                                  )),
                              Checkbox(
                                value: consent,
                                onChanged: (bool value) {
                                  setState(() {
                                    consent = value;
                                  });
                                },
                              )
                            ],
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 16),
                              child: Signature(
                                controller: signature,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                backgroundColor: Colors.white,
                              )),
                          Container(
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(
                                    height: 40,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Annuler'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: RaisedButton(
                                      onPressed: consent && signed
                                          ? () async {
                                              final bytes =
                                                  await signature.toPngBytes();
                                              await _addVisitor(visitor,
                                                  "data:image/png;base64,${base64.encode(bytes)}");
                                            }
                                          : null,
                                      child: Text('Valider'),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }));

  Future<User> _getUser() async {
    return User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
  }

  _addVisitor(Attendee visitor, signature) async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.put(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/visitors/${visitor.id}',
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: {
          'firstName': visitor.firstName,
          'lastName': visitor.lastName,
          'signature': signature,
        });
    if (response.statusCode == 201) {
      Navigator.pushReplacementNamed(
        context,
        visitorRoute,
        result: true,
        arguments: VisitorScreenArguments(visitorId),
      );
    } else {
      throw Exception('Cannot add visitor');
    }
  }

  Future<Data> _getScreenData(String visitorId) async =>
      Data(await _getUser(), await ApiService().getAttendee(visitorId, false));
}

class Data {
  final User user;
  final Attendee visitor;

  Data(this.user, this.visitor);
}
