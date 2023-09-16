import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soyabean/camera_page.dart';
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
    cameras = await availableCameras();
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

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.fromLTRB(1.0, 10, 1.0, 10),
            child: Container(
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
                    onPressed: () {},
                    child: const Text('Upload')),
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

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceVariant,
        title: Text('Soyabean',
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
        // initCamera();
        mainCam(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       // builder: (context) => CameraPage(camera: firstCamera)),
        //       builder: (context) => const CameraPage()),
        // );
      },
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
        _pickImage();
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
