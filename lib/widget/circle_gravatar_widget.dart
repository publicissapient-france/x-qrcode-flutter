import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

const COLORS = [
  0xFFFE414D,
  0xFF5675EE,
  0xFF8B45AC,
  0xFFE67E22,
  0xFFB32429,
  0xFF94C022,
];

class CircleGravatar extends StatefulWidget {
  final String uid;
  final String placeholder;
  final double radius;

  const CircleGravatar({
    Key key,
    this.uid,
    this.placeholder,
    this.radius,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _CircleGravatarState(this.uid, this.placeholder, this.radius);
}

class _CircleGravatarState extends State<CircleGravatar> {
  final String url;
  final String placeholder;
  final double radius;

  NetworkImage _networkImage;
  bool _loading = true;

  _CircleGravatarState(this.url, this.placeholder, this.radius) {
    _networkImage = NetworkImage(
        'https://www.gravatar.com/avatar/${md5.convert(utf8.encode(this.url)).toString()}?d=404');
  }

  @override
  void initState() {
    _networkImage
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        }, onError: (_, __) {
          // Do nothing when image is not found, placeholder will be use instead.
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? CircleAvatar(
          backgroundColor: Color(COLORS[url.hashCode % COLORS.length]),
          child: Text(
            placeholder,
            style: TextStyle(color: Colors.white),
          ),
          radius: this.radius,
        )
      : CircleAvatar(
          backgroundImage: _networkImage,
          radius: this.radius,
        );
}
