import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (_) {}
  runApp(const MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pin = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 70, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('कोचिंग पोर्टल (पिन: 1234)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 12),
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '••••', counterText: ''),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_pin.text.trim() == '1234') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पिन! 1234 दर्ज करें')));
                  }
                },
                child: const Text('लॉगिन करें'),
              )
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
    return Scaffold(
      appBar: AppBar(title: const Text('डैशबोर्ड')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, 'हाजिरी दर्ज करें (Attendance)', Icons.how_to_reg, Colors.teal, const AttendanceScreen()),
          _tile(context, 'मासिक फीस ट्रैकर (Fees)', Icons.currency_rupee, Colors.green, const FeeScreen()),
          _tile(context, 'टेस्ट अंक (Test Marks)', Icons.assignment_turned_in, Colors.deepPurple, const TestScreen()),
          _tile(context, 'नया छात्र जोड़ें (Add Student)', Icons.person_add, Colors.blue, const AddStudentScreen()),
          _tile(context, 'छात्र रिपोर्ट (Profile Search)', Icons.badge, Colors.orange, const StudentProfileSearchScreen()),
        ],
      ),
    );
  }

  Widget _tile(BuildContext ctx, String title, IconData icon, Color color, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
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
  final _n = TextEditingController(), _r = TextEditingController(), _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया छात्र जोड़ें')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _n, decoration: const InputDecoration(labelText: 'छात्र का नाम')),
            TextField(controller: _r, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'रोल नंबर')),
            TextField(controller: _c, decoration: const InputDecoration(labelText: 'कक्षा / विषय')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_n.text.isNotEmpty && _r.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('students').doc(_r.text.trim()).set({
                    'name': _n.text.trim(),
                    'roll': _r.text.trim(),
                    'class': _c.text.trim().isEmpty ? '11th' : _c.text.trim(),
                  });
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('सेव करें'),
            )
          ],
        ),
      ),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final dKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final Map<String, bool> _st = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('हाजिरी ($dKey)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!.docs;
          for (var d in list) { _st.putIfAbsent(d['roll'].toString(), () => true); }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final roll = list[i]['roll'].toString();
                    return CheckboxListTile(
                      title: Text('${list[i]['name']} (रोल: $roll)'),
                      value: _st[roll] ?? true,
                      onChanged: (v) => setState(() => _st[roll] = v ?? true),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () async {
                    final b = FirebaseFirestore.instance.batch();
                    _st.forEach((r, p) {
                      b.set(FirebaseFirestore.instance.collection('attendance').doc('$dKey-$r'), {'date': dKey, 'roll': r, 'status': p ? 'Present' : 'Absent'});
                    });
                    await b.commit();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('सुरक्षित करें'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class FeeScreen extends StatelessWidget {
  const FeeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final m = DateFormat('MMMM yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text('फीस ($m)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (ctx, s1) {
          if (!s1.hasData) return const Center(child: CircularProgressIndicator());
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('fees').where('month', isEqualTo: m).snapshots(),
            builder: (ctx, s2) {
              if (!s2.hasData) return const Center(child: CircularProgressIndicator());
              final fMap = {for (var d in s2.data!.docs) d['roll'].toString(): d['isPaid'] == true};
              return ListView.builder(
                itemCount: s1.data!.docs.length,
                itemBuilder: (ctx, i) {
                  final r = s1.data!.docs[i]['roll'].toString();
                  final paid = fMap[r] ?? false;
                  return ListTile(
                    title: Text(s1.data!.docs[i]['name'] ?? ''),
                    subtitle: Text('रोल: $r | ${paid ? "Paid" : "Pending"}'),
                    trailing: ElevatedButton(
                      onPressed: () => FirebaseFirestore.instance.collection('fees').doc('$m-$r').set({'month': m, 'roll': r, 'isPaid': !paid}),
                      child: Text(paid ? 'Paid ✔' : 'Pending ✖'),
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

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _tName = TextEditingController(text: 'Monthly Test'), _tot = TextEditingController(text: '50');
  final Map<String, TextEditingController> _m = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('टेस्ट अंक')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          for (var d in docs) { _m.putIfAbsent(d['roll'].toString(), () => TextEditingController(text: '0')); }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _tName, decoration: const InputDecoration(labelText: 'टेस्ट'))),
                    const SizedBox(width: 8),
                    SizedBox(width: 80, child: TextField(controller: _tot, decoration: const InputDecoration(labelText: 'पूर्णांक'))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final r = docs[i]['roll'].toString();
                    return ListTile(
                      title: Text('${docs[i]['name']} (रोल: $r)'),
                      trailing: SizedBox(width: 60, child: TextField(controller: _m[r], keyboardType: TextInputType.number)),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final b = FirebaseFirestore.instance.batch();
                  for (var d in docs) {
                    final r = d['roll'].toString();
                    b.set(FirebaseFirestore.instance.collection('tests').doc(), {
                      'testName': _tName.text,
                      'totalMarks': _tot.text,
                      'obtainedMarks': _m[r]?.text ?? '0',
                      'roll': r,
                      'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
                    });
                  }
                  await b.commit();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('सुरक्षित करें'),
              )
            ],
          );
        },
      ),
    );
  }
}

class StudentProfileSearchScreen extends StatefulWidget {
  const StudentProfileSearchScreen({super.key});
  @override
  State<StudentProfileSearchScreen> createState() => _StudentProfileSearchScreenState();
}

class _StudentProfileSearchScreenState extends State<StudentProfileSearchScreen> {
  final _s = TextEditingController();
  String? _roll;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('छात्र रिपोर्ट')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _s, decoration: const InputDecoration(labelText: 'रोल नंबर'))),
                IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _roll = _s.text.trim())),
              ],
            ),
            if (_roll != null && _roll!.isNotEmpty)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('tests').where('roll', isEqualTo: _roll).snapshots(),
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                    if (snap.data!.docs.isEmpty) return const Center(child: Text('कोई रिकॉर्ड नहीं मिला'));
                    return ListView.builder(
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (ctx, i) {
                        final t = snap.data!.docs[i].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(t['testName'] ?? 'Test'),
                          subtitle: Text('दिनांक: ${t['date']}'),
                          trailing: Text('${t['obtainedMarks']} / ${t['totalMarks']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
