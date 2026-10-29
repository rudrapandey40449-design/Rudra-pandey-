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
      title: 'Smart Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
    );
  }
}

// ---------------- 1. LOGIN SCREEN ----------------
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
        const SnackBar(
          content: Text('गलत पिन! सही पिन 1234 दर्ज करें'),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, size: 64, color: Colors.indigo),
              ),
              const SizedBox(height: 20),
              const Text(
                'कोचिंग एवं अटेंडेंस पोर्टल',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('एडमिन पिन दर्ज करें (Default: 1234)', style: TextStyle(color: Colors.grey)),
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
                child: FilledButton(
                  onPressed: _login,
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

// ---------------- 2. DASHBOARD ----------------
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              ),
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
          _MenuTile(
            title: 'उपस्थिति दर्ज करें (Attendance)',
            icon: Icons.how_to_reg,
            color: Colors.teal,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkAttendanceScreen())),
          ),
          _MenuTile(
            title: 'मासिक फीस ट्रैकर (Fees)',
            icon: Icons.currency_rupee,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeManagementScreen())),
          ),
          _MenuTile(
            title: 'टेस्ट अंक (Test Marks)',
            icon: Icons.assignment_turned_in,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestMarksScreen())),
          ),
          _MenuTile(
            title: 'नया छात्र जोड़ें (Add Student)',
            icon: Icons.person_add,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
          ),
          _MenuTile(
            title: 'छात्र रिपोर्ट कार्ड (Profile)',
            icon: Icons.badge,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileSearchScreen())),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ---------------- 3. ADD STUDENT ----------------
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _name = TextEditingController();
  final _roll = TextEditingController();
  final _class = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    final name = _name.text.trim();
    final roll = _roll.text.trim();
    if (name.isEmpty || roll.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('नाम और रोल नंबर भरें!')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(roll).set({
        'name': name,
        'roll': roll,
        'class': _class.text.trim().isEmpty ? '11th' : _class.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('छात्र सेव हो गया!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'छात्र का नाम', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: _roll, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'रोल नंबर', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: _class, decoration: const InputDecoration(labelText: 'कक्षा / विषय', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('सेव करें'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- 4. ATTENDANCE ----------------
class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final Map<String, bool> _status = {};
  bool _saving = false;

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      _status.forEach((roll, isPresent) {
        final doc = FirebaseFirestore.instance.collection('attendance').doc('$todayStr-$roll');
        batch.set(doc, {
          'date': todayStr,
          'roll': roll,
          'status': isPresent ? 'Present' : 'Absent',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('हाजिरी सुरक्षित हो गई!')));
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
      appBar: AppBar(title: Text('हाजिरी ($todayStr)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!.docs;
          if (list.isEmpty) return const Center(child: Text('कोई छात्र मौजूद नहीं है।'));

          for (var doc in list) {
            _status.putIfAbsent(doc['roll'].toString(), () => true);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final d = list[i].data() as Map<String, dynamic>;
                    final roll = d['roll'].toString();
                    final name = d['name'] ?? '';
                    final isPresent = _status[roll] ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(roll)),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: FilterChip(
                          label: Text(isPresent ? 'Present' : 'Absent'),
                          selected: isPresent,
                          selectedColor: Colors.green.shade100,
                          onSelected: (val) => setState(() => _status[roll] = val),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('सुरक्षित करें'),
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

// ---------------- 5. FEES MANAGEMENT ----------------
class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  final String curMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  Future<void> _toggle(String roll, bool current) async {
    await FirebaseFirestore.instance.collection('fees').doc('$curMonth-$roll').set({
      'month': curMonth,
      'roll': roll,
      'isPaid': !current,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('फीस ($curMonth)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snap1) {
          if (!snap1.hasData) return const Center(child: CircularProgressIndicator());
          final students = snap1.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('fees').where('month', isEqualTo: curMonth).snapshots(),
            builder: (context, snap2) {
              if (!snap2.hasData) return const Center(child: CircularProgressIndicator());
              final Map<String, bool> feeMap = {};
              for (var doc in snap2.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                feeMap[d['roll'].toString()] = d['isPaid'] ?? false;
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
                      subtitle: Text(isPaid ? 'जमा (Paid)' : 'बाकी (Pending)'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaid ? Colors.green.shade100 : Colors.red.shade100,
                        ),
                        onPressed: () => _toggle(roll, isPaid),
                        child: Text(isPaid ? 'Paid' : 'Pending', style: TextStyle(color: isPaid ? Colors.green.shade900 : Colors.red.shade900)),
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

// ---------------- 6. TEST MARKS ----------------
class TestMarksScreen extends StatefulWidget {
  const TestMarksScreen({super.key});

  @override
  State<TestMarksScreen> createState() => _TestMarksScreenState();
}

class _TestMarksScreenState extends State<TestMarksScreen> {
  final _testName = TextEditingController(text: 'Monthly Test');
  final _total = TextEditingController(text: '50');
  final Map<String, TextEditingController> _inputs = {};
  bool _saving = false;

  Future<void> _save(List<QueryDocumentSnapshot> docs) async {
    final tName = _testName.text.trim();
    final tTotal = _total.text.trim();
    if (tName.isEmpty || tTotal.isEmpty) return;

    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var d in docs) {
        final roll = d['roll'].toString();
        final marks = _inputs[roll]?.text.trim() ?? '0';
        final docRef = FirebaseFirestore.instance.collection('tests').doc();
        batch.set(docRef, {
          'testName': tName,
          'totalMarks': tTotal,
          'obtainedMarks': marks,
          'roll': roll,
          'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('अंक सुरक्षित हो गए!')));
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
      appBar: AppBar(title: const Text('टेस्ट अंक भरें')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;

          for (var d in docs) {
            _inputs.putIfAbsent(d['roll'].toString(), () => TextEditingController(text: '0'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _testName, decoration: const InputDecoration(labelText: 'टेस्ट नाम', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    SizedBox(width: 90, child: TextField(controller: _total, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'पूर्णांक', border: OutlineInputBorder()))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final roll = d['roll'].toString();
                    return ListTile(
                      leading: CircleAvatar(child: Text(roll)),
                      title: Text(d['name'] ?? ''),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _inputs[roll],
                          keyboardType: 
