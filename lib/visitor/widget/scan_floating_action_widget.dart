import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class ScanFloatingActionButton extends StatelessWidget {
  const ScanFloatingActionButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final onPressed;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        elevation: 0,
        backgroundColor: Color(PRIMARY_COLOR),
        onPressed: () => onPressed(context),
        child: Icon(Icons.crop_free),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white, width: 4),
            borderRadius: BorderRadius.circular(45)),
      );
}
