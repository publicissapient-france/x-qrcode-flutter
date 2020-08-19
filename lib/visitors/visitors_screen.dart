import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc_provider.dart';
import 'package:x_qrcode/constants.dart';
import 'package:x_qrcode/main_bloc.dart';
import 'package:x_qrcode/widget/circle_gravatar_widget.dart';
import 'package:x_qrcode/visitor/widget/scan_floating_action_widget.dart';
import 'package:x_qrcode/visitor/visitor_screen.dart';
import 'package:x_qrcode/visitor/widget/search_input_widget.dart';
import 'package:x_qrcode/visitors/visitors_bloc.dart';

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

    bloc.eventsStream.listen((event) async {
      switch (event.type) {
        case VisitorsEvents.scanSuccessExists:
          Navigator.pushNamed(context, visitorRoute,
              arguments: VisitorScreenArguments(event.id));
          break;
        case VisitorsEvents.scanSuccess:
          BlocProvider.of<MainBloc>(context).logEvent(
            ANALYTICS_EVENT_VISITOR_SCAN,
          );
          final visitorConsent = await Navigator.pushNamed(
            context,
            consentRoute,
            arguments: ConsentScreenArguments(event.id),
          );
          if (visitorConsent == true) {
            bloc.loadVisitors();
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Visiteurs'.toUpperCase()),
      ),
      body: BlocProvider<VisitorsBloc>(
        bloc: bloc,
        child: StreamBuilder<Map<String, List<Attendee>>>(
          stream: bloc.visitorsStream,
          builder: (context, snapshot) {
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
                      child: CustomScrollView(
                          slivers: snapshot.data.entries
                              .map((v) => SliverStickyHeader(
                                  header: Container(
                                    height: 28,
                                    color: Color(0xFFD3D3D3),
                                    padding: EdgeInsets.only(left: 12, top: 6),
                                    child: Text(v.key.toUpperCase()),
                                  ),
                                  sliver: SliverPadding(
                                    padding: EdgeInsets.only(
                                        left: 8, right: 8, top: 8, bottom: 8),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                          (context, i) =>
                                              _buildVisitor(v.value[i]),
                                          childCount: v.value.length),
                                    ),
                                  )))
                              .toList())),
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

  GestureDetector _buildVisitor(Attendee visitor) => GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, visitorRoute,
            arguments: VisitorScreenArguments(visitor.id));
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          child: ListTile(
            leading: CircleGravatar(
              uid: visitor.email,
              placeholder:
                  '${visitor.firstName.substring(0, 1)}${visitor.lastName.substring(0, 1)}',
            ),
            title: Text("${visitor.firstName} ${visitor.lastName}"),
          ),
        ),
      ));

  void _scanQrCode(ctx) async {
    try {
      var scanResult = await BarcodeScanner.scan();
      if (scanResult.type == ResultType.Barcode) {
        bloc.onVisitorScan(jsonDecode(scanResult.rawContent)['attendee_id']);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        _onScanError(ctx, 'Vous devez accepter la permission 📸');
      } else {
        _onScanError(ctx, 'Une erreur s‘est produite 😭');
      }
    } catch (e) {
      _onScanError(ctx, 'Une erreur s‘est produite 😭');
    }
  }

  void _onScanError(ctx, message) {
    Scaffold.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red[900], content: Text(message)));
  }
}
