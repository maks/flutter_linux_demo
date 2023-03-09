import 'dart:convert';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:launcher_entry/launcher_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _apiAuthority = "api.nasa.gov";
const _apiEndPoint = "/planetary/apod";

class NasaAPODService {
  final String _apiKey;
  final _notifications = NotificationsClient();
  final PreferencesService _prefsService;

  int _prevNotificationId = 0;
  List<NasaAPODEntry>? _entriesCache;

  Future<int> get favouritesCount async {
    if (_entriesCache == null) {
      return 0;
    }
    return _entriesCache!.where((e) => _prefsService.isFavourite(e)).toList().length;
  }

  NasaAPODService(this._apiKey, this._prefsService);

  Future<List<NasaAPODEntry>> fetchEntries() async {
    final startDate = DateTime.now().subtract(const Duration(days: 4)); // 5 most recent images
    final dateStr = "${startDate.year}-${startDate.month}-${startDate.day}";
    final queryParameters = {
      "api_key": _apiKey,
      "start_date": dateStr,
    };

    final response = await http.get(Uri.https(_apiAuthority, _apiEndPoint, queryParameters));

    if (response.statusCode == 200) {
      final entries = jsonDecode(response.body) as List;

      final list = entries.map((e) => NasaAPODEntry.fromMap(e)).toList();
      _entriesCache = list;
      
      return list;
    } else {
      throw Exception('Failed to load APOD data: ${response.statusCode}:${response.reasonPhrase}');
    }
  }

  Future<void> favourite(NasaAPODEntry entry, bool favourite) async {
    final action = favourite == false ? "UnFavourited" : "Favourited";
    final n = await _notifications.notify(
      '$action: ${entry.title}',
      appName: 'NASA APOD',
      expireTimeoutMs: 3000,
      replacesId: _prevNotificationId,
    );
    // save id as we want to replace each notification with any future ones
    _prevNotificationId = n.id;

    // now persist to local data
    final prefs = await SharedPreferences.getInstance();
    final id = entry.date;
    if (id == null) {
      throw Exception("cannot persist favourite, missing entry date");
    }
    await prefs.setBool(id, favourite);

    final count = await favouritesCount;
    _updateLauncherBadge(count);
  }

  Future<void> close() async {
    await _notifications.close();
    debugPrint("shutdown notification client");
  }


  void _updateLauncherBadge(int count) {
    // For use with Snap need to use Snap .desktop file naming convention and override the
    // object path because default object path created by `LauncherEntryService` class creates
    // a negative number suffix which doesn't pass the apparmor rule used by Snap
    final service = LauncherEntryService(
        appUri: 'application://flutter-linux-demo_flutter-linux-demo.desktop',
        objectPath: "/com/canonical/unity/launcherentry/1");

    service.update(
      count: count,
      countVisible: true,
      progress: 0,
      progressVisible: false,
      urgent: true,
    );
  }
}

class NasaAPODEntry {
  String? date;
  String? title;
  String? url;
  String? copyright;
  String? explanation;

  NasaAPODEntry({
    required this.date,
    required this.title,
    required this.url,
    required this.copyright,
    required this.explanation,
  });

  factory NasaAPODEntry.fromMap(Map<String, dynamic> map) {
    return NasaAPODEntry(
      date: map['date'] as String?,
      title: map['title'] as String?,
      url: map['url'] as String?,
      copyright: map['copyright'] as String?,
      explanation: map['explanation'] as String?,
    );
  }

  factory NasaAPODEntry.fromJson(String source) => NasaAPODEntry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => "[$date] $title";
}
