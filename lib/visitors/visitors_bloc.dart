import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

class VisitorsBloc implements Bloc {
  final ApiService apiService;

  final _visitorsController = StreamController<Map<String, List<Attendee>>>();

  List<Attendee> _visitors;

  VisitorsBloc({@required this.apiService});

  Stream<Map<String, List<Attendee>>> get visitorsStream =>
      _visitorsController.stream;

  void loadVisitors() async {
    _visitors = await apiService.getVisitors();
    _visitorsController.sink.add(_groupVisitorsByFirstChar(_visitors));
  }

  void searchVisitors(String query) {
    _visitorsController.sink.add(_groupVisitorsByFirstChar(_visitors
        .where((v) => v.firstName.toLowerCase().contains(query))
        .toList()));
  }

  @override
  void dispose() {
    _visitorsController.close();
  }

  Map<String, List<Attendee>> _groupVisitorsByFirstChar(
      List<Attendee> attendees) {
    Map<String, List<Attendee>> attendeesGroupByFirstNameFirstChar =
        SplayTreeMap((a, b) => a.compareTo(b));
    attendees.forEach((attendee) {
      var firstNameFirstChar = '-';
      if (attendee.firstName != null && attendee.firstName.length > 0) {
        firstNameFirstChar = attendee.firstName.substring(0, 1).toLowerCase();
      }
      if (!attendeesGroupByFirstNameFirstChar.containsKey(firstNameFirstChar)) {
        attendeesGroupByFirstNameFirstChar[firstNameFirstChar] = List();
      }
      attendeesGroupByFirstNameFirstChar[firstNameFirstChar].add(attendee);
    });
    return attendeesGroupByFirstNameFirstChar;
  }
}
