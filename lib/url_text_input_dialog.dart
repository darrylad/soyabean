import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/description_page.dart';
import 'package:soyabean/options_page.dart';
// import 'package:soyabean/main.dart';

class ShowUrlTextDialog extends StatefulWidget {
  final File? image;
  final BuildContext context;

  const ShowUrlTextDialog({
    super.key,
    required this.image,
    required this.context,
  });

  @override
  State<ShowUrlTextDialog> createState() => _ShowUrlTextDialogState();

  // Future<void> callDisplayTextInputDialog(image, context) async {
  //   final state = _ShowUrlTextDialogState();
  //   state.image = image;
  //   state.context = context;
  //   state._textFieldController = TextEditingController();
  //   await state.displayTextInputDialog(state.context, state.image);
  // }
}

class _ShowUrlTextDialogState extends State<ShowUrlTextDialog> {
  late File? image;

  @override
  late BuildContext context;
  // _ShowUrlTextDialogState(this.image);

  late TextEditingController _textFieldController;
  bool isUploadButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    image = widget.image;
    context = widget.context;

    _textFieldController = TextEditingController();
    // _textFieldController.text = urlText;
    _textFieldController.addListener(() {
      final isUploadButtonEnabled = _textFieldController.text.isNotEmpty;
      setState(() {
        this.isUploadButtonEnabled = isUploadButtonEnabled;
        // urlText = _textFieldController.text;
      });
    });
    loadUrlText();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textFieldController.dispose();
    super.dispose();
    // urlText = 'controller disposed';
  }

  void saveUrlText(String urlText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('urlText', urlText);
  }

  void loadUrlText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      urlText = prefs.getString('urlText') ?? 'https://example.com';
      _textFieldController.text = urlText;
    });
  }

  // Future<void> displayTextInputDialog(BuildContext context, File? image) async {
  //   var colorScheme = Theme.of(context).colorScheme;
  //   return showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return AlertDialog(
  //               title: Text('Enter Server URL',
  //                   style: TextStyle(color: colorScheme.onSurfaceVariant)),
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     onChanged: (value) {
  //                       // setState(() {});
  //                       setState(() {
  //                         isUploadButtonEnabled = value.isNotEmpty;
  //                       });
  //                     },
  //                     controller: _textFieldController,
  //                     decoration: const InputDecoration(
  //                         hintText: "http://your-matlab-server-ip:3000"),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   Text(urlText),
  //                 ],
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('CANCEL'),
  //                 ),
  //                 TextButton(
  //                   onPressed: isUploadButtonEnabled
  //                       ? () {
  //                           setState(() {
  //                             urlText = _textFieldController.text;
  //                           });
  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       DescriptionPage(image: image)));
  //                         }
  //                       : null,
  //                   child: const Text('UPLOAD'),
  //                 ),
  //               ],
  //             );
  //           },
  //           // child: enterServerUrlAlertBox(colorScheme, context, image),
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: colorScheme.onSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // return originalAlertBox1(colorScheme, context);

    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.onSurface
          : colorScheme.background,
      body: originalAlertBox1(colorScheme, context),
    );
  }

  AlertDialog originalAlertBox1(ColorScheme colorScheme, BuildContext context) {
    return AlertDialog(
      title: Text('Enter Server URL',
          style: TextStyle(color: colorScheme.onSurfaceVariant)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {});
              // setState(() {
              //   urlText = value;
              // });
            },
            controller: _textFieldController,
            decoration: const InputDecoration(
                hintText: "http://your-matlab-server-ip:3000"),
          ),
          const SizedBox(height: 10),
          // Text(urlText),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ),
        TextButton(
          onPressed: isUploadButtonEnabled
              ? () {
                  setState(() {
                    urlText = _textFieldController.text;
                  });
                  saveUrlText(urlText);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DescriptionPage(image: image)));
                }
              : null,
          child: Text(uploadText),
        ),
      ],
    );
  }
}

class SaveUrlDialog extends StatefulWidget {
  const SaveUrlDialog({
    super.key,
  });

  @override
  State<SaveUrlDialog> createState() => _SaveUrlDialogState();

  // Future<void> callDisplayTextInputDialog(image, context) async {
  //   final state = _ShowUrlTextDialogState();
  //   state.image = image;
  //   state.context = context;
  //   state._textFieldController = TextEditingController();
  //   await state.displayTextInputDialog(state.context, state.image);
  // }
}

class _SaveUrlDialogState extends State<SaveUrlDialog> {
  @override
  late BuildContext context;
  // _SaveUrlDialogState(this.image);

  late TextEditingController _textFieldController;
  bool isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _textFieldController = TextEditingController();
    // _textFieldController.text = urlText;
    _textFieldController.addListener(() {
      final isSaveButtonEnabled = _textFieldController.text.isNotEmpty;
      setState(() {
        this.isSaveButtonEnabled = isSaveButtonEnabled;
        // urlText = _textFieldController.text;

        //hive
        // urlText = box.get('urlText') ?? 'https://example.com';
      });
    });
    loadUrlText();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textFieldController.dispose();
    super.dispose();
    // urlText = 'controller disposed';
  }

  void saveUrlText(String urlText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('urlText', urlText);
  }

  void loadUrlText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      urlText = prefs.getString('urlText') ?? 'https://example.com';
      _textFieldController.text = urlText;
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;

    // return originalAlertBox1(colorScheme, context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: colorScheme.onSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.onSurface
          : colorScheme.background,
      body: saveUrlTextAlert(colorScheme, context),
    );
  }

  AlertDialog saveUrlTextAlert(ColorScheme colorScheme, BuildContext context) {
    return AlertDialog(
      title: Text('Enter Server URL',
          style: TextStyle(color: colorScheme.onSurfaceVariant)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {});
              // setState(() {
              //   urlText = value;
              // });
            },
            controller: _textFieldController,
            decoration: const InputDecoration(
                hintText: "http://your-matlab-server-ip:3000"),
          ),
          const SizedBox(height: 10),
          // Text(urlText),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: isSaveButtonEnabled
              ? () {
                  setState(() {
                    urlText = _textFieldController.text;
                  });
                  saveUrlText(urlText);

                  // hive
                  // box.put('urlText', urlText);

                  Navigator.pop(context, urlText);
                }
              : null,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

Future<void> displayTextInputDialog(BuildContext context, File? image) async {
  final _textFieldController = TextEditingController();
  bool isUploadButtonEnabled = _textFieldController.text.isNotEmpty;
  var colorScheme = Theme.of(context).colorScheme;
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Server URL',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      // setState(() {});
                      setState(() {
                        isUploadButtonEnabled = value.isNotEmpty;
                      });
                    },
                    controller: _textFieldController,
                    decoration: const InputDecoration(
                        hintText: "http://your-matlab-server-ip:3000"),
                  ),
                  const SizedBox(height: 10),
                  Text(urlText),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _textFieldController.clear();
                    _textFieldController.dispose();
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: isUploadButtonEnabled
                      ? () {
                          setState(() {
                            urlText = _textFieldController.text;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DescriptionPage(image: image)));
                        }
                      : null,
                  child: const Text('UPLOAD'),
                ),
              ],
            );
          },
          // child: enterServerUrlAlertBox(colorScheme, context, image),
        );
      });
}
