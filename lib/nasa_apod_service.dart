import 'dart:convert';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/nasa_api_service.dart';
import 'package:flutter_linux_demo/preferences_service.dart';

import 'package:launcher_entry/launcher_entry.dart';

class NasaAPODService {
  final _notifications = NotificationsClient();
  final PreferencesService _prefsService;
  final NasaApiService _apiService;

  int _prevNotificationId = 0;
  List<NasaAPODEntry>? _entriesCache;

  Future<int> get favouritesCount async {
    if (_entriesCache == null) {
      return 0;
    }
    return _entriesCache!.where((e) => _prefsService.isFavourite(e)).toList().length;
  }

  NasaAPODService(this._prefsService, this._apiService);

  Future<List<NasaAPODEntry>> fetchEntries() async {
    final startDate = DateTime.now().subtract(const Duration(days: 4)); // 5 most recent images

    final responseText = await _apiService.getAPODList(startDate);
    final entries = jsonDecode(responseText) as List;

    final list = entries.map((e) => NasaAPODEntry.fromMap(e)).toList();
    _entriesCache = list;

    return list;
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
    _prefsService.favourite(entry, favourite);

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
