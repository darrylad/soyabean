import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/description_page.dart';
import 'package:soyabean/main.dart';
import 'package:soyabean/options_page.dart';
import 'package:soyabean/url_text_input_dialog.dart';
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
  FlashMode? _currentFlashMode;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
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

    _currentFlashMode = controller!.value.flashMode;

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
      _showTextAlert('Error initializing camera: $e');
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
    // _textFieldController.dispose();
    _isCapturing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Free up memory when camera not active
      cameraController.dispose();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      reInitCamera();
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  bool _isCapturing = false;

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      _showTextAlert('Error occured while taking picture: $e');
      return null;
    }
  }

  // final TextEditingController _textFieldController = TextEditingController();

  // bool isUploadButtonEnabled = false;

  // Future<void> _displayTextInputDialog(BuildContext context, image) async {
  //   var colorScheme = Theme.of(context).colorScheme;
  //   // return oldShowDialog(context, colorScheme, image);
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
  //                       setState(() {});
  //                       // setState(() {
  //                       //   urlText = value;
  //                       // });
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

  Future<void> oldShowDialog(
      BuildContext context, ColorScheme colorScheme, image) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Enter Server URL',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            content: TextField(
              onChanged: (value) {},
              // controller: _textFieldController,
              decoration: const InputDecoration(
                  hintText: "http://your-matlab-server-ip:3000"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  // code for https request
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DescriptionPage(image: image)));
                },
                child: const Text('UPLOAD'),
              ),
            ],
          );
        });
  }

  void _showImageDialog(image) {
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
                      image: FileImage(image!),
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
                                            image: image,
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
                    // _displayTextInputDialog(context, image);

                    // final showUrlTextDialog = ShowUrlTextDialog(
                    //   image: image, // Provide the image parameter.
                    //   context: context, // Provide the context parameter.
                    // );
                    // showUrlTextDialog.callDisplayTextInputDialog(
                    //     image, context);

                    // displayTextInputDialog(context, image);

                    // ShowUrlTextDialog(image: image, context: context);

                    (askForUrlEverytime)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowUrlTextDialog(
                                      image: image,
                                      context: context,
                                    )))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DescriptionPage(image: image)));
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
                    controller!.resumePreview();
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

  void _showTextAlert(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
            ),
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
          ? colorScheme.onBackground
          : colorScheme.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarColor: (brightness == Brightness.light)
              ? colorScheme.onBackground
              : colorScheme.background, // Navigation bar
          statusBarColor: Colors.transparent, // Status bar
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(
            color: (brightness == Brightness.light)
                ? colorScheme.surface
                : colorScheme.onSurfaceVariant //change your color here
            ),
        backgroundColor: (brightness == Brightness.light)
            ? colorScheme.onBackground
            : colorScheme.background,
        title: Text('Camera Preview',
            style: TextStyle(
                color: (brightness == Brightness.light)
                    ? colorScheme.surface
                    : colorScheme.onSurfaceVariant)),
        centerTitle: true,
      ),
      body: _isCameraInitialized
          ? Center(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      // color: colorScheme.surface,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      // child: AspectRatio(
                      //   aspectRatio: 1 / controller!.value.aspectRatio,
                      //   child: controller!.buildPreview(),
                      // ),
                      child: controller!.buildPreview(),
                    ),
                  ),
                  // const SafeArea(
                  //   child: SizedBox(
                  //     height: 5,
                  //   ),
                  // ),
                  SizedBox(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(
                          child:
                              // _isCapturing
                              //     ? Center(
                              //         child: CircularProgressIndicator(
                              //           color: colorScheme.surfaceVariant,
                              //         ),
                              //       )
                              //     :
                              AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Center(
                                      child: photoShutterButton(
                                          colorScheme, brightness))),
                        ),
                        Expanded(
                            child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: _isCapturing
                              ? Center(
                                  child: CircularProgressIndicator(
                                  color: (brightness == Brightness.light)
                                      ? colorScheme.surface
                                      : colorScheme.onBackground,
                                ))
                              : const SizedBox(),
                        )
                            // child: const SizedBox(),
                            ),
                        // videoRecordButton(),
                        // cameraFlipButton(),
                      ],
                    ),
                  ),
                  // const SizedBox(
                  //   height: 5,
                  // )
                ],
              ),
            )
          : Center(
              // when camera is not initialized
              child: CircularProgressIndicator(
              color: colorScheme.surface,
            )),
    );
  }

  IconButton photoShutterButton(
    colorScheme,
    Brightness brightness,
  ) {
    return IconButton(
      icon: const Icon(
        Icons.camera_rounded,
        size: 75,
      ),
      color: (brightness == Brightness.light)
          ? (_isCapturing
              ? colorScheme.surface.withAlpha(150)
              : colorScheme.surface)
          : (_isCapturing
              ? colorScheme.onSurfaceVariant.withAlpha(150)
              : colorScheme.onBackground),
      onPressed: (_isCapturing)
          ? () {
              // do nothing, to disable the button when caputring
            }
          : () async {
              // checkIfCapturing();
              setState(() {
                _isCapturing = true;
              });
              XFile? rawImage = await takePicture();
              File imageFile = File(rawImage!.path);

              int currentUnix = DateTime.now().millisecondsSinceEpoch;
              final directory = await getApplicationDocumentsDirectory();
              String fileFormat = imageFile.path.split('.').last;

              await imageFile.copy(
                '${directory.path}/$currentUnix.$fileFormat',
              );

              final pickedImage = rawImage;
              File? image;
              setState(() {
                image = File(pickedImage.path);
                _isCapturing = false;
              });
              _showImageDialog(image);
              controller!.pausePreview();
            },
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
