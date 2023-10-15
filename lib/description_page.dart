// import 'dart:io'; // pick this

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/main.dart';

class DescriptionPage extends StatefulWidget {
  final File? image;
  const DescriptionPage({super.key, required this.image});

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  String result = 'Result will be displayed here';
  late File? image;

  @override
  void initState() {
    super.initState();
    // (isDemoModeOn) ? null : processImage();
  }

  Future<void> processImage() async {
    // final imagePath =
    //     'path_to_your_image.jpg'; // Replace with the actual image path
    // final url =
    //     'http://your-matlab-service-url'; // Replace with your MATLAB service URL

    try {
      final response =
          await http.post(Uri.parse(urlText), body: {'image': image});

      if (response.statusCode == 200) {
        setState(() {
          result = 'Image successfully processed: ${response.body}';
        });
      } else if (response.statusCode == 202) {
        setState(() {
          result = 'Image accepted for processing. Check status later.';
        });
      } else {
        setState(() {
          result =
              'Failed to communicate with the MATLAB service. Status Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;
    String status = 'Preparing...';
    return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: (brightness == Brightness.light)
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor: (brightness == Brightness.light)
                ? colorScheme.background
                : colorScheme.background, // Navigation bar
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: (brightness == Brightness.light)
                ? Brightness.dark
                : Brightness.light, // Status bar
          ),
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          title: (isDemoModeOn)
              ? Text('Description Demo',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600))
              : Text('Description',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
          //  Text(
          //   'Description',
          //   style: TextStyle(
          //       color: colorScheme.onSurface, fontWeight: FontWeight.w600),
          // ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(widget.image!),
                  const SizedBox(height: 60),
                  Text('Status: $status'),
                  const SizedBox(height: 20),
                  Text(urlText),
                ]),
          ),
        ));
  }
}
