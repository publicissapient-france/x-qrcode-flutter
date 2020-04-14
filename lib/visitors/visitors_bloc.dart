import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/common/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

class VisitorsBloc implements Bloc {
  final ApiService apiService;

  final _visitorsController = StreamController<List<Attendee>>();

  List<Attendee> _visitors;

  VisitorsBloc({@required this.apiService});

  Stream<List<Attendee>> get visitorsStream => _visitorsController.stream;

  void loadVisitors() async {
    _visitors = await apiService.getVisitors();
    _visitorsController.sink.add(_visitors);
  }

  void searchVisitor(String query) {
    _visitorsController.sink.add(_visitors
        .where((v) => v.firstName.toLowerCase().contains(query))
        .toList());
  }

  @override
  void dispose() {
    _visitorsController.close();
  }
}
