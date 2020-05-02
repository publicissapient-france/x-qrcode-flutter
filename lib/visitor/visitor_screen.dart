import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/visitor/widget/header_widget.dart';
import 'package:x_qrcode/visitor/widget/info_widget.dart';
import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/organization/model/user_model.dart';

import '../constants.dart';
import 'model/attendee_model.dart';

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
  final _storage = FlutterSecureStorage();

  _VisitorScreenState(this.visitorId);

  Future<Attendee> _visitor;
  bool _loading = false;
  bool _commentFieldVisible = false;
  TextEditingController _commentController;

  @override
  void initState() {
    _visitor = ApiService().getAttendee(this.visitorId, true);
    _commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Commentaires'.toUpperCase()),
          elevation: 0,
        ),
        body: FutureBuilder(
          future: _visitor,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Attendee visitor = snapshot.data;
              return Column(children: <Widget>[
                HeaderWidget(attendee: visitor),
                Expanded(
                    child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate([
                        snapshot.data.company != null
                            ? InfoWidget(
                                snapshot.data.company,
                                SvgPicture.asset('images/ic_company.svg'),
                                first: true,
                              )
                            : Container(),
                        snapshot.data.jobTitle != null
                            ? InfoWidget(
                                snapshot.data.jobTitle,
                                SvgPicture.asset('images/ic_job.svg'),
                              )
                            : Container(),
                        InfoWidget(
                          snapshot.data.email,
                          SvgPicture.asset('images/ic_email.svg'),
                          copyToClipboard: true,
                        ),
                        _commentFieldVisible
                            ? Container()
                            : _buildWriteComment(),
                        _commentFieldVisible
                            ? _buildCommentField(visitor.firstName)
                            : Container(),
                      ]),
                    ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildComment(
                          index, visitor, snapshot, visitor.comments[index]),
                      childCount: visitor.comments.length,
                    ))
                  ],
                ))
              ]);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Card _buildComment(
      int index, Attendee visitor, AsyncSnapshot snapshot, Comment comment) {
    return Card(
      color: Color(0xFFF4F4F4),
      elevation: 0,
      margin: EdgeInsets.only(
          top: 8,
          right: 8,
          left: 8,
          bottom: index == visitor.comments.length - 1 ? 8 : 0),
      child: Stack(children: <Widget>[
        _buildPopupMenu(snapshot, comment),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCommentHeader(comment),
              _buildCommentContent(comment)
            ],
          ),
        )
      ]),
    );
  }

  Container _buildCommentContent(Comment comment) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Text(comment.text),
    );
  }

  Row _buildCommentHeader(Comment comment) => Row(
        children: <Widget>[
          Expanded(
            child: Text(
              comment.authorFirstName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 24),
            child: Text(
              _toPrettyDate(comment.date),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          )
        ],
      );

  Positioned _buildPopupMenu(AsyncSnapshot snapshot, Comment comment) =>
      Positioned(
          right: 0,
          top: 0,
          child: PopupMenuButton(
              icon: Icon(Icons.more_horiz, color: Colors.black),
              itemBuilder: (context) => [
                    PopupMenuItem(value: 0, child: Text('Supprimer')),
                  ],
              onSelected: (value) =>
                  _onCommentMenuItemSelected(snapshot, comment, value)));

  Card _buildCommentField(String firstName) => Card(
        elevation: 0,
        margin: EdgeInsets.only(top: 8, right: 8, left: 8),
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 8, right: 16, bottom: 24, left: 16),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        'Ajouter des commentaires à propos de $firstName...'),
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Color(PRIMARY_COLOR),
                      borderRadius: BorderRadius.circular(16)),
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: _loading ? null : _saveComment,
                    icon: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  )),
            )
          ],
        ),
      );

  Container _buildWriteComment() => Container(
      margin: EdgeInsets.only(top: 8, right: 8, left: 8),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(4),
        ),
        color: Color(PRIMARY_COLOR),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            Container(
                margin: EdgeInsets.only(left: 32, top: 16, bottom: 16),
                child: Text(
                  'Ajouter un commentaire',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        onPressed: () {
          setState(() {
            _commentFieldVisible = true;
          });
        },
      ));

  void _saveComment() async {
    if (_commentController.text.isNotEmpty) {
      this._loading = true;
      final user =
          User.fromJson(jsonDecode(await _storage.read(key: STORAGE_KEY_USER)));
      final accessToken = await _storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
      final event = Event.fromJson(
          jsonDecode(await _storage.read(key: STORAGE_KEY_EVENT)));
      final response = await http.post(
          '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/visitors/$visitorId/comments',
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          },
          body: {
            'description': _commentController.text,
            'date': DateTime.now().toIso8601String(),
          });
      if (response.statusCode == 201) {
        this._commentController.text = '';
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _visitor = ApiService().getAttendee(this.visitorId, true);
          _commentFieldVisible = false;
        });
      } else {
        throw Exception('Cannot comment on visitor');
      }
      this._loading = false;
    }
  }

  void _deleteComment(AsyncSnapshot snapshot, Comment comment) async {
    this._loading = true;
    final user =
        User.fromJson(jsonDecode(await _storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await _storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await _storage.read(key: STORAGE_KEY_EVENT)));
    final response = await http.delete(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/visitors/$visitorId/comments/${comment.id}',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    if (response.statusCode == 204) {
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        snapshot.data.comments
            .removeWhere((_comment) => _comment.id == comment.id);
      });
    } else {
      throw Exception('Cannot delete comment');
    }
    this._loading = false;
  }

  void _onCommentMenuItemSelected(
      AsyncSnapshot snapshot, Comment comment, int value) {
    switch (value) {
      case 0:
        _confirmDeletion(snapshot, comment);
        break;
    }
  }

  void _confirmDeletion(AsyncSnapshot snapshot, Comment comment) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text(
                    'Êtes-vous sûr ?\n\nLe commentaire sera supprimé définitivement.'),
                actions: [
                  FlatButton(
                      child: Text("Annuler"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  FlatButton(
                      child: Text("Supprimer"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteComment(snapshot, comment);
                      })
                ]));
  }

  String _toPrettyDate(String date) {
    final d = DateTime.parse(date);
    return '${d.day}/${d.month} à ${d.hour}h${d.minute < 10 ? '0${d.minute}' : d.minute}';
  }
}
