import 'package:flutter_linux_demo/nasa_api_service.dart';
import 'package:flutter_linux_demo/preferences_service.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferencesService extends Mock implements PreferencesService {}

class MockNasaApiService extends Mock implements NasaApiService {}
