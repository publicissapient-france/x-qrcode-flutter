import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/common/bloc_provider.dart';
import 'package:x_qrcode/common/circle_gravatar_widget.dart';
import 'package:x_qrcode/visitor/widget/scan_floating_action_widget.dart';
import 'package:x_qrcode/visitor/visitor_screen.dart';
import 'package:x_qrcode/visitor/widget/search_input_widget.dart';
import 'package:x_qrcode/visitors/visitors_bloc.dart';

import '../constants.dart';
import '../visitor/consent_screen.dart';
import '../visitor/model/attendee_model.dart';

const visitorsRoute = '/visitors';

class VisitorsScreen extends StatefulWidget {
  VisitorsScreen({Key key}) : super(key: key);

  @override
  _VisitorsScreeState createState() => _VisitorsScreeState();
}

class _VisitorsScreeState extends State<VisitorsScreen> {
  final searchTextEditingController = TextEditingController();
  final bloc = VisitorsBloc(apiService: ApiService());

  String barcode;

  @override
  void initState() {
    super.initState();
    bloc.loadVisitors();
    searchTextEditingController.addListener(() =>
        bloc.searchVisitors(searchTextEditingController.text.toLowerCase()));
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color(BACKGROUND_COLOR),
      appBar: AppBar(
        title: Text('Visiteurs'.toUpperCase()),
      ),
      body: BlocProvider<VisitorsBloc>(
        bloc: bloc,
        child: StreamBuilder<List<Attendee>>(
          stream: bloc.visitorsStream,
          builder: (context, snapshot) {
            final visitors = snapshot.data;
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(12),
                      child: ClipRRect(
                        child: SearchInput(
                          searchTextEditingController:
                              searchTextEditingController,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      )),
                  Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: visitors.length,
                          itemBuilder: (context, index) {
                            Attendee visitor = visitors[index];
                            return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, visitorRoute,
                                      arguments:
                                          VisitorScreenArguments(visitor.id));
                                },
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Container(
                                    child: ListTile(
                                      leading: CircleGravatar(
                                        uid: visitor.email,
                                        placeholder:
                                            '${visitor.firstName.substring(0, 1)}${visitor.lastName.substring(0, 1)}',
                                      ),
                                      title: Text(
                                          "${visitor.firstName} ${visitor.lastName}"),
                                    ),
                                  ),
                                ));
                          }))
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: ScanFloatingActionButton(
        onPressed: _scanQrCode,
      ));

  void _scanQrCode(ctx) async {
    try {
      String barcode = await BarcodeScanner.scan();
      Map<String, dynamic> attendee = jsonDecode(barcode);
      var visitorId = attendee['attendee_id'];
      final visitorConsent = await Navigator.pushNamed(context, consentRoute,
          arguments: ConsentScreenArguments(visitorId));
      if (visitorConsent == true) {
        bloc.loadVisitors();
        Navigator.pushNamed(context, visitorsRoute,
            arguments: VisitorScreenArguments(visitorId));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _onScanError(ctx, 'Vous devez accepter la permission 📸');
      } else {
        _onScanError(ctx, 'Une erreur s‘est produite 😭');
      }
    } on FormatException {
      // do nothing on back press.
    } catch (e) {
      _onScanError(ctx, 'Une erreur s‘est produite 😭');
    }
  }

  void _onScanError(ctx, message) {
    Scaffold.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red[900], content: Text(message)));
  }
}
