import 'package:flutter_linux_demo/nasa_apod_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';
import 'nasa_api_test_data.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(NasaAPODEntry.fromMap({}));
  });

  test('NasaAPODService favourites count is 0 when no entries have been fetched', () async {
    final mockPrefsService = MockPreferencesService();
    final mockNasaApiService = MockNasaApiService();

    final subject = NasaAPODService(mockPrefsService, mockNasaApiService);

    expect(await subject.favouritesCount, 0);
  });

  test('NasaAPODService favourites count is 0 when 2 entries have been fetched but none favourited', () async {
    final mockPrefsService = MockPreferencesService();
    final mockNasaApiService = MockNasaApiService();

    when(() => mockNasaApiService.getAPODList(any())).thenAnswer((value) async => apiData1);

    final subject = NasaAPODService(mockPrefsService, mockNasaApiService);

    expect(await subject.favouritesCount, 0);
  });

  test('NasaAPODService favourites count is 1 when 2 entries have been fetched and 1 favourited', () async {
    final mockPrefsService = MockPreferencesService();
    final mockNasaApiService = MockNasaApiService();

    when(() => mockPrefsService.isFavourite(any())).thenReturn(true); // all entries are favourited
    when(() => mockNasaApiService.getAPODList(any())).thenAnswer((_) async => apiData1);

    final subject = NasaAPODService(mockPrefsService, mockNasaApiService);

    await subject.fetchEntries();

    expect(await subject.favouritesCount, 3);
  });
}
