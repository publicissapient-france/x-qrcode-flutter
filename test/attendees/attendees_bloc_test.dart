import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/attendees/attendees_bloc.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  AttendeesBloc attendeesBloc;
  MockApiService apiService;

  setUp(() {
    apiService = MockApiService();
    attendeesBloc = AttendeesBloc(apiService: apiService);
  });

  tearDown(() {
    attendeesBloc.dispose();
  });

  group('Attendees', () {
    test('should load attendees', () {
      final attendees = [
        Attendee('1', 'John', 'Doe', 'jd@email.com', false, null),
      ];
      when(apiService.getAttendees()).thenAnswer((_) {
        return Future.value(attendees);
      });

      attendeesBloc.loadAttendees();

      expectLater(attendeesBloc.attendeesStream, emitsInOrder([attendees]));
    });

    test('should search attendees', () async {
      var john = Attendee('1', 'John', 'Doe', 'jd@email.com', false, null);
      final attendees = [
        john,
        Attendee('2', 'Oliver', 'Queen', 'oq@email.com', false, null),
      ];
      when(apiService.getAttendees()).thenAnswer((_) {
        return Future.value(attendees);
      });

      attendeesBloc.loadAttendees();
      var stream = attendeesBloc.attendeesStream.asBroadcastStream();
      await expectLater(stream, emitsInOrder([attendees]));

      attendeesBloc.searchAttendees('jo');

      expectLater(
          stream,
          emitsInOrder([
            [john]
          ]));
    });

    test('should toggle check', () async {
      final john = Attendee('1', 'John', 'Doe', 'jd@email.com', false, null);
      final queen =
          Attendee('2', 'Oliver', 'Queen', 'oq@email.com', false, null);
      final attendees = [
        john,
        queen,
      ];
      when(apiService.getAttendees()).thenAnswer((_) {
        return Future.value(attendees);
      });

      attendeesBloc.loadAttendees();
      var stream = attendeesBloc.attendeesStream.asBroadcastStream();
      await expectLater(stream, emitsInOrder([attendees]));

      attendeesBloc.toggleCheck('1', true);

      expectLater(
          stream,
          emitsInOrder([
            [
              Attendee('1', 'John', 'Doe', 'jd@email.com', true, null),
              queen,
            ]
          ]));

      expectLater(attendeesBloc.eventsStream,
          emitsInOrder([AttendeesEvents.toggleSuccess]));
    });
  });
}
