import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coaching Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      ),
      home: const LoginScreen(),
    );
  }
}

// 1. LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pin = TextEditingController();

  void _login() {
    if (_pin.text.trim() == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('गलत पिन! सही पिन 1234 दर्ज करें'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.school, size: 64, color: Colors.indigo),
              ),
              const SizedBox(height: 18),
              const Text('कोचिंग पोर्टल', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('एडमिन पिन: 1234', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 14),
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _login,
                  child: const Text('लॉगिन करें', style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 2. DASHBOARD
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
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.indigo.shade500]),
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
          _btn(context, 'हाजिरी दर्ज करें (Attendance)', Icons.how_to_reg, Colors.teal, const AttendanceScreen()),
          _btn(context, 'मासिक फीस ट्रैकर (Fees)', Icons.currency_rupee, Colors.green, const FeeScreen()),
          _btn(context, 'टेस्ट अंक (Test Marks)', Icons.assignment_turned_in, Colors.deepPurple, const TestScreen()),
          _btn(context, 'नया छात्र जोड़ें (Add Student)', Icons.person_add, Colors.blue, const AddStudentScreen()),
          _btn(context, 'छात्र प्रोफ़ाइल खोजें (Search)', Icons.search, Colors.orange, const StudentProfileSearchScreen()),
        ],
      ),
    );
  }

  Widget _btn(BuildContext ctx, String title, IconData icon, Color color, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

// 3. ADD STUDENT (FULL DETAILS)
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _name = TextEditingController();
  final _roll = TextEditingController();
  final _phone = TextEditingController();
  final _father = TextEditingController();
  final _class = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    final name = _name.text.trim();
    final roll = _roll.text.trim();
    final phone = _phone.text.trim();
    final father = _father.text.trim();
    final sClass = _class.text.trim();
    final address = _address.text.trim();

    if (name.isEmpty || roll.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('छात्र का नाम और रोल नंबर भरना अनिवार्य है!')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('students').doc(roll).set({
        'name': name,
        'roll': roll,
        'phone': phone,
        'father': father,
        'class': sClass.isEmpty ? 'Class 11' : sClass,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('छात्र का पूरा विवरण सफलतापूर्वक सुरक्षित हो गया!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया छात्र जोड़ें')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inField(_name, 'छात्र का पूरा नाम *', Icons.person),
            const SizedBox(height: 12),
            _inField(_roll, 'रोल नंबर *', Icons.pin, isNum: true),
            const SizedBox(height: 12),
            _inField(_phone, 'मोबाइल नंबर', Icons.phone, isNum: true),
            const SizedBox(height: 12),
            _inField(_father, 'पिता का नाम', Icons.family_restroom),
            const SizedBox(height: 12),
            _inField(_class, 'कक्षा / बैच (उदा. 11th Science)', Icons.class_),
            const SizedBox(height: 12),
            _inField(_address, 'पूरा पता (गाँव / शहर)', Icons.location_on),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('डेटाबेस में सुरक्षित करें'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _inField(TextEditingController ctrl, String lbl, IconData icon, {bool isNum = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: lbl,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// 4. ATTENDANCE SCREEN
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final dKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final Map<String, bool> _status = {};
  bool _saving = false;

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final b = FirebaseFirestore.instance.batch();
      _status.forEach((r, p) {
        b.set(FirebaseFirestore.instance.collection('attendance').doc('$dKey-$r'), {
          'date': dKey,
          'roll': r,
          'status': p ? 'Present' : 'Absent',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      await b.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('आज की हाजिरी सुरक्षित हो गई!')));
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
      appBar: AppBar(title: Text('हाजिरी ($dKey)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data?.docs ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('डेटाबेस में कोई छात्र नहीं है।', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
                    child: const Text('+ पहले नया छात्र जोड़ें'),
                  )
                ],
              ),
            );
          }

          for (var d in list) {
            _status.putIfAbsent(d['roll'].toString(), () => true);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final d = list[i].data() as Map<String, dynamic>;
                    final roll = d['roll'].toString();
                    final name = d['name'] ?? '';
                    final isPres = _status[roll] ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: CheckboxListTile(
                        secondary: CircleAvatar(child: Text(roll)),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(isPres ? 'उपस्थित (Present)' : 'अनुपस्थित (Absent)'),
                        value: isPres,
                        activeColor: Colors.green,
                        onChanged: (v) => setState(() => _status[roll] = v ?? true),
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
                    child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('हाजिरी सुरक्षित करें'),
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

// 5. FEES MANAGEMENT
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
          if (s1.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final students = s1.data?.docs ?? [];
          if (students.isEmpty) {
            return const Center(child: Text('कोई छात्र मौजूद नहीं है। पहले छात्र जोड़ें।'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('fees').where('month', isEqualTo: m).snapshots(),
            builder: (ctx, s2) {
              final Map<String, bool> feeMap = {};
              if (s2.hasData) {
                for (var doc in s2.data!.docs) {
                  final d = doc.data() as Map<String, dynamic>;
                  feeMap[d['roll'].toString()] = d['isPaid'] == true;
                }
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                itemBuilder: (ctx, i) {
                  final s = students[i].data() as Map<String, dynamic>;
                  final r = s['roll'].toString();
                  final name = s['name'] ?? '';
                  final paid = feeMap[r] ?? false;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(r)),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(paid ? 'जमा (Paid)' : 'बाकी (Pending)'),
                      trailing: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: paid ? Colors.green.shade100 : Colors.red.shade100,
                        ),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('fees').doc('$m-$r').set({
                            'month': m,
                            'roll': r,
                            'isPaid': !paid,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                        },
                        child: Text(
                          paid ? 'Paid ✔' : 'Pending ✖',
                          style: TextStyle(color: paid ? Colors.green.shade900 : Colors.red.shade900, fontWeight: FontWeight.bold),
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

// 6. TEST MARKS
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _tName = TextEditingController(text: '15-Day Test');
  final _tot = TextEditingController(text: '50');
  final Map<String, TextEditingController> _m = {};
  bool _saving = false;

  Future<void> _save(List<QueryDocumentSnapshot> docs) async {
    final tName = _tName.text.trim();
    final tTotal = _tot.text.trim();
    if (tName.isEmpty || tTotal.isEmpty) return;

    setState(() => _saving = true);
    try {
      final b = FirebaseFirestore.instance.batch();
      for (var d in docs) {
        final r = d['roll'].toString();
        final marks = _m[r]?.text.trim() ?? '0';
        final docRef = FirebaseFirestore.instance.collection('tests').doc();
        b.set(docRef, {
          'testName': tName,
          'totalMarks': tTotal,
          'obtainedMarks': marks,
          'roll': r,
          'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      await b.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('टेस्ट अंक सुरक्षित हो गए!')));
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
      appBar: AppBar(title: const Text('टेस्ट अंक दर्ज करें')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('कोई छात्र मौजूद नहीं है। पहले छात्र जोड़ें।'));
          }

          for (var d in docs) {
            _m.putIfAbsent(d['roll'].toString(), () => TextEditingController(text: '0'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _tName, decoration: const InputDecoration(labelText: 'टेस्ट नाम', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    SizedBox(width: 90, child: TextField(controller: _tot, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'पूर्णांक', border: OutlineInputBorder()))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final r = d['roll'].toString();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(r)),
                        title: Text(d['name'] ?? ''),
                        trailing: SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _m[r],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
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
                  child: FilledButton(
                    onPressed: _saving ? null : () => _save(docs),
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

// 7. PROFILE SEARCH
class StudentProfileSearchScreen extends StatefulWidget {
  const StudentProfileSearchScreen({super.key});
  @override
  State<StudentProfileSearchScreen> createState() => _StudentProfileSearchScreenState();
}

class _StudentProfileSearchScreenState extends State<StudentProfileSearchScreen> {
  final _search = TextEditingController();
  String? _targetRoll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('छात्र प्रोफ़ाइल व रिकॉर्ड')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'रोल नंबर दर्ज करें',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => setState(() => _targetRoll = _search.text.trim()),
                  child: const Text('खोजें'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_targetRoll != null && _targetRoll!.isNotEmpty)
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('students').doc(_targetRoll).snapshots(),
                  builder: (ctx, sSnap) {
                    if (sSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!sSnap.hasData || !sSnap.data!.exists) {
                      return const Center(child: Text('इस रोल नंबर का कोई छात्र नहीं मिला।'));
                    }

                    final data = sSnap.data!.data() as Map<String, dynamic>;
                    return ListView(
                      children: [
                        Card(
                          color: Colors.indigo.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('नाम: ${data['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('रोल नंबर: ${data['roll']} | कक्षा: ${data['class'] ?? ""}'),
                                const SizedBox(height: 4),
                                Text('पिता का नाम: ${data['father'] ?? "दर्ज नहीं"}'),
                                const SizedBox(height: 4),
                                Text('मोबाइल नंबर: ${data['phone'] ?? "दर्ज नहीं"}'),
                                const SizedBox(height: 4),
                                Text('पता: ${data['address'] ?? "दर्ज नहीं"}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('टेस्ट रिकॉर्ड्स:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tests')
                              .where('roll', isEqualTo: _targetRoll)
                              .snapshots(),
                          builder: (ctx, tSnap) {
                            if (!tSnap.hasData) return const LinearProgressIndicator();
                            final tests = tSnap.data!.docs;
                            if (tests.isEmpty) return const Text('कोई टेस्ट रिकॉर्ड दर्ज नहीं है।');

                            return Column(
                              children: tests.map((doc) {
                                final t = doc.data() as Map<String, dynamic>;
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.star, color: Colors.amber),
                                    title: Text(t['testName'] ?? 'Test'),
                                    subtitle: Text('दिनांक: ${t['date'] ?? ""}'),
                                    trailing: Text(
                                      '${t['obtainedMarks']} / ${t['totalMarks']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
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
