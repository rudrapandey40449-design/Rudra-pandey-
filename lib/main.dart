import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera error: $e");
  }
  runApp(const AttendanceSystemApp());
}

class AttendanceSystemApp extends StatelessWidget {
  const AttendanceSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MainDashboardScreen(),
    );
  }
}

// ---------------- 1. MAIN DASHBOARD SCREEN ----------------
class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Smart Attendance Portal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Attendance Portal',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'छात्र उपस्थिति, प्रोफाइल और आईडी कार्ड प्रबंधन',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'मुख्य सेवाएं (Services)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Mark Attendance',
                    subtitle: 'हाजिरी लगाएं (Face)',
                    icon: Icons.camera_front_rounded,
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceInputScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Register Student',
                    subtitle: 'नया छात्र जोड़ें',
                    icon: Icons.person_add_alt_1_rounded,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterStudentScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Update Details',
                    subtitle: 'जानकारी बदलें',
                    icon: Icons.edit_note_rounded,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UpdateStudentScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Student ID Card',
                    subtitle: 'आईडी कार्ड बनाएं',
                    icon: Icons.badge_rounded,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StudentIdCardScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withAlpha(35),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 2. ATTENDANCE (ROLL NO INPUT & SCAN) ----------------
class AttendanceInputScreen extends StatefulWidget {
  const AttendanceInputScreen({super.key});

  @override
  State<AttendanceInputScreen> createState() => _AttendanceInputScreenState();
}

class _AttendanceInputScreenState extends State<AttendanceInputScreen> {
  final TextEditingController _idController = TextEditingController();

  void _openCamera() {
    String studentId = _idController.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया छात्र रोल नंबर या आईडी दर्ज करें!'), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScannerScreen(studentId: studentId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.face_retouching_natural, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'छात्र की उपस्थिति लगाएं',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('रोल नंबर डालें और चेहरा स्कैन करके प्रेजेंट मार्क करें।', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Student Roll No / ID',
                hintText: 'उदा. STU-01, 101, या 1',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openCamera,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('चेहरा स्कैन करें', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 3. CAMERA SCANNER SCREEN ----------------
class ScannerScreen extends StatefulWidget {
  final String studentId;
  const ScannerScreen({super.key, required this.studentId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    CameraDescription selectedCam = cameras.first;
    for (var cam in cameras) {
      if (cam.lensDirection == CameraLensDirection.front) {
        selectedCam = cam;
        break;
      }
    }

    _cameraController = CameraController(selectedCam, ResolutionPreset.medium, enableAudio: false);
    try {
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _markAttendance(String status) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status == 'PRESENT' ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: status == 'PRESENT' ? Colors.green : Colors.red,
              size: 65,
            ),
            const SizedBox(height: 12),
            Text(
              status == 'PRESENT' ? 'Present मार्क हुआ!' : 'Absent मार्क हुआ!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('ID: ${widget.studentId}', style: const TextStyle(fontSize: 15)),
            Text(
              'समय: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('ठीक है'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Student ID: ${widget.studentId}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                Center(
                  child: Container(
                    width: 240,
                    height: 310,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2.5),
                      borderRadius: const BorderRadius.all(Radius.elliptical(240, 310)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  
