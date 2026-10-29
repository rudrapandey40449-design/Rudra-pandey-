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
      title: 'Smart Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();

  void _login() {
    if (_pinController.text.trim() == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('गलत पिन! (पिन: 1234)'), backgroundColor: Colors.red),
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
              const Icon(Icons.school, size: 70, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('कोचिंग एवं अटेंडेंस पोर्टल', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('एडमिन पिन (1234) दर्ज करें', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(onPressed: _login, child: const Text('लॉगिन करें')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade400]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('आज की दिनांक', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(today, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _btn(context, 'हाजिरी दर्ज करें (Attendance)', Icons.how_to_reg, Colors.teal, const MarkAttendanceScreen()),
          _btn(context, 'मासिक फीस ट्रैकर (Fees)', Icons.currency_rupee, Colors.green, const FeeManagementScreen()),
          _btn(context, 'टेस्ट अंक (Test Marks)', Icons.assignment_turned_in, Colors.deepPurple, const TestMarksScreen()),
          _btn(context, 'नया छात्र जोड़ें (Add Student)', Icons.person_add, Colors.blue, const AddStudentScreen()),
          _btn(context, 'छात्र रिपोर्ट (Profile Search)', Icons.badge, Colors.orange, const StudentProfileSearchScreen()),
        ],
      ),
    );
  }

  Widget _btn(BuildContext ctx, String title, IconData icon, Color color, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _name = TextEditingController();
  final _roll = TextEditingController();
  final _class = TextEditingController();

  Future<void> _save() async {
    final name = _name.text.trim();
    final roll = _roll.text.trim();
    if (name.isEmpty || roll.isEmpty) return;

    await FirebaseFirestore.instance.collection('students').doc(roll).set({
      'name': name,
      'roll': roll,
      'class': _class.text.trim().isEmpty ? '11th' : _class.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया छात्र जोड़ें')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _roll, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'रोल नंबर', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _class, decoration: const InputDecoration(labelText: 'कक्षा / विषय', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(onPressed: _save, child: const Text('सेव करें')),
            ),
          ],
        ),
      ),
    );
  }
}

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});
  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final Map<String, bool> _status = {};

  Future<void> _submit() async {
    final batch = FirebaseFirestore.instance.batch();
    _status.forEach((roll, isPres) {
      final doc = FirebaseFirestore.instance.collection('attendance').doc('$dateKey-$roll');
      batch.set(doc, {'date': dateKey, 'roll': roll, 'status': isPres ? 'Present' : 'Absent'});
    });
    await batch.commit();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('हाजिरी ($dateKey)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!.docs;
          for (var doc in list) {
            _status.putIfAbsent(doc['roll'].toString(), () => true);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final d = list[i].data() as Map<String, dynamic>;
                    final roll = d['roll'].toString();
                    final isPres = _status[roll] ?? true;
                    return ListTile(
                      leading: CircleAvatar(child: Text(roll)),
                      title: Text(d['name'] ?? ''),
                      trailing: FilterChip(
                        label: Text(isPres ? 'Present' : 'Absent'),
                        selected: isPres,
                        onSelected: (val) => setState(() => _status[roll] = val),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(onPressed: _submit, child: const Text('सुरक्षित करें')),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final curMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text('फीस ($curMonth)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (ctx, snap1) {
          if (!snap1.hasData) return const Center(child: CircularProgressIndicator());
          final students = snap1.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('fees').where('month', isEqualTo: curMonth).snapshots(),
            builder: (ctx, snap2) {
              if (!snap2.hasData) return const Center(child: CircularProgressIndicator());
              final Map<String, bool> feeMap = {};
              for (var doc in snap2.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                feeMap[d['roll'].toString()] = d['isPaid'] ?? false;
              }

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (ctx, i) {
                  final s = students[i].data() as Map<String, dynamic>;
                  final roll = s['roll'].toString();
                  final isPaid = feeMap[roll] ?? false;

                  return ListTile(
                    leading: CircleAvatar(child: Text(roll)),
                    title: Text(s['name'] ?? ''),
                    subtitle: Text(isPaid ? 'जमा (Paid)' : 'बाकी (Pending)'),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        FirebaseFirestore.instance.collection('fees').doc('$curMonth-$roll').set({
                          'month': curMonth,
                          'roll': roll,
                          'isPaid': !isPaid,
                        });
                      },
                      child: Text(isPaid ? 'Paid ✔' : 'Pending ✖'),
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

class TestMarksScreen extends StatefulWidget {
  const TestMarksScreen({super.key});
  @override
  State<TestMarksScreen> createState() => _TestMarksScreenState();
}

class _TestMarksScreenState extends State<TestMarksScreen> {
  final _testName = TextEditingController(text: '15-Day Test');
  final _total = TextEditingController(text: '50');
  final Map<String, TextEditingController> _inputs = {};

  Future<void> _save(List<QueryDocumentSnapshot> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var d in docs) {
      final roll = d['roll'].toString();
      final marks = _inputs[roll]?.text.trim() ?? '0';
      final docRef = FirebaseFirestore.instance.collection('tests').doc();
      batch.set(docRef, {
        'testName': _testName.text.trim(),

        
