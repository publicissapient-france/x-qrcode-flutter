import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:x_qrcode/api/model/check_in_response.dart';
import 'package:x_qrcode/exception/checkin_exception.dart';

import 'package:x_qrcode/event/events_screen.dart';
import 'package:x_qrcode/organization/model/user_model.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

import '../constants.dart';

class ApiService {
  final storage = FlutterSecureStorage();

  Future<Attendee> getAttendee(String id, bool alreadyScanned) async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/${alreadyScanned ? 'visitors' : 'attendees'}/$id',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

    if (response.statusCode == 200) {
      Attendee attendee = Attendee.fromJson(jsonDecode(response.body));
      attendee.comments.sort((a, b) {
        if (a.date != null && b.date != null) {
          if (DateTime.parse(a.date).isBefore(DateTime.parse(b.date))) {
            return 1;
          }
        }
        return -1;
      });
      return attendee;
    } else {
      throw Exception('Cannot get attendee');
    }
  }

  Future<List<Attendee>> getAttendees() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/attendees',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

    if (response.statusCode == 200) {
      final rawAttendees = jsonDecode(response.body);
      final attendees = List<Attendee>();
      for (var rawEvent in rawAttendees) {
        attendees.add(Attendee.fromJson(rawEvent));
      }
      attendees.sort((a, b) => a.firstName.compareTo(b.firstName));
      return attendees;
    } else {
      throw Exception('Failed to load attendees');
    }
  }

  Future<List<Attendee>> getVisitors() async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.get(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/visitors',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

    if (response.statusCode == 200) {
      final rawVisitors = jsonDecode(response.body);
      final visitors = List<Attendee>();
      for (var rawEvent in rawVisitors) {
        visitors.add(Attendee.fromJson(rawEvent));
      }
      visitors.sort((a, b) => a.firstName.compareTo(b.firstName));
      return visitors;
    } else {
      throw Exception('Failed to load visitors');
    }
  }

  Future<CheckInResponse> toggleCheck(String id, bool check) async {
    final user =
        User.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_USER)));
    final accessToken = await storage.read(key: STORAGE_KEY_ACCESS_TOKEN);
    final event =
        Event.fromJson(jsonDecode(await storage.read(key: STORAGE_KEY_EVENT)));

    final response = await http.patch(
        '${DotEnv().env[ENV_KEY_API_URL]}/${user.tenant}/events/${event.id}/attendees/$id',
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
        body: {'checked': '$check'});

    if (response.statusCode == 200) {
      return new CheckInResponse(
          jsonDecode(response.body)['attendee_id'], check);
    } else {
      throw CheckInException(
          'Cannot check-in attendee, status: ${response.statusCode}, message: ${response.body}');
    }
  }
}
