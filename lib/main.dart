import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init: $e");
  }
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance & Coaching Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
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
  final String _adminPin = "1234";

  void _login() {
    if (_pinController.text.trim() == _adminPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('गलत पिन! सही एडमिन पिन दर्ज करें (Default: 1234)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, size: 70, color: Colors.indigo),
              ),
              const SizedBox(height: 24),
              const Text(
                'कोचिंग एवं अटेंडेंस पोर्टल',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('एडमिन पिन दर्ज करें', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, letterSpacing: 16),
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
                  child: const Text('लॉगिन करें', style: TextStyle(fontSize: 16)),
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
    final today = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('डैशबोर्ड'),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('आज की दिनांक', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(today, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuCard(
            title: 'उपस्थिति दर्ज करें (Mark Attendance)',
            subtitle: 'छात्रों की आज की हाजिरी लगाएँ',
            icon: Icons.how_to_reg,
            color: Colors.teal,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkAttendanceScreen())),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            title: 'मासिक फीस ट्रैकर (Fee Management)',
            subtitle: 'किस छात्र की फीस आई, किसकी बाकी है',
            icon: Icons.currency_rupee,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeManagementScreen())),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            title: 'टेस्ट रिज़ल्ट (Test Marks)',
            subtitle: '15 दिन या मासिक टेस्ट के अंक रोल नंबर पर जोड़ें',
            icon: Icons.assignment_turned_in,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestMarksScreen())),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            title: 'नया छात्र जोड़ें (Add Student)',
            subtitle: 'छात्र का नाम, रोल नंबर व क्लास सेव करें',
            icon: Icons.person_add,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            title: 'छात्र रिपोर्ट कार्ड (Student Profile)',
            subtitle: 'अटेंडेंस, टेस्ट मार्क्स और फीस रिकॉर्ड देखें',
            icon: Icons.badge,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileSearchScreen())),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    final sClass = _classController.text.trim();

    if (name.isEmpty || roll.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('नाम और रोल नंबर अनिवार्य हैं!')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(roll).set({
        'name': name,
        'roll': roll,
        'class': sClass.isEmpty ? '11th' : sClass,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('छात्र सफलतापूर्वक सेव हो गया!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              decoration: const InputDecoration(labelText: 'रोल नंबर', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _classController,
              decoration: const InputDecoration(labelText: 'कक्षा / विषय', hintText: 'उदा. 11th Science', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saving ? null : _saveStudent,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('डेटाबेस में सुरक्षित करें'),
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
  final Map<String, bool> _attendance = {};
  bool _saving = false;

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      _attendance.forEach((roll, isPresent) {
        final ref = FirebaseFirestore.instance.collection('attendance').doc('$dateKey-$roll');
        batch.set(ref, {
          'date': dateKey,
          'roll': roll,
          'status': isPresent ? 'Present' : 'Absent',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('आज की हाजिरी सेव हो गई!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('हाजिरी ($dateKey)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('कोई छात्र नहीं मिला। पहले छात्र जोड़ें।'));
          }

          for (var doc in docs) {
            final roll = doc['roll'].toString();
            _attendance.putIfAbsent(roll, () => true);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final roll = d['roll'].toString();
                    final name = d['name'] ?? '';
                    final isPresent = _attendance[roll] ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(roll)),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: FilterChip(
                          label: Text(isPresent ? 'Present' : 'Absent'),
                          selected: isPresent,
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.green,
                          onSelected: (val) => setState(() => _attendance[roll] = val),
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
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('हाजिरी सुरक्षित करें'),
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

// ---------------- FEES MANAGEMENT ----------------
class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  final String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  Future<void> _toggleFee(String roll, bool currentStatus) async {
    final docId = '$currentMonth-$roll';
    await FirebaseFirestore.instance.collection('fees').doc(docId).set({
      'month': currentMonth,
      'roll': roll,
      'isPaid': !currentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('फीस रिकॉर्ड ($currentMonth)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, studentSnap) {
          if (!studentSnap.hasData) return const Center(child: CircularProgressIndicator());
          final students = studentSnap.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('fees')
                .where('month', isEqualTo: currentMonth)
                .snapshots(),
            builder: (context, feeSnap) {
              if (!feeSnap.hasData) return const Center(child: CircularProgressIndicator());

              final Map<String, bool> feeMap = {};
              for (var doc in feeSnap.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                feeMap[data['roll'].toString()] = data['isPaid'] ?? false;
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                itemBuilder: (context, i) {
                  final s = students[i].data() as Map<String, dynamic>;
                  final roll = s['roll'].toString();
                  final name = s['name'] ?? '';
                  final isPaid = feeMap[roll] ?? false;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(roll)),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('स्थिति: ${isPaid ? "जमा (Paid)" : "बाकी (Pending)"}'),
                      trailing: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: isPaid ? Colors.green.shade100 : Colors.red.shade100,
                        ),
                        onPressed: () => _toggleFee(roll, isPaid),
                        child: Text(
                          isPaid ? 'Paid ✔' : 'Pending ✖',
                          style: TextStyle(
                            color: isPaid ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- TEST MARKS ----------------
class TestMarksScreen extends StatefulWidget {
  const TestMarksScreen({super.key});

  @override
  State<TestMarksScreen> createState() => _TestMarksScreenState();
}

class _TestMarksScreenState extends State<TestMarksScreen> {
  final _testNameController = TextEditingController(text: '15-Day Test');
  final _totalMarksController = TextEditingController(text: '50');
  final Map<String, TextEditingController> _marksInputs = {};
  bool _saving = false;

  Future<void> _saveMarks(List<QueryDocumentSnapshot> docs) async {
    final testName = _testNameController.text.trim();
    final totalMarks = _totalMarksController.text.trim();

    if (testName.isEmpty || totalMarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('टेस्ट का नाम और कुल अंक भरें!')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var d in docs) {
        final roll = d['roll'].toString();
        final obtained = _marksInputs[roll]?.text.trim() ?? '0';

        final ref = FirebaseFirestore.instance.collection('tests').doc();
        batch.set(ref, {
          'testName': testName,
          'totalMarks': totalMarks,
          'obtainedMarks': obtained,
          'roll': roll,
          'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('सभी टे
