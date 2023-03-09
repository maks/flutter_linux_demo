import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/apod_home_screen.dart';
import 'package:flutter_linux_demo/nasa_api_service.dart';
import 'package:flutter_linux_demo/nasa_apod_service.dart';
import 'package:flutter_linux_demo/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// comes from a `--dart-define=API_KEY=my-nasa-api-key` when building this app
// a global for now but really needs to be in a Provider
const _apiKey = String.fromEnvironment("API_KEY", defaultValue: "DEMO_KEY");

late final NasaAPODService apodService;

late final PreferencesService prefsService;

void main() async {
  debugPrint(("using API KEY: $_apiKey"));
  final apiService = NasaApiService(_apiKey);

  WidgetsFlutterBinding.ensureInitialized();
  prefsService = SharedPreferencesService(await SharedPreferences.getInstance());
  apodService = NasaAPODService(prefsService, apiService);

  runApp(const NasaAPODApp());

  apodService.close();
}

class NasaAPODApp extends StatelessWidget {
  const NasaAPODApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA APOD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ApodHomeScreen(title: 'NASA APOD'),
    );
  }
}
