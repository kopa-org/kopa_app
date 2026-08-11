import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/services/secure_storage_service.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('setToken marks the app as authenticated before', () async {
    expect(await SecureStorageService.hasAuthenticatedBefore(), isFalse);

    await SecureStorageService.setToken('token');

    expect(await SecureStorageService.hasAuthenticatedBefore(), isTrue);
  });

  test('clearUserData keeps the authenticated-before flag', () async {
    await SecureStorageService.setToken('token');

    await SecureStorageService.clearUserData();

    expect(await SecureStorageService.getToken(), isNull);
    expect(await SecureStorageService.hasAuthenticatedBefore(), isTrue);
  });
}
