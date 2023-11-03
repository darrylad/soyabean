import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
// import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'isolate_inference.dart';

class ImageClassificationHelper {
  static const modelPath = 'assets/leaf_disease_model_01.tflite';
  static const labelsPath = 'assets/labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  // Load model
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    // Use GPU Delegate
    // doesn't work on emulator
    if (Platform.isAndroid) {
      options.addDelegate(GpuDelegateV2());
    }

    // Use Metal Delegate
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get tensor input shape [1, 224, 224, 3]
    inputTensor = interpreter.getInputTensors().first;
    // Get tensor output shape [1, 1001]
    outputTensor = interpreter.getOutputTensors().first;

    log('Interpreter loaded successfully');
  }

  // Load labels from assets
  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
  }

  Future<void> initHelper() async {
    _loadLabels();
    _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<Map<String, double>> _inference(InferenceModel inferenceModel) async {
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort
        .send(inferenceModel..responsePort = responsePort.sendPort);
    // get inference result.
    var results = await responsePort.first;
    return results;
  }
  // Future<Map<String, double>> _inference(InferenceModel inferenceModel) async {
  //   ReceivePort responsePort = ReceivePort();
  //   isolateInference.sendPort
  //       ?.send(inferenceModel..responsePort = responsePort.sendPort);
  //   // get inference result.
  //   var results = await responsePort.first;
  //   return results;
  // }

  // inference camera frame
  Future<Map<String, double>> inferenceCameraFrame(
      CameraImage cameraImage) async {
    var isolateModel = InferenceModel(cameraImage, null, interpreter.address,
        labels, inputTensor.shape, outputTensor.shape);
    return _inference(isolateModel);
  }

  // inference still image
  // Future<Map<String, double>> inferenceImage(Image image) async {
  //   var isolateModel = InferenceModel(null, image, interpreter.address, labels,
  //       inputTensor.shape, outputTensor.shape);
  //   return _inference(isolateModel);
  // }
  Future<Map<String, double>> inferenceImage(Uint8List? image) async {
    var isolateModel = InferenceModel(null, image, interpreter.address, labels,
        inputTensor.shape, outputTensor.shape);
    return _inference(isolateModel);
  }

  Future<void> close() async {
    isolateInference.close();
  }
}














// import 'dart:developer';
// import 'dart:io';
// import 'dart:isolate';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart';
// import 'package:soyabean/isolate_inference.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class ImageClassificationHelper {
//   static const modelPath = 'assets/leaf_disease_model_01.tflite';
//   static const labelsPath = 'assets/models/labels.txt';

//   late final Interpreter interpreter;
//   late final List<String> labels;
//   late final IsolateInference isolateInference;
//   late Tensor inputTensor;
//   late Tensor outputTensor;

//   // Load model
//   Future<void> _loadModel() async {
//     final options = InterpreterOptions();

//     // Use XNNPACK Delegate
//     if (Platform.isAndroid) {
//       options.addDelegate(XNNPackDelegate());
//     }

//     // Use GPU Delegate
//     // doesn't work on emulator
//     // if (Platform.isAndroid) {
//     //   options.addDelegate(GpuDelegateV2());
//     // }

//     // Use Metal Delegate
//     if (Platform.isIOS) {
//       options.addDelegate(GpuDelegate());
//     }

//     // Load model from assets
//     interpreter = await Interpreter.fromAsset(modelPath, options: options);
//     // Get tensor input shape [1, 224, 224, 3]
//     inputTensor = interpreter.getInputTensors().first;
//     // Get tensor output shape [1, 1001]
//     outputTensor = interpreter.getOutputTensors().first;

//     log('Interpreter loaded successfully');
//   }

//   // Load labels from assets
//   Future<void> _loadLabels() async {
//     final labelTxt = await rootBundle.loadString(labelsPath);
//     labels = labelTxt.split('\n');
//   }

//   Future<void> initHelper() async {
//     _loadLabels();
//     _loadModel();
//     // isolateInference = IsolateInference();
//     // await isolateInference.start();
//   }

//   Future<Map<String, double>> _inference(InferenceModel inferenceModel) async {
//     ReceivePort responsePort = ReceivePort();
//     isolateInference.sendPort
//         .send(inferenceModel..responsePort = responsePort.sendPort);
//     // get inference result.
//     var results = await responsePort.first;
//     return results;
//   }

//   // inference camera frame
//   // Future<Map<String, double>> inferenceCameraFrame(
//   //     CameraImage cameraImage) async {
//   //   var isolateModel = InferenceModel(cameraImage, null, interpreter.address,
//   //       labels, inputTensor.shape, outputTensor.shape);
//   //   return _inference(isolateModel);
//   // }

//   // inference still image
//   Future<Map<String, double>> inferenceImage(Image image) async {
//     var isolateModel = InferenceModel(null, image, interpreter.address, labels,
//         inputTensor.shape, outputTensor.shape);
//     return _inference(isolateModel);
//   }

//   Future<void> close() async {
//     isolateInference.close();
//   }
// }












// class MyModel {
//   final Interpreter _interpreter;
//   MyModel(this._interpreter);
//   String run(Image image) {
//     // Convert the image to a tensor.
//     final tfliteImage = TfliteImage.fromImage(image);
//     final inputTensor = TfliteTensor(tfliteImage);
//     // Set the input tensor of the interpreter.
//     _interpreter.setInputTensor(0, inputTensor);
//     // Run the model.
//     _interpreter.run();
//     // Get the output of the model.
//     final outputTensor = _interpreter.getOutputTensor(0);
//     // Interpret the output tensor and extract the predicted text.
//     final predictedText = outputTensor.data.toList()[0];
//     return predictedText;
//   }
// }

