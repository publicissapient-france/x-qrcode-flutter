import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

enum AttendeesEvents {
  checkInSuccess,
  checkInError,
}

class AttendeesBloc implements Bloc {
  final ApiService apiService;

  final _attendeesController = StreamController<Map<String, List<Attendee>>>();

  final _eventsController = StreamController<AttendeesEvents>();

  num get checked => _attendeesCheckCount;

  num get count => _attendeesCount;

  List<Attendee> _attendees;
  num _attendeesCheckCount;
  num _attendeesCount;
  String _query = '';

  AttendeesBloc({@required this.apiService});

  Stream<Map<String, List<Attendee>>> get attendeesStream =>
      _attendeesController.stream;

  Stream<AttendeesEvents> get eventsStream => _eventsController.stream;

  void loadAttendees() async {
    _attendees = await apiService.getAttendees();

    _attendeesCheckCount = _attendees.where((a) => a.checkIn).length;
    _attendeesCount = _attendees.length;

    searchAttendees(_query);
  }

  void searchAttendees(String query) {
    _query = query;
    _attendeesController.sink.add(_groupAttendeesByFirstChar((_attendees
        .where((a) => a.firstName.toLowerCase().contains(query))
        .toList())));
  }

  void toggleCheck(String id, bool check, {bool fromCamera = true}) async {
    try {
      await apiService.toggleCheck(id, check);

      _attendees = _attendees.map((a) {
        if (a.id == id) {
          return a.copy(check: check);
        }
        return a;
      }).toList();

      _attendeesCheckCount += check ? 1 : -1;

      _attendeesController.sink.add(_groupAttendeesByFirstChar(_attendees));

      if (fromCamera) {
        _eventsController.sink.add(AttendeesEvents.checkInSuccess);
      }
    } catch (_) {
      if (fromCamera) {
        _eventsController.sink.add(AttendeesEvents.checkInError);
      }
    }
  }

  @override
  void dispose() {
    _attendeesController.close();
    _eventsController.close();
  }

  Map<String, List<Attendee>> _groupAttendeesByFirstChar(
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
