import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/main.dart';
import 'package:soyabean/my_second_thread.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:heif_converter/heif_converter.dart';

// import 'package:soyabean/imageClassifier.dart';
// import 'dart:typed_data';
// import 'package:soyabean/isolate_inference.dart';

bool singleThreadedMode = true;
// String modelPath = 'assets/leaf_disease_model_01.tflite';
String modelPath = 'assets/leaf_disease_model_02.tflite';
String classMappingPath = 'assets/class_mapping.json';
late var resizedImage;
bool isHistoryFeatureAvailable = false;

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

  // ImageClassificationHelper? imageClassificationHelper;
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
    // imageClassificationHelper = ImageClassificationHelper();
    // imageClassificationHelper!.initHelper();
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

  Future<List<List<List<List<double>>>>> preprocessImage(File imageFile) async {
    // var imageBytes = await imageFile.readAsBytes();

    var imageBytes = imageFile.readAsBytesSync();
    // late Float32List? inputData;
    final decodedImage = img.decodeImage(imageBytes);

    List<List<List<List<double>>>> imageList = [];
    if (decodedImage != null) {
      // final croppedImage = img.copyCrop(decodedImage,
      //     x: ((decodedImage.width > decodedImage.height)
      //         ? (decodedImage.width - decodedImage.height) ~/ 2
      //         : 0),
      //     y: ((decodedImage.width > decodedImage.height)
      //         ? 0
      //         : (decodedImage.height - decodedImage.width) ~/ 2),
      //     width: ((decodedImage.width > decodedImage.height)
      //         ? decodedImage.height
      //         : decodedImage.width),
      //     height: ((decodedImage.width > decodedImage.height)
      //         ? decodedImage.height
      //         : decodedImage.width));

      void cropImage() {
        // Calculate the cropping dimensions to make the image square
        // int cropSize = (decodedImage.width * 0.5).toInt();
        // int startX = (decodedImage.width - cropSize) ~/ 2;
        // int startY = (decodedImage.height - cropSize) ~/ 2;
        int cropSizeHeight =
            (decodedImage.height * croppMultiplyingFactor).toInt();
        int cropSizeWidth =
            (decodedImage.width * croppMultiplyingFactor).toInt();
        int cropSize =
            (cropSizeHeight > cropSizeWidth) ? cropSizeWidth : cropSizeHeight;
        int startX = (decodedImage.width - cropSize) ~/ 2;
        int startY = (decodedImage.height - cropSize) ~/ 2;

        // Crop the image
        // Crop the image to make it square
        final croppedImage = img.copyCrop(decodedImage,
            x: startX, y: startY, width: cropSize, height: cropSize);

        resizedImage = img.copyResize(croppedImage, width: 150, height: 150);
      }

      (imageCropping)
          ? cropImage()
          : resizedImage =
              img.copyResize(decodedImage, width: 150, height: 150);

      // Convert the image to a 4D array
      for (int i = 0; i < 1; i++) {
        // batch size
        List<List<List<double>>> row = [];
        for (int j = 0; j < resizedImage.height; j++) {
          List<List<double>> pixelRow = [];
          for (int k = 0; k < resizedImage.width; k++) {
            pixelRow.add([
              resizedImage.getPixel(k, j).r / 255.0,
              resizedImage.getPixel(k, j).g / 255.0,
              resizedImage.getPixel(k, j).b / 255.0,
            ]);
          }
          row.add(pixelRow);
        }
        imageList.add(row);
      }

      return imageList;

      // log(imageList.shape.toString());

      // Float32List createFloatArray(List<List<List<List<double>>>> values,
      //     {required List<int> shape}) {
      //   // Ensure the shape matches the provided shape
      //   if (shape.length != 4) {
      //     throw ArgumentError('Shape must be of length 4');
      //   }
      //   if (shape[0] != values.length ||
      //       shape[1] != values[0].length ||
      //       shape[2] != values[0][0].length ||
      //       shape[3] != values[0][0][0].length) {
      //     throw ArgumentError(
      //         'Shape does not match the dimensions of the input values');
      //   }

      //   // Create the Float32List with the specified shape
      //   Float32List floatArray =
      //       Float32List(shape[0] * shape[1] * shape[2] * shape[3]);

      //   // Fill the Float32List with the values
      //   int index = 0;
      //   for (int i = 0; i < values.length; i++) {
      //     for (int j = 0; j < values[i].length; j++) {
      //       for (int k = 0; k < values[i][j].length; k++) {
      //         for (int l = 0; l < values[i][j][k].length; l++) {
      //           floatArray[index++] = values[i][j][k][l];
      //         }
      //       }
      //     }
      //   }

      //   return floatArray;
      // }

      // // Convert the 4D array to Float32List
      // inputData = createFloatArray(imageList, shape: [1, 150, 150, 3]);

      // log(inputData.shape.toString());
    } else {
      log('could not decode image. will use heif converter.');
      log('imageFile.path: ${imageFile.path}');

      String imageFilePath = imageFile.path;

      String? convertedImagePath =
          await HeifConverter.convert(imageFilePath, format: 'png');
      log('convertedImagePath: $convertedImagePath');

      File convertedImageFile = File(convertedImagePath!);

      var imageBytes = convertedImageFile.readAsBytesSync();
      final decodedImage = img.decodeImage(imageBytes);

      List<List<List<List<double>>>> imageList = [];

      if (decodedImage != null) {
        void cropImage() {
          // Calculate the cropping dimensions to make the image square
          // int cropSize = (decodedImage.width * 0.5).toInt();
          int cropSizeHeight =
              (decodedImage.height * croppMultiplyingFactor).toInt();
          int cropSizeWidth =
              (decodedImage.width * croppMultiplyingFactor).toInt();
          int cropSize =
              (cropSizeHeight > cropSizeWidth) ? cropSizeWidth : cropSizeHeight;
          int startX = (decodedImage.width - cropSize) ~/ 2;
          int startY = (decodedImage.height - cropSize) ~/ 2;
          // int startX = ((decodedImage.width - cropSizeWidth) ~/ 2)
          //     .clamp(0, decodedImage.width - cropSizeWidth);
          // int startY = ((decodedImage.height - cropSizeHeight) ~/ 2)
          //     .clamp(0, decodedImage.height - cropSizeHeight);
          // int cropSize =
          //     (cropSizeHeight > cropSizeWidth) ? cropSizeWidth : cropSizeHeight;

          // Crop the image
          // Crop the image to make it square
          final croppedImage = img.copyCrop(decodedImage,
              x: startX, y: startY, width: cropSize, height: cropSize);

          resizedImage = img.copyResize(croppedImage, width: 150, height: 150);
        }

        (imageCropping)
            ? cropImage()
            : resizedImage =
                img.copyResize(decodedImage, width: 150, height: 150);

        // Convert the image to a 4D array
        for (int i = 0; i < 1; i++) {
          // batch size
          List<List<List<double>>> row = [];
          for (int j = 0; j < resizedImage.height; j++) {
            List<List<double>> pixelRow = [];
            for (int k = 0; k < resizedImage.width; k++) {
              pixelRow.add([
                resizedImage.getPixel(k, j).r / 255.0,
                resizedImage.getPixel(k, j).g / 255.0,
                resizedImage.getPixel(k, j).b / 255.0,
              ]);
            }
            row.add(pixelRow);
          }
          imageList.add(row);
        }
      }
      // log(imageList.toString());
      try {
        log('0 deleting convertedImageFile');
        convertedImageFile.deleteSync();
        log('deleting convertedImageFile');
      } catch (e, stackTrace) {
        log('error: $e , stackTrace: $stackTrace');
      }
      return imageList;

      // inputData = imageBytes as Float32List?;
    }

    // return imageList;
  }

  late Interpreter interpreter;

  // Future<String> runModel(Float32List inputImageData) async {
  Future<String> runModel(List<List<List<List<double>>>> inputImageData) async {
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    // Use GPU Delegate
    // doesn't work on emulator
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(GpuDelegateV2());
    }

    // Use Metal Delegate
    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    interpreter =
        await Interpreter.fromAsset(modelPath, options: interpreterOptions);

    final String classMappingData =
        await DefaultAssetBundle.of(context).loadString(classMappingPath);
    classMapping = json.decode(classMappingData);

    // Define the shape of the output tensor
    final outputShape = interpreter.getOutputTensors()[0].shape;
    // Ensure the outputImageData has the correct shape
    final List<List<double>> outputImageData = List.generate(outputShape[0],
        (index) => List<double>.generate(outputShape[1], (index) => 0));

    // // Run inference
    interpreter.run(inputImageData, outputImageData);

    // Flatten the output list of lists to a single list
    List<double> flattenedOutput =
        outputImageData.expand((list) => list).toList();

    // log('original output: ' + outputImageData.toString());
    // log('flattened output: ' + flattenedOutput.toString());

