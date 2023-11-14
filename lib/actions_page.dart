import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soyabean/camera_page.dart';
import 'package:soyabean/description_page.dart';
import 'package:soyabean/main.dart';
import 'package:soyabean/options_page.dart';
import 'package:soyabean/url_text_input_dialog.dart';
// import 'package:soyabean/main.dart';
// import 'package:soyabean/main.dart';

// Future<Widget?> cameraAvailabilityChecker(context) async {
//   List<CameraDescription> cameras = [];
//   cameras = await availableCameras();
//   // debugPrint(cameras.toString());
//   final firstCamera = cameras.first;

//   // final CameraController cameraController = CameraController(
//   //   firstCamera,
//   //   ResolutionPreset.medium, // You can change the resolution as needed
//   // );

//   // await cameraController.initialize();

//   // Now you can use the cameraController for further operations

//   if (cameras.isNotEmpty) {
//     return Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CameraPage()),
//     );
//   } else {
//     return null;
//   }
// }

// void cameraCheckerCaller(context) {
//   cameraAvailabilityChecker(context);
// }

// Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`
// WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
// final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
// final firstCamera = cameras.first;
// CameraDescription? firstCamera;
// Future<CameraDescription> initCamera() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   final firstCamera = cameras.first;
//   return firstCamera;
// }

// void callCamera() {
//   initCamera();
// }

Future<void> mainCam(context) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    (platformOS == 'Android' || platformOS == 'iOS')
        ? cameras = await availableCameras()
        : null;
  } on CameraException catch (e) {
    debugPrint('Error in fetching the cameras: $e');
  }
  // runApp(MyApp());
  // const CameraPage();
  Navigator.push(
    context,
    MaterialPageRoute(
        // builder: (context) => CameraPage(camera: firstCamera)),
        builder: (context) => const CameraPage()),
  );
}

String urlText = 'https://example.com';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsState();
}

