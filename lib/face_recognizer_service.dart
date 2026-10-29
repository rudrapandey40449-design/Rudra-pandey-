import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognizerService {
  late Interpreter _interpreter;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilefacenet.tflite',
        options: options,
      );
      _isInitialized = true;
    } catch (e) {
      print('TFLite Model Load Error: $e');
    }
  }

  List<double> extractEmbedding(img.Image croppedFace) {
    if (!_isInitialized) {
      throw Exception('Interpreter not initialized');
    }

    // Resize image to 112x112 as expected by MobileFaceNet
    img.Image resized = img.copyResize(croppedFace, width: 112, height: 112);

    // Normalize image to [-1, 1]
    var input = List.generate(
      1,
      (i) => List.generate(
        112,
        (y) => List.generate(
          112,
          (x) {
            var pixel = resized.getPixel(x, y);
            return [
              (pixel.r - 127.5) / 128.0,
              (pixel.g - 127.5) / 128.0,
              (pixel.b - 127.5) / 128.0,
            ];
          },
        ),
      ),
    );

    // Output shape for MobileFaceNet is [1, 192]
    var output = List.filled(1 * 192, 0.0).reshape([1, 192]);
    _interpreter.run(input, output);

    List<double> rawEmbedding = List<double>.from(output[0]);

    // L2 Normalize
    double sum = 0.0;
    for (var val in rawEmbedding) {
      sum += val * val;
    }
    double norm = sqrt(sum);

    return rawEmbedding.map((e) => e / norm).toList();
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
    }
  }
}
