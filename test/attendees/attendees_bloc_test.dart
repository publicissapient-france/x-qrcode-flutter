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
      final john = Attendee('1', 'John', 'Doe', 'jd@email.com', false, null);
      when(apiService.getAttendees()).thenAnswer((_) => Future.value([john]));

      attendeesBloc.loadAttendees();

      expectLater(
          attendeesBloc.attendeesStream,
          emitsInOrder([
            {
              'j': [john]
            }
          ]));
    });

    test('should search attendees', () async {
      final john = Attendee('1', 'John', 'Doe', 'jd@email.com', false, null);
      var oliver =
          Attendee('2', 'Oliver', 'Queen', 'oq@email.com', false, null);
      when(apiService.getAttendees())
          .thenAnswer((_) => Future.value([john, oliver]));

      attendeesBloc.loadAttendees();
      var stream = attendeesBloc.attendeesStream.asBroadcastStream();
      await expectLater(
          stream,
          emitsInOrder([
            {
              'j': [john],
              'o': [oliver]
            }
          ]));

      attendeesBloc.searchAttendees('jo');

      expectLater(
          stream,
          emitsInOrder([
            {
              'j': [john]
            }
          ]));
    });

    test('should toggle check', () async {
      final john = Attendee('1', 'John', 'Doe', 'jd@email.com', false, null);
      final oliver =
          Attendee('2', 'Oliver', 'Queen', 'oq@email.com', false, null);
      when(apiService.getAttendees())
          .thenAnswer((_) => Future.value([john, oliver]));

      attendeesBloc.loadAttendees();
      var stream = attendeesBloc.attendeesStream.asBroadcastStream();
      await expectLater(
          stream,
          emitsInOrder([
            {
              'j': [john],
              'o': [oliver]
            }
          ]));

      attendeesBloc.toggleCheck('1', true);

      expectLater(
          stream,
          emitsInOrder([
            {
              'j': [Attendee('1', 'John', 'Doe', 'jd@email.com', true, null)],
              'o': [oliver]
            },
          ]));

      expectLater(attendeesBloc.eventsStream,
          emitsInOrder([AttendeesEvents.toggleSuccess]));
    });
  });
}
