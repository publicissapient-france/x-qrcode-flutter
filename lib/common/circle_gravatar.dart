import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

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
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? CircleAvatar(
          child: Text(placeholder),
          radius: this.radius,
        )
      : CircleAvatar(
          backgroundImage: _networkImage,
          radius: this.radius,
        );
}
