import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';
import 'package:x_qrcode/widget/circle_gravatar_widget.dart';

import '../../constants.dart';

class HeaderWidget extends StatelessWidget {
  final Attendee attendee;
  final bool checkMode;
  final bool checkIn;
  final Function onCheck;

  const HeaderWidget(
      {Key key,
      this.attendee,
      this.checkMode: false,
      this.checkIn: false,
      this.onCheck})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 160,
                margin: EdgeInsets.only(bottom: 4),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.only(right: 8, left: 8),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '${attendee.firstName} ${attendee.lastName}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                ),
              )),
          Container(
            height: 50,
            color: Color(PRIMARY_COLOR),
          ),
          checkMode
              ? GestureDetector(
                  onTap: onCheck,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 8, top: 32),
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.check_circle,
                        size: 30,
                        color:
                            checkIn ? Color(PRIMARY_COLOR) : Color(0xFFD3D3D3),
                      ),
                    ),
                  ),
                )
              : Container(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
                height: 112,
                width: 112,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                padding: EdgeInsets.all(4),
                child: CircleGravatar(
                  uid: attendee.email,
                  placeholder: attendee.placeholder,
                )),
          ),
        ],
      );
}
