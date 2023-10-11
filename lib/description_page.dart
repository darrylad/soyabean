// import 'dart:io'; // pick this

import 'dart:io';

import 'package:flutter/material.dart';

class DescriptionPage extends StatelessWidget {
  final File? image;
  const DescriptionPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          title: Text(
            'Description',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.w600),
          ),
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
                  Image.file(image!),
                ]),
          ),
        ));
  }
}
