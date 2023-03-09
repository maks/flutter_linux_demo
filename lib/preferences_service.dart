import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_linux_demo/nasa_apod_service.dart';

abstract class PreferencesService {
  bool isFavourite(NasaAPODEntry entry);

  void favourite(NasaAPODEntry entry, bool isFavourited);
}

class SharedPreferencesService implements PreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(
    this._prefs,
  );

  @override
  bool isFavourite(NasaAPODEntry entry) => _prefs.getBool(entry.date ?? '') ?? false;

  @override
  void favourite(NasaAPODEntry entry, bool isFavourited) {
    _prefs.getBool(entry.date ?? '') ?? false;
  }
}
