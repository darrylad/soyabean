import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'dart:ui';
// import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/imageClassifier.dart';
// import 'package:soyabean/isolate_inference.dart';
import 'package:soyabean/main.dart';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

bool singleThreadedMode = true;

class DescriptionPage extends StatefulWidget {
  final File? image;
  // final img.Image? image;
  const DescriptionPage({super.key, required this.image});

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  String result = 'Result will be displayed here';
  late File? image; //original variable

  String status = 'Preparing...';

  ImageClassificationHelper? imageClassificationHelper;
  String? imagePath;
  img.Image? pic;
  Map<String, double>? classification;

  Map<String, dynamic>? classMapping;

  // void convertFileToImage(File? file) {
  //   if (file == null) {
  //     // return null;
  //   } else {
  //     // Read the bytes of the file.
  //     final bytes = file.readAsBytesSync();

  //     // final picImage = img.decodeImage(bytes);
  //     pic = img.decodeImage(bytes);
  //     imagePath = widget.image!.path;
  //   }

  //   // Decode the bytes into an img.Image object.

  //   // return picImage;
  // }

  @override
  void initState() {
    image = widget.image;
    // convertFileToImage(image);
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    super.initState();
    (isDemoModeOn) ? null : processImage();
  }

  void cleanResult() {
    imagePath = null;
    pic = null;
    classification = null;
    setState(() {});
  }

  // Future<img.Image?> decodeImageAsync(Uint8List imageData) async {
  //   try {
  //     return await Future(() {
  //       return img.decodeImage(imageData);
  //     });
  //   } catch (e) {
  //     log('Image decoding error: $e');
  //     return null;
  //   }
  // }

  // Future<Uint8List?> convertFileToJpegInMemory(File inputImage) async {
  //   // Read the image file
  //   final imageBytes = await inputImage.readAsBytes();
  //   // Decode the image
  //   final image = img.decodeImage(Uint8List.fromList(imageBytes));
  //   if (image == null) {
  //     // Handle the case where the image couldn't be decoded.
  //     log('Failed to decode the image.');
  //     return null;
  //   }
  //   // Encode the image as JPEG
  //   final jpegImage = img.encodeJpg(image);
  //   return Uint8List.fromList(jpegImage);
  // }

  // Future<Uint8List> loadImageAsUint8List(String imagePath) async {
  //   final ByteData data = await rootBundle.load(imagePath);
  //   final List<int> bytes = data.buffer.asUint8List();
  //   return Uint8List.fromList(bytes);
  // }

  // Future<Uint8List> preprocessImage(String imagePath) async {
  //   // final Uint8List imageUint8List = await loadImageAsUint8List(imagePath);
  //   // You can perform additional preprocessing here if needed, such as resizing the image.
  //   // Ensure the image data is in the [0, 255] range (like the original code)
  //   imageUint8List.forEach((byte) {
  //     byte ~/= 255; // Rescale pixel values
  //   });
  //   return imageUint8List;
  // }

  Future<Uint8List> preprocessImage(File imageFile) async {
    var imageBytes = await imageFile.readAsBytes();
    late var inputData;
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage != null) {
      final resizedImage =
          img.copyResize(decodedImage, width: 150, height: 150);
      inputData = resizedImage.data?.buffer.asUint8List();
      for (int i = 0; i < inputData!.length; i++) {
        // inputData[i] /= 255.0;
        // inputData[i] = (inputData[i] / 255.0).toDouble();
        // inputData[i] = (inputData[i] / 255.0);
        inputData[i] = (inputData[i] ~/ 255);
      }
    } else {
      inputData = imageBytes;
    }

    // final inputTensor = Tensor(TfLiteType.float32, [1, 150, 150, 3]);
    // inputTensor.buffer.asUint8List().setRange(0, inputData.length, inputData);

    // final outputs = Map<int, Object>();
    // outputs[0] = Tensor(TfLiteType.float32, [1, 5]);

    // Ensure the image data is in the [0, 255] range (like the original code)
    // imageBytes = imageBytes.map((byte) => (byte ~/ 255).toInt()).toList();

