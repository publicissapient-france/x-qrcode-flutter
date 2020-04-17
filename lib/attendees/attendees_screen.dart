import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/attendees/attendees_bloc.dart';
import 'package:x_qrcode/attendees/checkin_exception.dart';
import 'package:x_qrcode/common/circle_gravatar_widget.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';
import 'package:x_qrcode/visitor/widget/scan_floating_action_widget.dart';
import 'package:x_qrcode/visitor/widget/search_input_widget.dart';

import '../constants.dart';

const attendeeRoute = '/attendees';

class AttendeesScreen extends StatefulWidget {
  AttendeesScreen({Key key}) : super(key: key);

  @override
  _AttendeesScreeState createState() => _AttendeesScreeState();
}

class _AttendeesScreeState extends State<AttendeesScreen> {
  final searchTextEditingController = TextEditingController();
  final AttendeesBloc bloc = AttendeesBloc(apiService: ApiService());

  String barcode;

  @override
  void initState() {
    super.initState();

    bloc.loadAttendees();

    searchTextEditingController.addListener(() =>
        bloc.searchAttendees(searchTextEditingController.text.toLowerCase()));

    bloc.eventsStream.listen((event) {
      if (event == AttendeesEvents.toggleSuccess) {
        _onToggleSuccess(context);
      }
    });
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(BACKGROUND_COLOR),
        appBar: AppBar(
          title: Text('Check-in'.toUpperCase()),
        ),
        body: StreamBuilder<Map<String, List<Attendee>>>(
            stream: bloc.attendeesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 12, right: 12, top: 12, bottom: 6),
                      child: Column(
                        children: <Widget>[
                          SearchInput(
                            searchTextEditingController:
                                searchTextEditingController,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            child: LinearProgressIndicator(
                              backgroundColor: Color(0xFFD3D3D3),
                              value: bloc.checked / bloc.count,
                            ),
                          ),
                          Container(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  bloc.checked.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(PRIMARY_COLOR),
                                      fontSize: 16),
                                ),
                              ),
                              Text(
                                bloc.count.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 16),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: snapshot.data.entries
                            .map((a) => SliverStickyHeader(
                                header: Container(
                                  height: 28,
                                  color: Color(0xFFD3D3D3),
                                  padding: EdgeInsets.only(left: 12, top: 6),
                                  child: Text(a.key.toUpperCase()),
                                ),
                                sliver: SliverPadding(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 8, top: 8, bottom: 8),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        (context, i) =>
                                            _buildAttendee(a.value[i]),
                                        childCount: a.value.length),
                                  ),
                                )))
                            .toList(),
                      ),
                    )
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: ScanFloatingActionButton(
          onPressed: _scanQrCode,
        ));
  }

  GestureDetector _buildAttendee(Attendee attendee) => GestureDetector(
      onTap: () {
        bloc.toggleCheck(attendee.id, !attendee.checkIn, fromCamera: false);
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          child: ListTile(
            title: Text("${attendee.firstName} ${attendee.lastName}"),
            leading: CircleGravatar(
              uid: attendee.email,
              placeholder: attendee.placeholder,
            ),
            trailing: Icon(
              Icons.check_circle,
              size: 30,
              color:
                  attendee.checkIn ? Color(PRIMARY_COLOR) : Color(0xFFD3D3D3),
            ),
          ),
        ),
      ));

  void _scanQrCode(ctx) async {
    try {
      String barcode = await BarcodeScanner.scan();
      _showLoading(ctx);
      bloc.toggleCheck(barcode, true);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _onScanError(ctx, 'Vous devez accepter la permission 📸');
      } else {
        _onScanError(ctx, 'Une erreur s‘est produite 😭');
      }
    } on FormatException {
      bloc.loadAttendees();
    } on CheckInException {
      Navigator.pop(ctx);
      _showError(ctx);
      await Future.delayed(Duration(milliseconds: 750));
      Navigator.pop(ctx);
      _scanQrCode(ctx);
    } catch (e) {
      _onScanError(ctx, 'Une erreur s‘est produite 😭');
    }
  }

  void _onToggleSuccess(ctx) async {
    Navigator.pop(ctx);
    _showSuccess(ctx);
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.pop(ctx);
    _scanQrCode(ctx);
  }

  void _showSuccess(ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(32),
              color: Colors.green,
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 152,
              ),
            ),
          );
        });
  }

  void _showError(ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(32),
              color: Colors.red,
              child: Icon(
                Icons.not_interested,
                color: Colors.white,
                size: 152,
              ),
            ),
          );
        });
  }

  void _showLoading(ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  )));
        });
  }

  void _onScanError(ctx, message) {
    Scaffold.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red[900], content: Text(message)));
  }
}