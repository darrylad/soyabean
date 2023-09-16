import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:soyabean/actions_page.dart';
// import 'dart:io';
// import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];

Future<void> reInitCamera() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error in fetching the cameras: $e');
  }
  // runApp(MyApp());
  // const CameraPage();
}

class CameraPage extends StatefulWidget {
  // const CameraPage({super.key, required this.camera});
  const CameraPage({
    super.key,
  });

  // CameraDescription? camera;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    onNewCameraSelected(cameras[0]);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      reInitCamera();
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text('Camera Preview'),
        centerTitle: true,
      ),
      body: _isCameraInitialized
          ? AspectRatio(
              aspectRatio: 1 / controller!.value.aspectRatio,
              child: controller!.buildPreview(),
            )
          : Container(),
    );
  }
}















// class _ActionsState extends State<Actions> {
//   File? _image;

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedImage != null) {
//       setState(() {
//         _image = File(pickedImage.path);
//       });
//       _showImageDialog();
//     }
//   }

//   void _showImageDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Padding(
//             padding: const EdgeInsets.fromLTRB(1.0, 10, 1.0, 10),
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 image: DecorationImage(
//                   image: FileImage(_image!),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           actions: <Widget>[
//             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//               Expanded(
//                 child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all<Color>(
//                           Theme.of(context).colorScheme.primary),
//                       foregroundColor: MaterialStateProperty.all<Color>(
//                           Theme.of(context).colorScheme.onPrimary),
//                       elevation: MaterialStateProperty.all<double>(4),
//                     ),
//                     onPressed: () {},
//                     child: const Text('Upload')),
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text('Cancel'),
//                 ),
//               ),
//             ]),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     var colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: colorScheme.surfaceVariant,
//       appBar: AppBar(
//         backgroundColor: colorScheme.surfaceVariant,
//         title: Text('Soyabean',
//             style: TextStyle(
//                 color: colorScheme.onSurfaceVariant,
//                 fontWeight: FontWeight.w600)),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // TextButton.icon(
//                 //   style: ButtonStyle(
//                 //     backgroundColor:
//                 //         MaterialStateProperty.all<Color>(colorScheme.primary),
//                 //     foregroundColor:
//                 //         MaterialStateProperty.all<Color>(colorScheme.onPrimary),
//                 //     elevation: MaterialStateProperty.all<double>(4),
//                 //     iconSize: MaterialStateProperty.all<double>(100),
//                 //     textStyle: MaterialStateProperty.all<TextStyle>(
//                 //         TextStyle(fontSize: 20)),
//                 //   ),
//                 //   onPressed: () {
//                 //     _pickImage();
//                 //   },
//                 //   icon: const Icon(
//                 //     Icons.photo_album,
//                 //   ),
//                 //   label: const Text('Choose Photo'),
//                 // ),
//                 ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor:
//                         MaterialStateProperty.all<Color>(colorScheme.primary),
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(colorScheme.onPrimary),
//                     elevation: MaterialStateProperty.all<double>(4),
//                     iconSize: MaterialStateProperty.all<double>(100),
//                     shape: MaterialStateProperty.all<OutlinedBorder>(
//                         RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15))),
//                     padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                         const EdgeInsets.fromLTRB(40, 20, 40, 20)),
//                     // textStyle: MaterialStateProperty.all<TextStyle>(
//                     //     TextStyle(fontSize: 20)),
//                   ),
//                   onPressed: () {
//                     _pickImage();
//                   },
//                   child: const Column(
//                     children: [
//                       SizedBox(height: 10),
//                       Icon(Icons.photo_album),
//                       SizedBox(height: 5),
//                       Text(
//                         'Choose Photo',
//                         style: TextStyle(
//                           fontSize: 14,
//                           letterSpacing: 0.9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 60),
//                 ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor:
//                         MaterialStateProperty.all<Color>(colorScheme.primary),
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(colorScheme.onPrimary),
//                     elevation: MaterialStateProperty.all<double>(4),
//                     iconSize: MaterialStateProperty.all<double>(100),
//                     shape: MaterialStateProperty.all<OutlinedBorder>(
//                         RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15))),
//                     padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                         const EdgeInsets.fromLTRB(40, 20, 40, 20)),
//                     // textStyle: MaterialStateProperty.all<TextStyle>(
//                     //     TextStyle(fontSize: 20)),
//                   ),
//                   onPressed: () {},
//                   child: const Column(
//                     children: [
//                       SizedBox(height: 10),
//                       Icon(Icons.camera_alt),
//                       SizedBox(height: 5),
//                       Text(
//                         'Take Photo',
//                         style: TextStyle(
//                           fontSize: 14,
//                           letterSpacing: 0.9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // _image != null
//                 //     ? Image.file(_image!)
//                 //     : const Text('No image selected'),
//               ]),
//         ),
//       ),
//     );
//   }
// }
