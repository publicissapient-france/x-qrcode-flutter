import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

enum AttendeesEventType {
  checkInSuccess,
  checkInError,
}

class AttendeesEvent {
  final AttendeesEventType type;
  final String id;

  AttendeesEvent(this.type, this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AttendeesEvent &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              id == other.id;

  @override
  int get hashCode => type.hashCode ^ id.hashCode;
}

class AttendeesBloc implements Bloc {
  final ApiService apiService;

  final _attendeesController = StreamController<Map<String, List<Attendee>>>();

  final _eventsController = StreamController<AttendeesEvent>();

  num get checked => _attendeesCheckCount;

  num get count => _attendeesCount;

  List<Attendee> _attendees;
  num _attendeesCheckCount;
  num _attendeesCount;
  String _query = '';

  AttendeesBloc({@required this.apiService});

  Stream<Map<String, List<Attendee>>> get attendeesStream =>
      _attendeesController.stream;

  Stream<AttendeesEvent> get eventsStream => _eventsController.stream;

  List<Attendee> get attendees => _attendees;

  void loadAttendees() async {
    _attendees = await apiService.getAttendees();

    _attendeesCheckCount = _attendees
        .where((a) => a.checkIn)
        .length;
    _attendeesCount = _attendees.length;

    searchAttendees(_query);
  }

  void searchAttendees(String query) {
    _query = query;
    _attendeesController.sink.add(_groupAttendeesByFirstChar((_attendees
        .where((a) => a.firstName.toLowerCase().contains(query))
        .toList())));
  }

  void toggleCheck(String rawContent, bool check,
      {bool fromCamera = true}) async {
    String id = _extractId(rawContent);
    try {
      final response = await apiService.toggleCheck(id, check);

      _attendees = _attendees.map((a) {
        if (a.id == response.id) {
          return a.copy(check: check);
        }
        return a;
      }).toList();

      _attendeesCheckCount += check ? 1 : -1;

      _attendeesController.sink.add(_groupAttendeesByFirstChar(_attendees));

      if (fromCamera) {
        _eventsController.sink.add(
          AttendeesEvent(
            AttendeesEventType.checkInSuccess,
            response.id,
          ),
        );
      }
    } catch (_) {
      if (fromCamera) {
        _eventsController.sink.add(
          AttendeesEvent(
            AttendeesEventType.checkInError,
            id,
          ),
        );
      }
    }
  }


  String _extractId(String rawContent) {
    const ATTENDEE_ID = 'attendee_id';
    var id = rawContent;
    if (rawContent.contains(ATTENDEE_ID)) {
      id = jsonDecode(rawContent)[ATTENDEE_ID];
    }
    return id;
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