// Find the index of the maximum value in the flattened list
    final predictedClassIndex = flattenedOutput
        .indexOf(flattenedOutput.reduce((a, b) => a > b ? a : b));

    // final predictedClassIndex = outputImageData
    //     .indexOf(outputImageData.reduce((a, b) => a > b ? a : b));
    final predictedClassLabel = classMapping![predictedClassIndex.toString()];
    log('predictedClassLabel : ' + predictedClassLabel.toString());

    // final receivedResult = output.first;
    // setState(() {
    //   result = receivedResult[0];
    // });
    return predictedClassLabel.toString();
  }

  void useIsolate(File? image) async {
    final receivePort = ReceivePort();
    imagePath = image!.path;
    // String classMappingPath = 'assets/class_mapping.json';

    // Initialize the interpreter here
    // Interpreter passInterpreter;
    // try {
    //   passInterpreter =
    //       await Interpreter.fromAsset(modelPath, options: InterpreterOptions());
    // } catch (e, stackTrace) {
    //   log('Failed to initialize passInterpreter.',
    //       error: e, stackTrace: stackTrace);
    //   return;
    // }

    var rootToken = RootIsolateToken.instance!;
    WidgetsFlutterBinding.ensureInitialized();

    await Isolate.spawn(
      mySecondThread,
      // [receivePort.sendPort, imagePath, classMappingPath],
      IsolateData(
        token: rootToken,
        sendPort: receivePort.sendPort,
        imagePath: imagePath,
        classMappingPath: classMappingPath,
        // interpreter: passInterpreter,
      ),
      debugName: 'mySecondThread',
    );

    // receivePort.listen((message) {
    //   setState(() {
    //     status = 'Completed';
    //     result = message.toString();
    //   });
    // });

    receivePort.listen((message) {
      setState(() {
        status = message[0].toString();
        result = message[1].toString();
      });
    });
    // var response = await receivePort.first;
    // log('response ' + response.toString());
  }

  void useSimpleIsolate(File? image) async {
    var imgArray =
        await Isolate.run(preprocessImage(image!) as FutureOr Function());
    result =
        await Isolate.run(runModel(imgArray) as FutureOr<String> Function());
    setState(() {});
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

      singleThreadedMode
          ? preprocessImage(image!).then((imgArray) async {
              // Now, imgArray contains the preprocessed image data as Uint8List.
              // You can use it as needed, such as sending it to a model for predictions.
              setState(() {});
              // log(imgArray.toString());
              // classification =
              //     await imageClassificationHelper?.inferenceImage(imgArray);

              // singleThreadedMode
              //     ? result = await runModel(imgArray)
              //     : result =
              //         (await imageClassificationHelper?.inferenceImage(imgArray))!;
              result = await runModel(imgArray);

              // log(classification.toString());
              log(result);

              if (result != 'Result will be displayed here') {
                status = 'Completed';
              }

              // final entries = classification?.entries;
              // log(entries.toString());

              // if (entries != null) {
              //   for (final entry in entries) {
              //     result = entry.value.toString();
              //   }
              // }
              setState(() {});
            })
          : useIsolate(image);
      // : useSimpleIsolate(image);

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
        // : imageClassificationHelper?.close();
        : null;

    // image?.dispose(); // Dispose of the original image
    // resizedImage?.dispose(); // Dispose of the resized image

    // cleanResult();
    result = 'Result will be displayed here';
    status = 'Preparing...';
    image = null;
    imagePath = null;
    pic = null;
    classification = null;

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
                        AspectRatio(
                            aspectRatio: 1.0,
                            child:
                                Image.file(widget.image!, fit: BoxFit.cover)),
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
              Opacity(
                opacity: isHistoryFeatureAvailable ? 1.0 : 0.5,
                child: SizedBox(
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
                ),
              )
            ],
          ),
        ));
  }

  void resizedImgDialog() {
    try {
      Uint8List resizedBytes = img.encodePng(resizedImage);
      Image myImage = Image.memory(resizedBytes);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Resized Image'),
              contentPadding: const EdgeInsets.all(0),
              content: SizedBox(
                height: 180,
                width: 10,
                child: myImage,
              ),
              // actionsPadding: const EdgeInsets.all(2),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            );
          });
    } catch (e, stackTrace) {
      log('error: $e , stackTrace: $stackTrace');
    }
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
      onPressed: (isHistoryFeatureAvailable) ? () {} : null,
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
        // const Text('SERVER URL', style: TextStyle(fontSize: 12)),
        // Text(urlText, style: const TextStyle(fontSize: 20)),
        // const SizedBox(height: 25),
        // Image.memory(pic!.data!.buffer.asUint8List()),
        // Image.memory(image!.readAsBytesSync()
        ElevatedButton(
            onPressed: () {
              resizedImgDialog();
            },
            child: const Text('Show resized Image')),
      ],
    );
  }
}
