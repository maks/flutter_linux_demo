import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/apod_details_screen.dart';
import 'package:flutter_linux_demo/nasa_apod_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'image_mock_http_client.dart';
import 'mocks.dart';

void main() {
  const imageUrl = 'https://test.com/test.jpg';

  setUpAll(() async {
    registerFallbackValue(NasaAPODEntry.fromMap({}));

    // for Images from network
    registerFallbackValue(Uri());
    // Load an image from assets and transform it from bytes to List<int>
    final imageByteData = File('test/image.png').readAsBytesSync();
    final imageIntList = imageByteData.buffer.asInt8List();

    final requestsMap = {
      Uri.parse(imageUrl): imageIntList,
    };

    HttpOverrides.global = MockHttpOverrides(requestsMap);
  });

  testWidgets('Details screen shows expected entry title', (WidgetTester tester) async {
    final fakeEntry = NasaAPODEntry(
      date: "2023-01-01",
      title: "A test image",
      url: imageUrl,
      copyright: "",
      explanation: "",
    );
    final mockPrefsService = MockPreferencesService();

    when(() => mockPrefsService.isFavourite(any())).thenReturn(true); // all entries are favourited
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: APODDetailsScreen(
          entry: fakeEntry,
          prefsService: mockPrefsService,
        ),
      ),
    );

    // Verify that we have expected text on screen
    expect(find.text('A test image'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Verify we have expected favourited star icon
    expect(find.byIcon(Icons.star_outlined), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNothing);
  });
}
