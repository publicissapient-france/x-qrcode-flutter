import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoWidget extends StatelessWidget {
  final String info;
  final Widget icon;
  final bool first;
  final bool copyToClipboard;

  InfoWidget(this.info, this.icon,
      {this.first: false, this.copyToClipboard: false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.only(
            top: first ? 4 : 8,
            right: 8,
            left: 8,
          ),
          child: Row(
            children: <Widget>[
              Container(
                child: icon,
                margin: EdgeInsets.only(left: 8, right: 4),
              ),
              Text(info),
            ],
          ),
        ),
        onTap: copyToClipboard ? () => _copyToClipboard(context, info) : () {},
      );

  _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    Scaffold.of(context).showSnackBar(SnackBar(
      elevation: 1,
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Copié dans le presse-papier 📋',
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    ));
  }
}
