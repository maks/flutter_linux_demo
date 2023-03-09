import 'package:flutter_linux_demo/nasa_apod_service.dart';
import 'package:flutter_linux_demo/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  test('NasaAPODService favourites count is 0 when no entries have been fetched', () async {
    final mockPrefsService = MockPreferencesService();

    final subject = NasaAPODService("", mockPrefsService);

    expect(0, await subject.favouritesCount);
  });
}

class MockPreferencesService extends Mock implements PreferencesService {}
