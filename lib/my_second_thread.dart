import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:soyabean/description_page.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/material.dart';
// import 'dart:ui' as ui;

// void mySecondThread(List<dynamic> args) {
Future<void> mySecondThread(IsolateData isolateData) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);

  SendPort sendPort = isolateData.sendPort;
  String? imagePath = isolateData.imagePath;

  String classMappingPath = isolateData.classMappingPath;

  String result = 'Result will be displayed here';
  String status = 'Running';
  File? image = File(imagePath!);
  sendPort.send([status, result]);

  Map<String, dynamic>? classMapping;

  // late InterpreterOptions isolateInterpreterOptions;
  late Interpreter isolateInterpreter;

  try {
    // isolateInterpreterOptions = InterpreterOptions();
    // ui.FlutterBinding.ensureInitialized();
    // Initialize the interpreter after ensuring Flutter is initialized
    // isolateInterpreter = await Interpreter.fromAsset(
    isolateInterpreter = await initializeInterpreter();
    // isolateInterpreter = isolateData.interpreter;

    // The rest of your code that uses the interpreter...
  } catch (e, stackTrace) {
    log('Failed to initialize interpreter.', error: e, stackTrace: stackTrace);
    status = 'Failed to initialize interpreter.';
    result = '-';
    sendPort.send([status, result]);
    // Handle exceptions...
  }

  Future<List<List<List<List<double>>>>> preprocessImage(File imageFile) async {
    // var imageBytes = await imageFile.readAsBytes();

    var imageBytes = imageFile.readAsBytesSync();
    // late Float32List? inputData;
    final decodedImage = img.decodeImage(imageBytes);

    List<List<List<List<double>>>> imageList = [];
    if (decodedImage != null) {
      final resizedImage =
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

      log('imageList: ' + imageList.toString());

      return imageList;
    } else {
      log('could not decode image. will use heif converter.');
      status = 'Converting image';
      sendPort.send([status, result]);
      log('imageFile.path: ${imageFile.path}');

      String imageFilePath = imageFile.path;

      try {
        String? convertedImagePath =
            await HeifConverter.convert(imageFilePath, format: 'png');
        log('convertedImagePath: $convertedImagePath');

        File convertedImageFile = File(convertedImagePath!);

        var imageBytes = convertedImageFile.readAsBytesSync();
        final decodedImage = img.decodeImage(imageBytes);

        List<List<List<List<double>>>> imageList = [];

        if (decodedImage != null) {
          final resizedImage =
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
        log(imageList.toString());
      } catch (e) {
        log('could not convert image.');
        status = 'Failed to convert image';
        result = '-';
        sendPort.send([status, result]);
        // Handle exceptions...
      }

      return imageList;

      // inputData = imageBytes as Float32List?;
    }

    // return imageList;
  }

  // late Interpreter interpreter;

  Future<String> runModel(List<List<List<List<double>>>> inputImageData) async {
    // isolateInterpreterOptions = InterpreterOptions();
    // WidgetsFlutterBinding.ensureInitialized();

    // final Interpreter interpreter = await Interpreter.fromAsset(
    //     'assets/leaf_disease_model_01.tflite',
    //     options: interpreterOptions);
    // final String classMappingData = await DefaultAssetBundle.of(context)
    //     .loadString('assets/class_mapping.json');
    final String classMappingData = await File(classMappingPath).readAsString();
    classMapping = json.decode(classMappingData);

    // Define the shape of the output tensor
    final outputShape = isolateInterpreter.getOutputTensors()[0].shape;
    // Ensure the outputImageData has the correct shape
    final List<List<double>> outputImageData = List.generate(outputShape[0],
        (index) => List<double>.generate(outputShape[1], (index) => 0));

    log('outputshape ' + outputShape.toString());

    // // Run inference
    isolateInterpreter.run(inputImageData, outputImageData);

    // Flatten the output list of lists to a single list
    List<double> flattenedOutput =
        outputImageData.expand((list) => list).toList();

    log('original output: ' + outputImageData.toString());
    log('flattened output: ' + flattenedOutput.toString());

    // Find the index of the maximum value in the flattened list
    final predictedClassIndex = flattenedOutput
        .indexOf(flattenedOutput.reduce((a, b) => a > b ? a : b));

    final predictedClassLabel = classMapping![predictedClassIndex.toString()];
    log('predictedClassLabel : ' + predictedClassLabel.toString());

    // final receivedResult = output.first;
    // setState(() {
    //   result = receivedResult[0];
    // });
    return predictedClassLabel.toString();
  }

  preprocessImage(image).then((imgArray) async {
    result = await runModel(imgArray);

    log('this' + result);

    if (result != 'Result will be displayed here') {
      status = 'Completed';
    }
  });

  print('mySecondThread');
  log(result);
  sendPort.send([status, result]);
  Isolate.current.kill();
}

class IsolateData {
  SendPort sendPort;
  String? imagePath;
  String classMappingPath;
  final RootIsolateToken token;

  IsolateData({
    required this.token,
    required this.sendPort,
    required this.imagePath,
    required this.classMappingPath,
  });
}

