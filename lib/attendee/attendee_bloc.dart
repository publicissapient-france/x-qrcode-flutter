import 'dart:async';

import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/bloc/bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

class AttendeeBloc extends Bloc {
  final ApiService apiService;

  Attendee _attendee;

  final _attendeeController = StreamController<Attendee>();

  Stream<Attendee> get attendeeStream => _attendeeController.stream;

  AttendeeBloc(this.apiService, this._attendee) {
    _attendeeController.sink.add(_attendee);
  }

  void checkIn() async {
    final response = await apiService.toggleCheck(_attendee.id, !_attendee.checkIn);
    _attendee = _attendee.copy(check: response.check);
    _attendeeController.sink.add(_attendee);
  }

  @override
  void dispose() {
    _attendeeController.close();
  }
}
