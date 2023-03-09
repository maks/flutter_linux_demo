import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/nasa_apod_service.dart';
import 'package:flutter_linux_demo/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// comes from a `--dart-define=API_KEY=my-nasa-api-key` when building this app
// a global for now but really needs to be in a Provider
const apiKey = String.fromEnvironment("API_KEY", defaultValue: "DEMO_KEY");

late final NasaAPODService apiService;

late final PreferencesService prefsService;

void main() async {
  debugPrint(("using API KEY: $apiKey"));

  WidgetsFlutterBinding.ensureInitialized();
  prefsService = SharedPreferencesService(await SharedPreferences.getInstance());
  apiService = NasaAPODService(apiKey, prefsService);

  runApp(const MyApp());

  apiService.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA APOD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NASA APOD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<NasaAPODEntry>>(
                future: apiService.fetchEntries(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<NasaAPODEntry> entries = snapshot.data!;
                    
                    return Expanded(
                      child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              title: Text(entries[i].title ?? ""),
                              subtitle: Text(entries[i].date ?? ""),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => APODDetails(
                                    entry: entries[i],
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class APODDetails extends StatefulWidget {
  final NasaAPODEntry entry;

  const APODDetails({
    super.key,
    required this.entry,
  });

  @override
  State<APODDetails> createState() => _APODDetailsState();
}

class _APODDetailsState extends State<APODDetails> {
  late bool isFavourited;

  @override
  void initState() {
    super.initState();
    isFavourited = prefsService.isFavourite(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.entry.title ?? ""),
      ),
        body: Stack(
          children: [
            Image.network(
              widget.entry.url ?? "",
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  isFavourited ? Icons.star_outlined : Icons.star_border,
                  color: Colors.amberAccent,
                ),
                onPressed: () async {
                  debugPrint("fav: ${widget.entry.title}");
                  await apiService.favourite(widget.entry, !isFavourited);
                  setState(() {
                    isFavourited = !isFavourited;
                  });
                },
              ),
            ),
          ],
        ));
  }
}