Future<Interpreter> initializeInterpreter() async {
  Completer<Interpreter> completer = Completer();
  // Ensure Flutter is initialized before initializing the interpreter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the interpreter after ensuring Flutter is initialized
  // return await Interpreter.fromAsset(modelPath, options: InterpreterOptions());
  try {
    // Initialize the interpreter after ensuring Flutter is initialized
    Interpreter interpreter = await Interpreter.fromAsset(
      modelPath,
      options: InterpreterOptions(),
    );

    // Complete the Completer to signal that the interpreter is ready
    completer.complete(interpreter);
  } catch (e, stackTrace) {
    // Handle initialization errors
    log('Failed to initialize interpreter.', error: e, stackTrace: stackTrace);
    completer.completeError(e);
  }

  return completer.future;
}

Future<void> mySecondSimpleThread(SimpleIsolateData simpleIsolateData) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(simpleIsolateData.token);

  SendPort sendPort = simpleIsolateData.sendPort;
  String? imagePath = simpleIsolateData.imagePath;

  String classMappingPath = simpleIsolateData.classMappingPath;

  String result = 'Result will be displayed here';
  String status = 'Running';
  File? image = File(imagePath!);
  // sendPort.send([status, result]);

  Map<String, dynamic>? classMapping;

  // late InterpreterOptions isolateInterpreterOptions;
  late Interpreter isolateInterpreter;

  try {
    // isolateInterpreterOptions = InterpreterOptions();
    isolateInterpreter = await initializeInterpreter();
  } catch (e, stackTrace) {
    log('Failed to initialize interpreter.', error: e, stackTrace: stackTrace);
    status = 'Failed to initialize interpreter.';
    result = '-';
    // sendPort.send([status, result]);
    // Handle exceptions...
  }

  Future<List<List<List<List<double>>>>> preprocessImage(File imageFile) async {
    // var imageBytes = await imageFile.readAsBytes();

    var imageBytes = imageFile.readAsBytesSync();
    // late Float32List? inputData;
    final decodedImage = img.decodeImage(imageBytes);

    List<List<List<List<double>>>> imageList = [];
    if (decodedImage != null) {
      final resizedImage =
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

      log('imageList: ' + imageList.toString());

      return imageList;
    } else {
      log('could not decode image. will use heif converter.');
      status = 'Converting image';
      sendPort.send([status, result]);
      log('imageFile.path: ${imageFile.path}');

      String imageFilePath = imageFile.path;

      try {
        String? convertedImagePath =
            await HeifConverter.convert(imageFilePath, format: 'png');
        log('convertedImagePath: $convertedImagePath');

        File convertedImageFile = File(convertedImagePath!);

        var imageBytes = convertedImageFile.readAsBytesSync();
        final decodedImage = img.decodeImage(imageBytes);

        List<List<List<List<double>>>> imageList = [];

        if (decodedImage != null) {
          final resizedImage =
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
        log(imageList.toString());
      } catch (e) {
        log('could not convert image.');
        status = 'Failed to convert image';
        result = '-';
        sendPort.send([status, result]);
        // Handle exceptions...
      }

      return imageList;

      // inputData = imageBytes as Float32List?;
    }

    // return imageList;
  }

  // late Interpreter interpreter;

  Future<String> runModel(List<List<List<List<double>>>> inputImageData) async {
    // isolateInterpreterOptions = InterpreterOptions();
    // WidgetsFlutterBinding.ensureInitialized();

    // final Interpreter interpreter = await Interpreter.fromAsset(
    //     'assets/leaf_disease_model_01.tflite',
    //     options: interpreterOptions);
    // final String classMappingData = await DefaultAssetBundle.of(context)
    //     .loadString('assets/class_mapping.json');
    final String classMappingData = await File(classMappingPath).readAsString();
    classMapping = json.decode(classMappingData);

    // Define the shape of the output tensor
    final outputShape = isolateInterpreter.getOutputTensors()[0].shape;
    // Ensure the outputImageData has the correct shape
    final List<List<double>> outputImageData = List.generate(outputShape[0],
        (index) => List<double>.generate(outputShape[1], (index) => 0));

    log('outputshape ' + outputShape.toString());

    // // Run inference
    isolateInterpreter.run(inputImageData, outputImageData);

    // Flatten the output list of lists to a single list
    List<double> flattenedOutput =
        outputImageData.expand((list) => list).toList();

    log('original output: ' + outputImageData.toString());
    log('flattened output: ' + flattenedOutput.toString());

    // Find the index of the maximum value in the flattened list
    final predictedClassIndex = flattenedOutput
        .indexOf(flattenedOutput.reduce((a, b) => a > b ? a : b));

    final predictedClassLabel = classMapping![predictedClassIndex.toString()];
    log('predictedClassLabel : ' + predictedClassLabel.toString());

    // final receivedResult = output.first;
    // setState(() {
    //   result = receivedResult[0];
    // });
    return predictedClassLabel.toString();
  }

  preprocessImage(image).then((imgArray) async {
    result = await runModel(imgArray);

    log('this' + result);

    if (result != 'Result will be displayed here') {
      status = 'Completed';
    }
  });

  print('mySecondThread');
  log(result);
  sendPort.send([status, result]);
  Isolate.current.kill();
}

class SimpleIsolateData {
  SendPort sendPort;
  String? imagePath;
  String classMappingPath;
  final RootIsolateToken token;

  SimpleIsolateData({
    required this.token,
    required this.sendPort,
    required this.imagePath,
    required this.classMappingPath,
  });
}
