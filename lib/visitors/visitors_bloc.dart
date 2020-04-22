import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

enum VisitorsEvents {
  scanSuccessExists,
  scanSuccess,
}

class Event {
  final VisitorsEvents type;

  Event(this.type);
}

class VisitorEvent extends Event {
  final String id;

  VisitorEvent(VisitorsEvents type, this.id) : super(type);
}

class VisitorsBloc implements Bloc {
  final ApiService apiService;

  final _visitorsController = StreamController<Map<String, List<Attendee>>>();

  final _eventsController = StreamController<VisitorEvent>();

  List<Attendee> _visitors;

  VisitorsBloc({@required this.apiService});

  Stream<Map<String, List<Attendee>>> get visitorsStream =>
      _visitorsController.stream;

  Stream<VisitorEvent> get eventsStream => _eventsController.stream;

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
    _eventsController.close();
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

  void onVisitorScan(id) {
    if (_visitors.where((v) => v.id == id).isEmpty) {
      _eventsController.sink.add(VisitorEvent(
        VisitorsEvents.scanSuccess,
        id,
      ));
    } else {
      _eventsController.sink.add(VisitorEvent(
        VisitorsEvents.scanSuccessExists,
        id,
      ));
    }
  }
}
