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
  runApp(const MaterialApp(home: AdminAuth(), debugShowCheckedModeBanner: false));
}

class AdminAuth extends StatefulWidget {
  const AdminAuth({super.key});
  @override
  State<AdminAuth> createState() => _AdminAuthState();
}

class _AdminAuthState extends State<AdminAuth> {
  final _id = TextEditingController(), _pw = TextEditingController(), _org = TextEditingController();
  bool isReg = false, _load = false;

  Future<void> _submit() async {
    final id = _id.text.trim().toLowerCase(), pw = _pw.text.trim(), org = _org.text.trim();
    if (id.isEmpty || pw.isEmpty) return;
    setState(() => _load = true);
    final ref = FirebaseFirestore.instance.collection('admins').doc(id);
    final doc = await ref.get();
    if (isReg) {
      if (doc.exists) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('आईडी पहले से मौजूद है!')));
      } else {
        await ref.set({'id': id, 'pw': pw, 'org': org.isEmpty ? 'शिक्षा केंद्र' : org});
        _go(id, org.isEmpty ? 'शिक्षा केंद्र' : org);
      }
    } else {
      if (doc.exists && doc.data()?['pw'] == pw) {
        _go(id, doc.data()?['org'] ?? 'शिक्षा केंद्र');
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत आईडी या पासवर्ड!')));
      }
    }
    if (mounted) setState(() => _load = false);
  }

  void _go(String id, String org) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard(aId: id, org: org)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D253F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance, size: 50, color: Color(0xFF0D253F)),
                  const SizedBox(height: 8),
                  Text(isReg ? 'नया एडमिन पंजीकरण' : 'राष्ट्रीय कोचिंग पोर्टल लॉगिन', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 14),
                  if (isReg) TextField(controller: _org, decoration: const InputDecoration(labelText: 'कोचिंग / संस्था का नाम', border: OutlineInputBorder(), isDense: true)),
                  if (isReg) const SizedBox(height: 8),
                  TextField(controller: _id, decoration: const InputDecoration(labelText: 'एडमिन आईडी (यूज़रनेम)', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  TextField(controller: _pw, obscureText: true, decoration: const InputDecoration(labelText: 'पासवर्ड', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(42)),
                    onPressed: _load ? null : _submit,
                    child: _load ? const CircularProgressIndicator(color: Colors.white) : Text(isReg ? 'पंजीकृत करें' : 'प्रवेश करें'),
                  ),
                  TextButton(onPressed: () => setState(() => isReg = !isReg), child: Text(isReg ? 'लॉगिन करें' : 'नया खाता बनाएँ')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final String aId, org;
  const Dashboard({super.key, required this.aId, required this.org});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(org, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0D253F),
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminAuth())))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0D253F), borderRadius: BorderRadius.circular(8)),
            child: Text('अधिकृत एडमिन: $aId | दिनांक: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}', style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(height: 12),
          _btn(context, 'दैनिक व मासिक हाजिरी (Attendance)', Icons.how_to_reg, Colors.teal, AttMod(aId: aId)),
          _btn(context, 'शुल्क संग्रह रजिस्टर (Fee Ledger)', Icons.currency_rupee, Colors.green, FeeMod(aId: aId)),
          _btn(context, 'विषयवार परीक्षा अंक (Test Marks)', Icons.assignment, Colors.indigo, TestMod(aId: aId)),
          _btn(context, 'छात्र नामांकन (Add Student)', Icons.person_add, Colors.blue, AddStdMod(aId: aId)),
          _btn(context, 'डिजिटल छात्र रिकॉर्ड (Student Dossier)', Icons.badge, Colors.orange, SearchMod(aId: aId)),
        ],
      ),
    );
  }

  Widget _btn(BuildContext c, String t, IconData i, Color cl, Widget p) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(i, color: cl),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => p)),
    ),
  );
}

class AddStdMod extends StatefulWidget {
  final String aId;
  const AddStdMod({super.key, required this.aId});
  @override
  State<AddStdMod> createState() => _AddStdModState();
}

