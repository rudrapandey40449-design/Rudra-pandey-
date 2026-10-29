import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const AdminLoginScreen(),
    );
  }
}

// ---------------- ADMIN LOGIN ----------------
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();
  final String _adminPin = "1234"; // डिफ़ॉल्ट एडमिन पिन

  void _login() {
    if (_pinController.text.trim() == _adminPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('गलत पिन! कृपया सही एडमिन पिन डालें।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security, size: 70, color: Colors.indigo),
              ),
              const SizedBox(height: 24),
              const Text(
                'एडमिन लॉगिन',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'अटेंडेंस पोर्टल में प्रवेश के लिए पिन दर्ज करें',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "••••",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _login,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('प्रवेश करें (Login)', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- DASHBOARD ----------------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Attendance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.indigo.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('आज की तारीख', style: TextStyle(color: Colors.white70)),
                Text(today, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _DashboardCard(
            title: 'उपस्थिति दर्ज करें (Mark Attendance)',
            subtitle: 'छात्रों की आज की उपस्थिति मार्क करें',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkAttendanceScreen())),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'नए छात्र जोड़ें (Add Student)',
            subtitle: 'छात्र का नाम, रोल नंबर व क्लास ऑनलाइन सेव करें',
            icon: Icons.person_add_alt_1,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'उपस्थिति रिकॉर्ड (Attendance History)',
            subtitle: 'पुरानी तारीखों का पूरा रिकॉर्ड देखें',
            icon: Icons.history,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ---------------- ADD STUDENT ----------------
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _classController = TextEditingController();
  bool _saving = false;

  Future<void> _saveStudent() async {
    final name = _nameController.text.trim();
    final roll = _rollController.text.trim();
    final studentClass = _classController.text.trim();

    if (name.isEmpty || roll.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया नाम और रोल नंबर दर्ज करें!')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(roll).set({
        'name': name,
        'roll': roll,
        'class': studentClass.isEmpty ? 'Class 11' : studentClass,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('छात्र ऑनलाइन सुरक्षित सेव हो गया!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('एरर: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया छात्र जोड़ें')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'छात्र का नाम', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rollController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'रोल नंबर (Unique ID)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _classController,
              decoration: const InputDecoration(labelText: 'कक्षा / क्लास', hintText: 'उदा. 11th Science', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saving ? null : _saveStudent,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('डेटाबेस में सेव करें'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- MARK ATTENDANCE ----------------
class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final Map<String, bool> _attendanceStatus = {};
  bool _saving = false;

  Future<void> _submitAttendance() async {
    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      _attendanceStatus.forEach((roll, isPresent) {
        final docRef = FirebaseFirestore.instance
            .collection('attendance')
            .doc('$dateKey-$roll');
        batch.set(docRef, {
          'date': dateKey,
          'roll': roll,
          'status': isPresent ? 'Present' : 'Absent',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('आज की उपस्थिति ऑनलाइन सबमिट हो गई!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('एरर: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('उपस्थिति ($dateKey)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('कोई छात्र नहीं मिला। कृपया पहले छात्र जोड़ें।'),
            );
          }

          for (var doc in docs) {
            final roll = doc['roll'].toString();
            _attendanceStatus.putIfAbsent(roll, () => true);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final roll = data['roll'].toString();
                    final name = data['name'] ?? '';
                    final isPresent = _attendanceStatus[roll] ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(roll)),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Class: ${data['class'] ?? ''}'),
                        trailing: FilterChip(
                          label: Text(isPresent ? 'Present' : 'Absent'),
                          selected: isPresent,
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.green,
                          onSelected: (val) {
                            setState(() {
                              _attendanceStatus[roll] = val;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: _saving ? null : _submitAttendance,
                    label: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('उपस्थिति सेव करें'),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

// ---------------- HISTORY SCREEN ----------------
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('उपस्थिति रिकॉर्ड (History)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('अभी तक कोई उपस्थिति रिकॉर्ड नहीं है।'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = data['date'] ?? '';
              final roll = data['roll'] ?? '';
              final status = data['status'] ?? 'Absent';
              final isPresent = status == 'Present';

              return ListTile(
                leading: Icon(
                  isPresent ? Icons.check_circle : Icons.cancel,
                  color: isPresent ? Colors.green : Colors.red,
                ),
                title: Text('Roll No: $roll | $status'),
                subtitle: Text('Date: $date'),
              );
            },
          );
        },
      ),
    );
  }
}