class _ActionsState extends State<ActionsPage> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      _showImageDialog();
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Specify the file type as FileType.image
      allowMultiple: false, // Allow the selection of multiple images
    );

    if (result != null) {
      List<File> imageFiles = result.paths.map((path) => File(path!)).toList();
      // Do something with the selected image files (e.g., display them, upload, etc.)
      setState(() {
        _image = imageFiles[0];
      });
      _showImageDialog();
    }
  }

  late TextEditingController _textFieldController;
  bool isUploadButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _textFieldController = TextEditingController();

    _textFieldController.addListener(() {
      final isUploadButtonEnabled = _textFieldController.text.isNotEmpty;
      setState(() {
        this.isUploadButtonEnabled = isUploadButtonEnabled;
        // urlText = _textFieldController.text;
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, File? image) async {
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
                    Text(urlText),
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
                    onPressed: isUploadButtonEnabled
                        ? () {
                            setState(() {
                              urlText = _textFieldController.text;
                            });
                            Navigator.pushReplacement(
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

  AlertDialog enterServerUrlAlertBox(
      ColorScheme colorScheme, BuildContext context, File? image) {
    return AlertDialog(
      title: Text('Enter Server URL',
          style: TextStyle(color: colorScheme.onSurfaceVariant)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                urlText = value;
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
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: isUploadButtonEnabled
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DescriptionPage(image: image)));
                }
              : null,
          child: const Text('UPLOAD'),
        ),
      ],
    );
  }

  void _showImageDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.fromLTRB(1.0, 10, 1.0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                (isServerFeatureAvailable)
                    ? ((askForUrlEverytime)
                        ? const SizedBox(
                            height: 0,
                          )
                        : InkWell(
                            onLongPress: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowUrlTextDialog(
                                            image: _image,
                                            context: context,
                                          )));
                            },
                            child: SizedBox(
                                height: 30,
                                child: Center(child: Text('URL: $urlText')))))
                    : const SizedBox(
                        height: 0,
                      ),
                (imageCropping)
                    ? Container(
                        child: ListTile(
                          title: const Text('Image crop factor'),
                          // subtitle: const Text(
                          //     'Choose how much the image should be cropped'),
                          // trailing: const Icon(Icons.arrow_forward),
                          trailing: DropdownButton<double>(
                            value: croppMultiplyingFactor,
                            items: const [
                              DropdownMenuItem<double>(
                                value: 0.4,
                                child: Text('0.4'),
                              ),
                              DropdownMenuItem<double>(
                                value: 0.5,
                                child: Text('0.5'),
                              ),
                              DropdownMenuItem<double>(
                                value: 0.6,
                                child: Text('0.6'),
                              ),
                              DropdownMenuItem<double>(
                                value: 0.7,
                                child: Text('0.7'),
                              ),
                              DropdownMenuItem<double>(
                                value: 0.8,
                                child: Text('0.8'),
                              ),
                              DropdownMenuItem<double>(
                                value: 0.9,
                                child: Text('0.9'),
                              ),
                              DropdownMenuItem<double>(
                                value: 1.0,
                                child: Text('No Zoom (1.0)'),
                              ),
                            ],
                            onChanged: (double? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  croppMultiplyingFactor = newValue;
                                });
                              }
                            },
                          ),
                          // onTap: () {},
                        ),
                      )
                    : const Opacity(
                        opacity: 0.6,
                        child: SizedBox(
                          // height: 0,
                          child: Text('Image cropping is off'),
                        ),
                      ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.onPrimary),
                    elevation: MaterialStateProperty.all<double>(4),
                  ),
                  onPressed: () {
                    // _displayTextInputDialog(context, _image);   // in built method
                    (askForUrlEverytime)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowUrlTextDialog(
                                      image: _image,
                                      context: context,
                                    )))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DescriptionPage(image: _image)));
                  },
                  // child: (askForUrlEverytime)
                  //     ? const Text('Proceed')
                  //     : const Text('Upload'),
                  child: (isServerFeatureAvailable)
                      ? ((askForUrlEverytime)
                          ? const Text('Proceed')
                          : Text(uploadText))
                      : const Text('Run'),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.surfaceVariant
          : colorScheme.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: (brightness == Brightness.light)
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: (platformOS == 'Android')
              ? ((brightness == Brightness.light)
                  ? colorScheme.background
                  : colorScheme.surfaceVariant)
              : Colors.transparent, // Navigation bar
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: (brightness == Brightness.light)
              ? Brightness.dark
              : Brightness.light,
          statusBarBrightness: (brightness == Brightness.light)
              ? Brightness.dark
              : Brightness.light,
        ),
        backgroundColor: (brightness == Brightness.light)
            ? colorScheme.surfaceVariant
            : colorScheme.background,
        title: (isDemoModeOn)
            ? Text('Soyabean Demo',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600))
            : Text('Soyabean',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                choosePhotoButton(colorScheme),
                const SizedBox(height: 60),
                takePhotoButton(colorScheme),
                // _image != null
                //     ? Image.file(_image!)
                //     : const Text('No image selected'),
              ]),
        ),
      ),
    );
  }

  FilledButton takePhotoButton(ColorScheme colorScheme) {
    return FilledButton(
      style: ButtonStyle(
        // backgroundColor: MaterialStateProperty.all<Color>(colorScheme.primary),
        // foregroundColor: MaterialStateProperty.all<Color>(colorScheme.onPrimary),
        elevation:
            areCamerasAvailable ? MaterialStateProperty.all<double>(4) : null,
        iconSize: MaterialStateProperty.all<double>(100),
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.fromLTRB(40, 20, 40, 20)),
        // textStyle: MaterialStateProperty.all<TextStyle>(
        //     TextStyle(fontSize: 20)),
      ),
      onPressed: areCamerasAvailable
          ? () {
              // initCamera();
              mainCam(context);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       // builder: (context) => CameraPage(camera: firstCamera)),
              //       builder: (context) => const CameraPage()),
              // );
            }
          : null,
      child: const Column(
        children: [
          SizedBox(height: 10),
          Icon(Icons.camera_alt),
          SizedBox(height: 5),
          Text(
            'Take Photo',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  FilledButton choosePhotoButton(ColorScheme colorScheme) {
    return FilledButton(
      style: ButtonStyle(
        // backgroundColor: MaterialStateProperty.all<Color>(colorScheme.primary),
        // foregroundColor: MaterialStateProperty.all<Color>(colorScheme.onPrimary),
        elevation: MaterialStateProperty.all<double>(4),
        iconSize: MaterialStateProperty.all<double>(100),
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.fromLTRB(40, 20, 40, 20)),
        // textStyle: MaterialStateProperty.all<TextStyle>(
        //     TextStyle(fontSize: 20)),
      ),
      onPressed: () {
        platformOS == 'Android' ? _pickImage() : _pickFile();
        // _pickImage();
      },
      child: const Column(
        children: [
          SizedBox(height: 10),
          Icon(Icons.photo_album),
          SizedBox(height: 5),
          Text(
            'Choose Photo',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}
