import 'package:flutter/material.dart';

import 'apod_details_screen.dart';
import 'main.dart';
import 'nasa_apod_service.dart';

class ApodHomeScreen extends StatefulWidget {
  const ApodHomeScreen({super.key, required this.title});

  final String title;

  @override
  State<ApodHomeScreen> createState() => _ApodHomeScreenState();
}

class _ApodHomeScreenState extends State<ApodHomeScreen> {
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
                future: apodService.fetchEntries(),
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
                                  builder: (context) => APODDetailsScreen(
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
