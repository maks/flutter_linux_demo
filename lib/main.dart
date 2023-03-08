import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/nasa_apod_service.dart';

// comes from a `--dart-define=API_KEY=my-nasa-api-key` when building this app
// a global for now but really needs to be in a Provider
const apiKey = String.fromEnvironment("API_KEY", defaultValue: "DEMO_KEY");

void main() {
  debugPrint(("using API KEY: $apiKey"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
                future: NasaAPODService(apiKey).fetchEntries(),
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
                                  builder: (context) => APODDetails(entry: entries[i]),
                                ),
                              ),
                            );
                          }),
                    );
                  } else if (snapshot.hasError) {
                    debugPrint("err: ${snapshot.error}");
                  }
                  return Container();
                }),
          ],
        ),
      ),
    );
  }
}

class APODDetails extends StatelessWidget {
  final NasaAPODEntry entry;

  const APODDetails({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title ?? ""),
      ),
      body: Stack(
        children: [
          Text(entry.title ?? ""),
          Image.network(
            entry.url ?? "",
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}