class _AddStdModState extends State<AddStdMod> {
  final _n = TextEditingController(), _r = TextEditingController(), _p = TextEditingController(), _f = TextEditingController(), _c = TextEditingController(), _a = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नवीन छात्र पंजीकरण'), backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _n, decoration: const InputDecoration(labelText: 'छात्र का पूरा नाम *')),
          TextField(controller: _r, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'अनुक्रमांक (Roll No) *')),
          TextField(controller: _p, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'मोबाइल नंबर')),
          TextField(controller: _f, decoration: const InputDecoration(labelText: 'पिता का नाम')),
          TextField(controller: _c, decoration: const InputDecoration(labelText: 'कक्षा / वर्ग (उदा. 11th)')),
          TextField(controller: _a, decoration: const InputDecoration(labelText: 'पूरा पता (गाँव/शहर)')),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(44)),
            onPressed: () async {
              if (_n.text.isNotEmpty && _r.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('students').doc(_r.text.trim()).set({
                  'name': _n.text.trim(), 'roll': _r.text.trim(), 'phone': _p.text.trim(), 'father': _f.text.trim(), 'class': _c.text.trim().isEmpty ? '11th' : _c.text.trim(), 'address': _a.text.trim(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('अभिलेख सुरक्षित करें'),
          )
        ],
      ),
    );
  }
}class AttMod extends StatefulWidget {
  final String aId;
  const AttMod({super.key, required this.aId});
  @override
  State<AttMod> createState() => _AttModState();
}

class _AttModState extends State<AttMod> {
  DateTime _dt = DateTime.now();
  final Map<String, bool> _st = {};
  String get _dKey => DateFormat('yyyy-MM-dd').format(_dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('उपस्थिति पंजिका'), backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Text('दिनांक: $_dKey', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('तारीख चुनें'),
                  onPressed: () async {
                    final p = await showDatePicker(context: context, initialDate: _dt, firstDate: DateTime(2025), lastDate: DateTime.now());
                    if (p != null) setState(() => _dt = p);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('students').snapshots(),
              builder: (ctx, s1) {
                if (!s1.hasData) return const Center(child: CircularProgressIndicator());
                final stds = s1.data!.docs;
                if (stds.isEmpty) return const Center(child: Text('कोई छात्र पंजीकृत नहीं है।'));
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('attendance').where('date', isEqualTo: _dKey).snapshots(),
                  builder: (ctx, s2) {
                    if (s2.hasData) {
                      for (var d in s2.data!.docs) { _st[d['roll'].toString()] = d['status'] == 'Present'; }
                    }
                    return ListView.builder(
                      itemCount: stds.length,
                      itemBuilder: (c, i) {
                        final r = stds[i]['roll'].toString();
                        final isP = _st[r] ?? true;
                        return CheckboxListTile(
                          title: Text('${stds[i]['name']} (रोल: $r)'),
                          subtitle: Text('फेस सत्यापन: प्रमाणित ✔ | स्थिति: ${isP ? "उपस्थित" : "अनुपस्थित"}'),
                          value: isP,
                          activeColor: Colors.green,
                          onChanged: (v) => setState(() => _st[r] = v ?? true),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(44)),
              onPressed: () async {
                final b = FirebaseFirestore.instance.batch();
                _st.forEach((r, p) {
                  final ref = FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('attendance').doc('$_dKey-$r');
                  b.set(ref, {'date': _dKey, 'month': DateFormat('MMMM yyyy').format(_dt), 'roll': r, 'status': p ? 'Present' : 'Absent'});
                });
                await b.commit();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('उपस्थिति सुरक्षित हो गई!')));
              },
              child: Text('$_dKey की हाजिरी लॉक करें'),
            ),
          )
        ],
      ),
    );
  }
}

class FeeMod extends StatelessWidget {
  final String aId;
  const FeeMod({super.key, required this.aId});