    return Uint8List.fromList(inputData);
  }

  late Interpreter interpreter;

  Future<String> runModel(Uint8List inputImageData) async {
    final interpreterOptions = InterpreterOptions();
    interpreter = await Interpreter.fromAsset(
        'assets/leaf_disease_model_01.tflite',
        options: interpreterOptions);
    final String classMappingData = await DefaultAssetBundle.of(context)
        .loadString('assets/class_mapping.json');
    classMapping = json.decode(classMappingData);

    // final inputImageData = imgInput.data!.buffer.asUint8List();
    // final outputImageData = List(1 * classMapping!.length);
    final outputImageData =
        List<double>.generate(classMapping!.length, (index) => 0);

    // var input = [inputImage];
    // var output = [
    //   List<String>.filled(interpreter.getOutputTensors().first.shape[0], "")
    // ];
    // var output =
    //     List<String>.filled(interpreter.getOutputTensors().first.shape[1], "");

    // // Run inference
    interpreter.run(inputImageData, outputImageData);

    final predictedClassIndex = outputImageData
        .indexOf(outputImageData.reduce((a, b) => a > b ? a : b));
    final predictedClassLabel = classMapping![predictedClassIndex.toString()];
    log(predictedClassLabel.toString());

    // final receivedResult = output.first;
    // setState(() {
    //   result = receivedResult[0];
    // });
    return predictedClassLabel;
  }

  Future<void> processImage() async {
    imagePath = widget.image!.path;

    // final jpegInMemory = await convertFileToJpegInMemory(image!);

    if (imagePath != null) {
      // if (resizedImage != null) {
      // Read image bytes from file
      // final imageData = File(imagePath!).readAsBytesSync();
      // final imageData =
      //     await image!.readAsBytes().timeout(const Duration(seconds: 12));
      // // log(imageData.toString());
      // if (imageData.isEmpty) {
      //   log('imageData is empty');
      // } else {
      //   log('imageData is not empty');
      // }

      // Decode image using package:image/image.dart (https://pub.dev/image)
      // pic = img.decodeImage(imageData);
      // pic = await decodeImageAsync(imageData);

      preprocessImage(image!).then((imgArray) async {
        // Now, imgArray contains the preprocessed image data as Uint8List.
        // You can use it as needed, such as sending it to a model for predictions.
        setState(() {});
        // log(imgArray.toString());
        // classification =
        //     await imageClassificationHelper?.inferenceImage(imgArray);

        singleThreadedMode
            ? await runModel(imgArray)
            : classification =
                await imageClassificationHelper?.inferenceImage(imgArray);

        log(classification.toString());
        log(result);

        final entries = classification?.entries;
        log(entries.toString());

        if (entries != null) {
          for (final entry in entries) {
            result = entry.value.toString();
          }
        }
        setState(() {});
      });

      // original code
      // setState(() {});
      // // classification = await imageClassificationHelper?.inferenceImage(pic!);
      // // classification = await imageClassificationHelper?.inferenceImage(image!);
      // log(classification.toString());

      // final entries = classification?.entries;
      // log(entries.toString());

      // if (entries != null) {
      //   for (final entry in entries) {
      //     result = entry.value.toString();
      //   }
      // }
      // setState(() {});

      // await decodeImageAsync(imageData).then((decodedImage) async {
      //   if (decodedImage != null) {
      //     pic = decodedImage;
      //     setState(() {});
      //     classification =
      //         await imageClassificationHelper?.inferenceImage(pic!);

      //     final entries = classification?.entries;
      //     log(entries.toString());

      //     if (entries != null) {
      //       for (final entry in entries) {
      //         result = entry.value.toString();
      //       }
      //     }
      //     setState(() {});
      //   } else {
      //     // Value doesn't match, wait for a specified duration
      //     const waitDuration = Duration(seconds: 3);
      //     final completer = Completer<void>();

      //     Timer(waitDuration, () {
      //       // This block will be executed after the specified duration
      //       if (!completer.isCompleted) {
      //         // The timer has not been canceled, terminate or handle the timeout
      //         // You can choose to log a message or take other actions here
      //         completer.completeError('Timeout occurred');
      //       }
      //     });

      //     try {
      //       await completer.future; // Wait for either the timeout or the value
      //     } catch (error) {
      //       log('Timeout error: $error');
      //       // Handle the timeout error, e.g., show a message to the user
      //     }
      //     // log('pic is null');
      //   }
      // });

//       if (pic != null) {
//         setState(() {});
//         classification = await imageClassificationHelper?.inferenceImage(pic!);

//         final entries = classification?.entries;
//         log(entries.toString());

// // Iterate over the list and get the string value for each key-value pair.
//         if (entries != null) {
//           for (final entry in entries) {
//             // final key = entry.key;
//             result = entry.value.toString();

//             // Do something with the string value.
//           }
//         }
//         setState(() {});
//       } else {
//         log('pic is null');
//       }

      // result = await imageClassificationHelper!.inferenceImage(pic!);
    }
  }

  @override
  void dispose() {
    singleThreadedMode
        ? interpreter.close()
        : imageClassificationHelper?.close();

    super.dispose();
  }

  Future<void> uploadImage() async {
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
                        // Image.memory(widget.pic!.getBytes()),
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
                      child: saveButton(colorScheme),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: deleteButton(colorScheme),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  ElevatedButton saveButton(ColorScheme colorScheme) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        backgroundColor:
            MaterialStateProperty.all(colorScheme.primaryContainer),
      ),
      onPressed: () {},
      child: const SizedBox(height: 50, child: Center(child: Text('Save'))),
    );
  }

  ElevatedButton deleteButton(ColorScheme colorScheme) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(colorScheme.onError),
      ),
      onPressed: () {
        cleanResult();
      },
      child: SizedBox(
          height: 50,
          child: Center(
              child: Text(
            'Delete',
            style: TextStyle(color: colorScheme.error),
          ))),
    );
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
        const SizedBox(height: 25),
        // Image.memory(pic!.data!.buffer.asUint8List()),
        // Image.memory(image!.readAsBytesSync()
      ],
    );
  }
}
