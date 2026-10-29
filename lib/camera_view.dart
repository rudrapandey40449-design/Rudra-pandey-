import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'face_math_util.dart';
import 'face_recognizer_service.dart';

class AttendanceCameraView extends StatefulWidget {
  final List<double> registeredFaceEmbedding;
  final String studentId;

  const AttendanceCameraView({
    Key? key,
    required this.registeredFaceEmbedding,
    required this.studentId,
  }) : super(key: key);

  @override
  State<AttendanceCameraView> createState() => _AttendanceCameraViewState();
}

class _AttendanceCameraViewState extends State<AttendanceCameraView> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  final FaceRecognizerService _faceRecognizerService = FaceRecognizerService();

  bool _isProcessingFrame = false;
  String _statusMessage = "Align student face in the frame";
  bool _isAttendanceMarked = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    await _faceRecognizerService.initialize();

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    _cameraController!.startImageStream(_processCameraFrame);
    setState(() {});
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _isAttendanceMarked) return;
    _isProcessingFrame = true;

    try {
      // 1. ML Kit Face Detection
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() => _statusMessage = "No face detected");
        _isProcessingFrame = false;
        return;
      }

      final Face face = faces.first;

      // 2. Liveness Check (Blink Verification)
      final leftOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightOpen = face.rightEyeOpenProbability ?? 1.0;

      if (leftOpen < 0.2 || rightOpen < 0.2) {
        setState(() => _statusMessage = "Liveness: Blink Detected! Verifying...");
      }

      // Convert frame to img.Image for MobileFaceNet
      img.Image convertedImage = _convertYUV420ToImage(image);
      final rect = face.boundingBox;

      img.Image croppedFace = img.copyCrop(
        convertedImage,
        x: rect.left.toInt().clamp(0, convertedImage.width - 1),
        y: rect.top.toInt().clamp(0, convertedImage.height - 1),
        width: rect.width.toInt().clamp(1, convertedImage.width),
        height: rect.height.toInt().clamp(1, convertedImage.height),
      );

      // 3. Extract embedding & calculate Cosine Similarity
      final currentEmbedding = _faceRecognizerService.extractEmbedding(croppedFace);
      final similarity = FaceMathUtil.computeCosineSimilarity(
        widget.registeredFaceEmbedding,
        currentEmbedding,
      );

      if (similarity >= 0.82) {
        _isAttendanceMarked = true;
        setState(() {
          _statusMessage = "Success! Attendance Marked for ${widget.studentId}";
        });
        await _cameraController?.stopImageStream();
      } else {
        setState(() {
          _statusMessage = "Face Mismatch (${(similarity * 100).toStringAsFixed(1)}%)";
        });
      }
    } catch (e) {
      print("Frame processing error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final img.Image outImg = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      int pY = y * image.planes[0].bytesPerRow;
      int pUV = (y >> 1) * uvRowStride;

      for (int x = 0; x < width; x++) {
        final uvIndex = pUV + (x >> 1) * uvPixelStride;
        final index = pY + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + (1.370705 * (vp - 128))).round().clamp(0, 255);
        int g = (yp - (0.337633 * (up - 128)) - (0.698001 * (vp - 128))).round().clamp(0, 255);
        int b = (yp + (1.732446 * (up - 128))).round().clamp(0, 255);

        outImg.setPixelRgb(x, y, r, g, b);
      }
    }
    return outImg;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _faceRecognizerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Verify Student ID: ${widget.studentId}")),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: _isAttendanceMarked ? Colors.green : Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
