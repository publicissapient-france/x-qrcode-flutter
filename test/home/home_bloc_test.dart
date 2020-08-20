import 'package:flutter_auth0/flutter_auth0.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/constants.dart';
import 'package:x_qrcode/home/home_bloc.dart';

class MockApiService extends Mock implements ApiService {}

class MockStorage extends Mock implements FlutterSecureStorage {}

class MockAuth0Auth extends Mock implements Auth0Auth {}

class MockAuth0 extends Mock implements Auth0 {
  final mockAuth0Auth;

  MockAuth0(this.mockAuth0Auth);

  @override
  Auth0Auth get auth => mockAuth0Auth;
}

void main() {
  HomeBloc homeBloc;

  MockApiService apiService;
  MockStorage storage;
  MockAuth0 auth0;
  MockAuth0Auth auth0auth;

  setUp(() {
    apiService = MockApiService();
    storage = MockStorage();
    auth0auth = MockAuth0Auth();
    auth0 = MockAuth0(auth0auth);
    homeBloc = HomeBloc(apiService, storage, auth0);
  });

  tearDown(() {
    homeBloc.dispose();
  });

  group('Home', () {
    test('should login when token does not exist', () {
      when(storage.read(key: STORAGE_KEY_USER)).thenReturn(null);

      homeBloc.getAppropriateHome();

      expectLater(homeBloc.home, emitsInOrder([HOMES.LOGIN]));
    });

    test('should refresh token when it expires', () async {
      when(storage.read(key: STORAGE_KEY_TOKEN_EXPIRES_IN)).thenAnswer((_) =>
          Future.value(
              DateTime.now().subtract(Duration(minutes: 5)).toIso8601String()));
      when(storage.read(key: STORAGE_KEY_REFRESH_TOKEN))
          .thenAnswer((_) => Future.value('refresh_token'));
      when(auth0auth.refreshToken({'refreshToken': 'refresh_token'}))
          .thenAnswer(
              (_) => Future.value({'access_token': 'at', 'expires_in': 0}));
      when(storage.read(key: STORAGE_KEY_ACCESS_TOKEN))
          .thenAnswer((realInvocation) => Future.value('at'));
      when(storage.read(key: STORAGE_KEY_USER))
          .thenAnswer((_) => Future.value('user'));

      homeBloc.getAppropriateHome();

      await untilCalled(
          auth0auth.refreshToken({'refreshToken': 'refresh_token'}));
      await untilCalled(
          storage.write(key: STORAGE_KEY_ACCESS_TOKEN, value: 'at'));
      await untilCalled(storage.read(key: STORAGE_KEY_ACCESS_TOKEN));

      expectLater(homeBloc.home, emitsInOrder([HOMES.EVENTS]));
    });

    test('should not refresh token when it is not expired', () async {
      when(storage.read(key: STORAGE_KEY_TOKEN_EXPIRES_IN)).thenAnswer((_) =>
          Future.value(
              DateTime.now().add(Duration(minutes: 5)).toIso8601String()));
      when(storage.read(key: STORAGE_KEY_ACCESS_TOKEN))
          .thenAnswer((realInvocation) => Future.value('at'));

      homeBloc.getAppropriateHome();

      await untilCalled(storage.read(key: STORAGE_KEY_ACCESS_TOKEN));

      expectLater(homeBloc.home, emitsInOrder([HOMES.ORGANIZATIONS]));
    });

    test('should disconnect user if refresh token fails', () async {
      when(storage.read(key: STORAGE_KEY_TOKEN_EXPIRES_IN)).thenAnswer((_) =>
          Future.value(
              DateTime.now().subtract(Duration(minutes: 5)).toIso8601String()));
      when(storage.read(key: STORAGE_KEY_REFRESH_TOKEN))
          .thenAnswer((_) => Future.value('refresh_token'));
      when(auth0auth.refreshToken({'refreshToken': 'refresh_token'}))
          .thenThrow((_) => {});

      homeBloc.getAppropriateHome();

      await untilCalled(
          auth0auth.refreshToken({'refreshToken': 'refresh_token'}));
      await untilCalled(storage.deleteAll());
      await untilCalled(storage.read(key: STORAGE_KEY_ACCESS_TOKEN));

      expectLater(homeBloc.home, emitsInOrder([HOMES.LOGIN]));
    });
  });
}
