import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCyezv6VO44lOP-wDRCNYuOHZ-wFtDycpk',
        appId: '1:152984908526:android:78031fe79787a96224b9ff',
        messagingSenderId: '152984908526',
        projectId: 'attendance-app-9ac46',
      ),
    );
  } catch (_) {}
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 70, color: Colors.indigo),
              const SizedBox(height: 10),
              const Text('कोचिंग पोर्टल (पिन: 1234)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '••••', counterText: ''),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  if (_pin.text.trim() == '1234') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पिन!')));
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
        padding: const EdgeInsets.all(12),
        children: [
          _btn(context, 'हाजिरी दर्ज करें (Attendance)', Icons.how_to_reg, Colors.teal, const AttendanceScreen()),
          _btn(context, 'मासिक फीस ट्रैकर (Fees)', Icons.currency_rupee, Colors.green, const FeeScreen()),
          _btn(context, 'टेस्ट अंक (Test Marks)', Icons.assignment_turned_in, Colors.deepPurple, const TestScreen()),
          _btn(context, 'नया छात्र जोड़ें (Add Student)', Icons.person_add, Colors.blue, const AddStudentScreen()),
          _btn(context, 'छात्र प्रोफ़ाइल खोजें (Search)', Icons.search, Colors.orange, const ProfileSearchScreen()),
        ],
      ),
    );
  }

  Widget _btn(BuildContext c, String t, IconData i, Color cl, Widget p) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(i, color: cl),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => p)),
    ),
  );
}

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _n = TextEditingController(), _r = TextEditingController(), _p = TextEditingController();
  final _f = TextEditingController(), _c = TextEditingController(), _a = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया छात्र जोड़ें')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _n, decoration: const InputDecoration(labelText: 'छात्र का नाम *')),
          TextField(controller: _r, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'रोल नंबर *')),
          TextField(controller: _p, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'मोबाइल नंबर')),
          TextField(controller: _f, decoration: const InputDecoration(labelText: 'पिता का नाम')),
          TextField(controller: _c, decoration: const InputDecoration(labelText: 'कक्षा / बैच')),
          TextField(controller: _a, decoration: const InputDecoration(labelText: 'पता (गाँव/शहर)')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_n.text.isNotEmpty && _r.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('students').doc(_r.text.trim()).set({
                  'name': _n.text.trim(),
                  'roll': _r.text.trim(),
                  'phone': _p.text.trim(),
                  'father': _f.text.trim(),
                  'class': _c.text.trim().isEmpty ? 'Class 11' : _c.text.trim(),
                  'address': _a.text.trim(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('डेटाबेस में सुरक्षित करें'),
          )
        ],
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
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!.docs;
          if (list.isEmpty) return const Center(child: Text('कोई छात्र नहीं मिला। पहले नया छात्र जोड़ें।'));
          for (var d in list) { _st.putIfAbsent(d['roll'].toString(), () => true); }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final r = list[i]['roll'].toString();
                    return CheckboxListTile(
                      title: Text('${list[i]['name']} (रोल: $r)'),
                      value: _st[r] ?? true,
                      onChanged: (v) => setState(() => _st[r] = v ?? true),
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
                  child: const Text('हाजिरी सुरक्षित करें'),
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
          if (s1.data!.docs.isEmpty) return const Center(child: Text('कोई छात्र नहीं मिला।'));
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('fees').where('month', isEqualTo: m).snapshots(),
            builder: (ctx, s2) {
              final feeMap = {for (var d in (s2.data?.docs ?? [])) d['roll'].toString(): d['isPaid'] == true};
              return ListView.builder(
                itemCount: s1.data!.docs.length,
                itemBuilder: (c, i) {
                  final r = s1.data!.docs[i]['roll'].toString();
                  final p = feeMap[r] ?? false;
                  return ListTile(
                    title: Text(s1.data!.docs[i]['name'] ?? ''),
                    subtitle: Text('रोल: $r | ${p ? "जमा (Paid)" : "बाकी (Pending)"}'),
                    trailing: ElevatedButton(
                      onPressed: () => FirebaseFirestore.instance.collection('fees').doc('$m-$r').set({'month': m, 'roll': r, 'isPaid': !p}),
                      child: Text(p ? 'Paid ✔' : 'Pending ✖'),
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
  final _t = TextEditingController(text: '15-Day Test'), _tot = TextEditingController(text: '50');
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
          if (docs.isEmpty) return const Center(child: Text('कोई छात्र नहीं मिला।'));
          for (var d in docs) { _m.putIfAbsent(d['roll'].toString(), () => TextEditingController(text: '0')); }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _t, decoration: const InputDecoration(labelText: 'टेस्ट'))),
                    const SizedBox(width: 8),
                    SizedBox(width: 80, child: TextField(controller: _tot, decoration: const InputDecoration(labelText: 'पूर्णांक'))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
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
                      'testName': _t.text,
                      'totalMarks': _tot.text,
                      'obtainedMarks': _m[r]?.text ?? '0',
                      'roll': r,
                      'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
                    });
                  }
                  await b.commit();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('अंक सुरक्षित करें'),
              )
            ],
          );
        },
      ),
    );
  }
}

class ProfileSearchScreen extends StatefulWidget {
  const ProfileSearchScreen({super.key});
  @override
  State<ProfileSearchScreen> createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  final _s = TextEditingController();
  String? _roll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('छात्र प्रोफ़ाइल')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _s, decoration: const InputDecoration(labelText: 'रोल नंबर दर्ज करें'))),
                IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _roll = _s.text.trim())),
              ],
            ),
            if (_roll != null && _roll!.isNotEmpty)
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('students').doc(_roll).snapshots(),
                  builder: (ctx, s1) {
                    if (!s1.hasData || !s1.data!.exists) return const Center(child: Text('छात्र नहीं मिला।'));
                    final d = s1.data!.data() as Map<String, dynamic>;
                    return ListView(
                      children: [
                        ListTile(
                          title: Text(d['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text('रोल: ${d['roll']}\nकक्षा: ${d['class']}\nमोबाइल: ${d['phone'] ?? "नहीं"}\nपिता: ${d['father'] ?? "नहीं"}\nपता: ${d['address'] ?? "नहीं"}'),
                        ),
                        const Divider(),
                        const Text('टेस्ट रिकॉर्ड्स:', style: TextStyle(fontWeight: FontWeight.bold)),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('tests').where('roll', isEqualTo: _roll).snapshots(),
                          builder: (ctx, s2) {
                            if (!s2.hasData) return const SizedBox();
                            return Column(
                              children: s2.data!.docs.map((doc) => ListTile(
                                title: Text(doc['testName'] ?? 'Test'),
                                subtitle: Text('दिनांक: ${doc['date']}'),
                                trailing: Text('${doc['obtainedMarks']} / ${doc['totalMarks']}'),
                              )).toList(),
                            );
                          },
                        )
                      ],
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
