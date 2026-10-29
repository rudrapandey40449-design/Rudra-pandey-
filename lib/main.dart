import 'package:flutter/material.dart';
import 'camera_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StudentIdInputScreen(),
    );
  }
}

class StudentIdInputScreen extends StatefulWidget {
  const StudentIdInputScreen({Key? key}) : super(key: key);

  @override
  State<StudentIdInputScreen> createState() => _StudentIdInputScreenState();
}

class _StudentIdInputScreenState extends State<StudentIdInputScreen> {
  final TextEditingController _idController = TextEditingController();

  // Test Sample: 192-d dummy embedding for verification test
  final List<double> _sampleRegisteredEmbedding = List.filled(192, 0.05);

  void _proceedToVerification() {
    final studentId = _idController.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया स्टूडेंट ID / Roll Number दर्ज करें')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceCameraView(
          studentId: studentId,
          registeredFaceEmbedding: _sampleRegisteredEmbedding,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.face_retouching_natural,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Face Attendance System',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Student Roll No / ID',
                hintText: 'उदा. STU-101',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _proceedToVerification,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'चेहरा स्कैन करें',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
