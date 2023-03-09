import 'package:flutter/material.dart';
import 'package:flutter_linux_demo/preferences_service.dart';

import 'main.dart';
import 'nasa_apod_service.dart';

class APODDetailsScreen extends StatefulWidget {
  final NasaAPODEntry entry;
  final PreferencesService prefsService;

  const APODDetailsScreen({
    super.key,
    required this.entry,
    required this.prefsService,   
  });

  @override
  State<APODDetailsScreen> createState() => _APODDetailsScreenState();
}

class _APODDetailsScreenState extends State<APODDetailsScreen> {
  late bool isFavourited;

  @override
  void initState() {
    super.initState();
    isFavourited = widget.prefsService.isFavourite(widget.entry);
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
                  await apodService.favourite(widget.entry, !isFavourited);
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
