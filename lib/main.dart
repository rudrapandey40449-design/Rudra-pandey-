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

// ---------------- 1. DASHBOARD ----------------
class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Smart Attendance Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome to Attendance Portal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('छात्र उपस्थिति, प्रोफाइल और आईडी कार्ड प्रबंधन', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('मुख्य सेवाएं (Services)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  _menuItem(context, 'Mark Attendance', 'हाजिरी लगाएं (Face)', Icons.camera_front, Colors.deepPurple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AttendanceInputScreen()));
                  }),
                  _menuItem(context, 'Register Student', 'नया छात्र जोड़ें', Icons.person_add, Colors.blue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterStudentScreen()));
                  }),
                  _menuItem(context, 'Update Details', 'जानकारी बदलें', Icons.edit_note, Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const UpdateStudentScreen()));
                  }),
                  _menuItem(context, 'Student ID Card', 'आईडी कार्ड देखें', Icons.badge, Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const StudentIdCardScreen()));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// ---------------- 2. ATTENDANCE INPUT ----------------
class AttendanceInputScreen extends StatefulWidget {
  const AttendanceInputScreen({super.key});

  @override
  State<AttendanceInputScreen> createState() => _AttendanceInputScreenState();
}

class _AttendanceInputScreenState extends State<AttendanceInputScreen> {
  final TextEditingController _idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.face_retouching_natural, size: 70, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text('छात्र उपस्थिति दर्ज करें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _idCtrl,
              decoration: InputDecoration(
                labelText: 'Student Roll No / ID',
                hintText: 'उदा. STU-01, 101, या 1',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  String id = _idCtrl.text.trim();
                  if (id.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया रोल नंबर दर्ज करें!'), backgroundColor: Colors.red));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (c) => ScannerScreen(studentId: id)));
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('चेहरा स्कैन करें', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 3. SCANNER SCREEN ----------------
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
      debugPrint("Camera error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _recordStatus(String status) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(status == 'PRESENT' ? 'Present दर्ज!' : 'Absent दर्ज!'),
        content: Text('ID: ${widget.studentId}\nStatus: $status'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('ID: ${widget.studentId}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                Center(child: CameraPreview(_cameraController!)),
                Center(
                  child: Container(
                    width: 230,
                    height: 290,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2),
                      borderRadius: const BorderRadius.all(Radius.elliptical(230, 290)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () => _recordStatus('ABSENT'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Absent', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () => _recordStatus('PRESENT'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Present', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------- 4. REGISTER STUDENT ----------------
class RegisterStudentScreen extends StatelessWidget {
  const RegisterStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Student')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Student Full Name', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Roll Number', prefixIcon: Icon(Icons.numbers))),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Class / Course', prefixIcon: Icon(Icons.school))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('छात्र रजिस्टर हो गया!'), backgroundColor: Colors.green));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('सेव करें', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 5. UPDATE DETAILS ----------------
class UpdateStudentScreen extends StatelessWidget {
  const UpdateStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Details')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: TextField(
          decoration: InputDecoration(labelText: 'Roll No दर्ज करें', suffixIcon: Icon(Icons.search)),
        ),
      ),
    );
  }
}

// ---------------- 6. STUDENT ID CARD ----------------
class StudentIdCardScreen extends StatelessWidget {
  const StudentIdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student ID Card')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 36, child: Icon(Icons.person, size: 40)),
                SizedBox(height: 12),
                Text('Aman Pandey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Roll No: STU-101', style: TextStyle(color: Colors.grey)),
                Text('Class: 11th Science', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 12),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status: Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Icon(Icons.qr_code, size: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

