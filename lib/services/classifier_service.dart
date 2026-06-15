import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../data/pest_database.dart';
import '../models/pest_info.dart';

class ClassificationResult {
  final PestInfo pestInfo;
  final double confidence;

  ClassificationResult({required this.pestInfo, required this.confidence});
}

class ClassifierService {
  Interpreter? _interpreter;
  final int _inputSize = 224;
  final int _numClasses = 40;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/best_float32.tflite');
    } catch (e) {
      throw Exception('خطا در بارگذاری مدل: $e');
    }
  }

  Future<ClassificationResult?> classifyImage(File imageFile) async {
    if (_interpreter == null) return null;

    try {
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null) return null;

      img.Image resized = img.copyResize(image, width: _inputSize, height: _inputSize);

      var input = List.filled(1 * _inputSize * _inputSize * 3, 0.0)
          .reshape([1, _inputSize, _inputSize, 3]);
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          var pixel = resized.getPixel(x, y);
          input[0][y][x][0] = pixel.r / 255.0;
          input[0][y][x][1] = pixel.g / 255.0;
          input[0][y][x][2] = pixel.b / 255.0;
        }
      }

      var output = List.filled(1 * _numClasses, 0.0).reshape([1, _numClasses]);
      _interpreter!.run(input, output);

      double maxProb = 0.0;
      int predictedIndex = 0;
      for (int i = 0; i < _numClasses; i++) {
        if (output[0][i] > maxProb) {
          maxProb = output[0][i];
          predictedIndex = i;
        }
      }

      PestInfo? pest = PestDatabase.getPestByIndex(predictedIndex);
      if (pest == null) return null;

      return ClassificationResult(pestInfo: pest, confidence: maxProb);
    } catch (e) {
      throw Exception('خطا در پردازش: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}