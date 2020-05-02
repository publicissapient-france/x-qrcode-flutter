import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const scanErrorRoute = '/scan_error';

class ScanErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Color(0xFFFF1F44),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 152,
          ),
        ),
      );
}
