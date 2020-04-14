import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';
import 'package:x_qrcode/visitors/visitors_bloc.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  VisitorsBloc visitorsBloc;
  MockApiService apiService;

  setUp(() {
    apiService = MockApiService();
    visitorsBloc = VisitorsBloc(apiService: apiService);
  });

  tearDown(() {
    visitorsBloc.dispose();
  });

  group('Visitors', () {
    test('should load visitors', () {
      final attendees = [
        Attendee('1', 'John', 'Doe', 'jd@email.com', false, null),
      ];
      when(apiService.getVisitors()).thenAnswer((_) {
        return Future.value(attendees);
      });

      visitorsBloc.loadVisitors();

      expectLater(
        visitorsBloc.visitorsStream,
        emitsInOrder([attendees]),
      );
    });

    test('should search visitor', () async {
      var john = Attendee('1', 'John', 'Doe', 'jd@email.com', false, null);
      final attendees = [
        john,
        Attendee('2', 'Oliver', 'Queen', 'oq@email.com', false, null),
      ];
      when(apiService.getVisitors()).thenAnswer((_) {
        return Future.value(attendees);
      });

      visitorsBloc.loadVisitors();

      var stream = visitorsBloc.visitorsStream;

      await expectLater(
        stream,
        emitsInOrder([attendees]),
      );

      visitorsBloc.searchVisitor('jo');

      expectLater(
        stream,
        emitsInOrder([
          [john],
        ]),
      );
    });
  });
}
