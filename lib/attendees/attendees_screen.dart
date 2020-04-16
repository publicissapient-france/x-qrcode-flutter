import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        body: StreamBuilder<List<Attendee>>(
            stream: bloc.attendeesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final attendees = snapshot.data;
                final attendeesChecked =
                    attendees.where((a) => a.checkIn).length;
                return Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(12),
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
                              value: attendeesChecked / attendees.length,
                            ),
                          ),
                          Container(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  attendeesChecked.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(PRIMARY_COLOR),
                                      fontSize: 16),
                                ),
                              ),
                              Text(
                                attendees.length.toString(),
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
                      child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: attendees.length,
                          itemBuilder: (context, index) {
                            Attendee attendee = attendees[index];
                            return GestureDetector(
                                onTap: () {
                                  bloc.toggleCheck(
                                      attendee.id, !attendee.checkIn, fromCamera: false);
                                },
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Container(
                                    child: ListTile(
                                      title: Text(
                                          "${attendee.firstName} ${attendee.lastName}"),
                                      leading: CircleGravatar(
                                        uid: attendee.email,
                                        placeholder:
                                            '${attendee.firstName.substring(0, 1)}${attendee.lastName.substring(0, 1)}',
                                      ),
                                      trailing: Icon(
                                        Icons.check_circle,
                                        size: 30,
                                        color: attendee.checkIn
                                            ? Color(PRIMARY_COLOR)
                                            : Color(0xFFD3D3D3),
                                      ),
                                    ),
                                  ),
                                ));
                          }),
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
