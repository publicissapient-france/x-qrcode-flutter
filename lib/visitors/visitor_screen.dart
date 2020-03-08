import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/events/events_screen.dart';
import 'package:x_qrcode/organization/user.dart';
import 'package:x_qrcode/visitors/attendee.dart';

import '../constants.dart';

class VisitorScreenArguments {
  final String visitorId;

  VisitorScreenArguments(this.visitorId);
}

const visitorRoute = '/visitor';

class VisitorScreen extends StatefulWidget {
  final String visitorId;

  VisitorScreen({Key key, @required this.visitorId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VisitorScreenState(this.visitorId);
}

class _VisitorScreenState extends State<VisitorScreen> {
  final visitorId;

  final storage = FlutterSecureStorage();
  final commentController = TextEditingController();

  Future<Attendee> visitor;

  _VisitorScreenState(this.visitorId);

  bool loading = false;

  @override
  void initState() {
    this.visitor = ApiService().getAttendee(this.visitorId, true);
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('📝 Notes'),
        ),
        body: FutureBuilder(
          future: visitor,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Card(
                          elevation: 2,
                          margin: EdgeInsets.only(top: 8, right: 8, left: 8),
                          child: Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.all(16),
                              child: Column(children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://www.gravatar.com/avatar/${md5.convert(utf8.encode(snapshot.data.email)).toString()}?s=200'),
                                  radius: 45,
                                ),
                                Container(
                                  height: 16,
                                ),
                                RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: snapshot.data.firstName,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                              text:
                                                  ' ${snapshot.data.lastName}',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal))
                                        ]))
                              ]))),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(top: 8, right: 8, left: 8),
                        child: Container(
                          margin: EdgeInsets.all(16),
                          child: Text(snapshot.data.email),
                        ),
                      ),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(top: 8, right: 8, left: 8),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  top: 16, right: 16, bottom: 24, left: 16),
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        'Ajouter des notes à propos de ${snapshot.data.firstName}...'),
                                minLines: 2,
                                maxLines: 6,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton(
                                onPressed: loading ? null : _saveComment,
                                icon: Icon(Icons.save),
                                color: Colors.green,
                              ),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    Comment comment = snapshot.data.comments[index];
                    return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(
                            top: 8,
                            right: 8,
                            left: 8,
                            bottom: index == snapshot.data.comments.length - 1
                                ? 8
                                : 0),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.message,
                                    color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: Text(
                                      ' ${comment.authorFirstName}',
                                    ),
                                  ),
                                  comment.date != null
                                      ? Text(
                                          _toPrettyDate(comment.date),
                                        )
                                      : Container()
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Text(comment.text),
                              )
                            ],
                          ),
                        ));
                  }, childCount: snapshot.data.comments.length))
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  void _saveComment() async {
    if (commentController.text.isNotEmpty) {
      this.loading = true;
      final user =
          User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
      final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
      final event = Event.fromJson(
          jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));
      final response = await http.post(
          '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/visitors/$visitorId/comments',
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          },
          body: {
            'description': commentController.text,
            'date': DateTime.now().toIso8601String(),
          });
      if (response.statusCode == 201) {
        this.commentController.text = '';
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          visitor = ApiService().getAttendee(this.visitorId, true);
        });
      } else {
        throw Exception('Cannot comment on visitor');
      }
      this.loading = false;
    }
  }

  String _toPrettyDate(String date) {
    final d = DateTime.parse(date);
    return '${d.day}/${d.month} - ${d.hour}h${d.minute < 10 ? '0${d.minute}' : d.minute}';
  }
}
