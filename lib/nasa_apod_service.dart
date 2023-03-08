import 'dart:convert';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _apiAuthority = "api.nasa.gov";
const _apiEndPoint = "/planetary/apod";

class NasaAPODService {
  final String _apiKey;

  final _notifications = NotificationsClient();

  int _prevNotificationId = 1;

  NasaAPODService(this._apiKey);

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
  }

  Future<void> close() async {
    await _notifications.close();
    debugPrint("shutdown notification client");
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
