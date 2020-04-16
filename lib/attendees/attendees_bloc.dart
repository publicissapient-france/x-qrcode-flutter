import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/common/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

enum AttendeesEvents {
  toggleSuccess,
}

class AttendeesBloc implements Bloc {
  final ApiService apiService;

  final _attendeesController = StreamController<List<Attendee>>();

  final _eventsController = StreamController<AttendeesEvents>();

  List<Attendee> _attendees;

  AttendeesBloc({@required this.apiService});

  Stream<List<Attendee>> get attendeesStream => _attendeesController.stream;

  Stream<AttendeesEvents> get eventsStream => _eventsController.stream;

  void loadAttendees() async {
    _attendees = await apiService.getAttendees();
    _attendeesController.sink.add(_attendees);
  }

  void searchAttendees(String query) {
    _attendeesController.sink.add(_attendees
        .where((a) => a.firstName.toLowerCase().contains(query))
        .toList());
  }

  void toggleCheck(String id, bool check, {bool fromCamera = true}) async {
    await apiService.toggleCheck(id, check);
    _attendees = _attendees.map((a) {
      if (a.id == id) {
        return a.copy(check: check);
      }
      return a;
    }).toList();
    _attendeesController.sink.add(_attendees);
    if (fromCamera) {
      _eventsController.sink.add(AttendeesEvents.toggleSuccess);
    }
  }

  @override
  void dispose() {
    _attendeesController.close();
    _eventsController.close();
  }
}
