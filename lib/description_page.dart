// import 'dart:io'; // pick this

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  String status = 'Preparing...';

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
          status = 'Image successfully processed.';
          result = response.body;
        });
      } else if (response.statusCode == 202) {
        setState(() {
          status = 'Image accepted for processing. Waiting for result.';
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.file(widget.image!),
                        const SizedBox(height: 60),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              descriptionContents(status),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ]),
                ),
              ),
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                              colorScheme.primaryContainer),
                        ),
                        onPressed: () {},
                        child: const SizedBox(
                            height: 50, child: Center(child: Text('Save'))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(colorScheme.onError),
                        ),
                        onPressed: () {},
                        child: SizedBox(
                            height: 50,
                            child: Center(
                                child: Text(
                              'Delete',
                              style: TextStyle(color: colorScheme.error),
                            ))),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Column descriptionContents(String status) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STATUS', style: TextStyle(fontSize: 12)),
        Text(status, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 35),
        const Text('RESULT', style: TextStyle(fontSize: 12)),
        Text(result, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 35),
        const Text('SERVER URL', style: TextStyle(fontSize: 12)),
        Text(urlText, style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}
