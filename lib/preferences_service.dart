import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_linux_demo/nasa_apod_service.dart';

abstract class PreferencesService {
  bool isFavourite(NasaAPODEntry entry);

  Future<void> favourite(NasaAPODEntry entry, bool isFavourited);
}

class SharedPreferencesService implements PreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(
    this._prefs,
  );

  @override
  bool isFavourite(NasaAPODEntry entry) => _prefs.getBool(entry.date ?? '') ?? false;

  @override
  Future<void> favourite(NasaAPODEntry entry, bool isFavourited) async {
    final id = entry.date;
    if (id == null) {
      throw Exception("cannot persist favourite, missing entry date");
    }
    await _prefs.setBool(id, isFavourited);
  }
}