  @override
  Widget build(BuildContext context) {
    final m = DateFormat('MMMM yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text('शुल्क रजिस्टर ($m)'), backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('admins').doc(aId).collection('students').snapshots(),
        builder: (ctx, s1) {
          if (!s1.hasData) return const Center(child: CircularProgressIndicator());
          final stds = s1.data!.docs;
          if (stds.isEmpty) return const Center(child: Text('कोई छात्र नहीं मिला।'));
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('admins').doc(aId).collection('fees').where('month', isEqualTo: m).snapshots(),
            builder: (ctx, s2) {
              final feeMap = {for (var d in (s2.data?.docs ?? [])) d['roll'].toString(): d.data() as Map<String, dynamic>};
              return ListView.builder(
                itemCount: stds.length,
                itemBuilder: (c, i) {
                  final r = stds[i]['roll'].toString();
                  final item = feeMap[r];
                  final isP = item != null && item['isPaid'] == true;
                  final pDate = item?['paidOn'] ?? 'अपेक्षित';
                  return Card(
                    child: ListTile(
                      title: Text(stds[i]['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('रोल: $r | तिथि: $pDate'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: isP ? Colors.green : Colors.red.shade400, foregroundColor: Colors.white),
                        onPressed: () {
                          final now = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
                          FirebaseFirestore.instance.collection('admins').doc(aId).collection('fees').doc('$m-$r').set({
                            'month': m, 'roll': r, 'isPaid': !isP, 'paidOn': !isP ? now : null,
                          });
                        },
                        child: Text(isP ? 'Paid ✔' : 'Due ✖'),
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

class TestMod extends StatefulWidget {
  final String aId;
  const TestMod({super.key, required this.aId});
  @override
  State<TestMod> createState() => _TestModState();
}

class _TestModState extends State<TestMod> {
  final _t = TextEditingController(text: 'प्रथम पाक्षिक'), _sub = TextEditingController(text: 'Chemistry'), _tot = TextEditingController(text: '50');
  final Map<String, TextEditingController> _m = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('परीक्षा मूल्यांकन रजिस्टर'), backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('students').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('कोई छात्र पंजीकृत नहीं है।'));
          for (var d in docs) { _m.putIfAbsent(d['roll'].toString(), () => TextEditingController(text: '0')); }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _t, decoration: const InputDecoration(labelText: 'परीक्षा', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 6),
                    Expanded(child: TextField(controller: _sub, decoration: const InputDecoration(labelText: 'विषय', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 6),
                    SizedBox(width: 65, child: TextField(controller: _tot, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'पूर्णांक', border: OutlineInputBorder(), isDense: true))),
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
                      trailing: SizedBox(width: 70, child: TextField(controller: _m[r], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'अंक', border: OutlineInputBorder(), isDense: true))),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(44)),
                  onPressed: () async {
                    final b = FirebaseFirestore.instance.batch();
                    final dStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
                    for (var doc in docs) {
                      final r = doc['roll'].toString();
                      final ref = FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('tests').doc('${_t.text.trim()}-$r');
                      b.set(ref, {'testName': _t.text.trim(), 'subject': _sub.text.trim(), 'total': _tot.text.trim(), 'marks': _m[r]?.text.trim() ?? '0', 'roll': r, 'date': dStr});
                    }
                    await b.commit();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('अंक सफलतापूर्वक अपडेट हो गए!')));
                  },
                  child: const Text('अंक सुरक्षित व अपडेट करें'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class SearchMod extends StatefulWidget {
  final String aId;
  const SearchMod({super.key, required this.aId});
  @override
  State<SearchMod> createState() => _SearchModState();
}

class _SearchModState extends State<SearchMod> {
  final _s = TextEditingController();
  String? _roll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('डिजिटल छात्र डोजियर'), backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _s, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'अनुक्रमांक (Roll No) खोजें', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
                  onPressed: () => setState(() => _roll = _s.text.trim()),
                  child: const Text('खोजें'),
                )
              ],
            ),
            const SizedBox(height: 10),
            if (_roll != null && _roll!.isNotEmpty)
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('students').doc(_roll).snapshots(),
                  builder: (ctx, s1) {
                    if (!s1.hasData || !s1.data!.exists) return const Center(child: Text('छात्र नहीं मिला।'));
                    final d = s1.data!.data() as Map<String, dynamic>;
                    return ListView(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${d['name']} (रोल: ${d['roll']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('कक्षा: ${d['class']} | पिता: ${d['father']}'),
                                Text('मोबाइल: ${d['phone']} | पता: ${d['address']}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('attendance').where('roll', isEqualTo: _roll).snapshots(),
                          builder: (ctx, att) {
                            final docs = att.data?.docs ?? [];
                            int pres = docs.where((e) => e['status'] == 'Present').length;
                            final tot = docs.length;
                            final pct = tot > 0 ? ((pres / tot) * 100).toStringAsFixed(1) : '0';
                            return Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('मासिक उपस्थिति: कुल $tot दिन | उपस्थित: $pres दिन | अनुपस्थित: ${tot - pres} दिन | निरंतरता: $pct%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text('परीक्षा परिणाम विवरण:', style: TextStyle(fontWeight: FontWeight.bold)),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('admins').doc(widget.aId).collection('tests').where('roll', isEqualTo: _roll).snapshots(),
                          builder: (ctx, ts) {
                            final tDocs = ts.data?.docs ?? [];
                            if (tDocs.isEmpty) return const Text('कोई टेस्ट रिकॉर्ड नहीं मिला।');
                            return Column(
                              children: tDocs.map((doc) => Card(
                                child: ListTile(
                                  title: Text('${doc['testName']} - ${doc['subject']}'),
                                  subtitle: Text('तिथि: ${doc['date']}'),
                                  trailing: Text('${doc['marks']} / ${doc['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
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

