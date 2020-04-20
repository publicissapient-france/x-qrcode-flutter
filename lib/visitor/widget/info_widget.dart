import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  final String info;
  final Widget icon;
  final bool first;

  InfoWidget(this.info, this.icon, {this.first: false});

  @override
  Widget build(BuildContext context) => Card(
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
      );
}
