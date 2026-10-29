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
  runApp(const GovtPortalApp());
}

class GovtPortalApp extends StatelessWidget {
  const GovtPortalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'शिक्षा प्रबंधन पोर्टल',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D253F),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D253F),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: const AdminAuthScreen(),
    );
  }
}

// ---------------- 1. MULTI-ADMIN AUTH SCREEN ----------------
class AdminAuthScreen extends StatefulWidget {
  const AdminAuthScreen({super.key});
  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final _adminId = TextEditingController();
  final _pass = TextEditingController();
  final _institute = TextEditingController();
  bool isRegister = false;
  bool _loading = false;

  Future<void> _handleAuth() async {
    final id = _adminId.text.trim().toLowerCase();
    final pass = _pass.text.trim();
    final inst = _institute.text.trim();

    if (id.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('आईडी और पासवर्ड दर्ज करें')));
      return;
    }

    setState(() => _loading = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('admins').doc(id);
      final doc = await docRef.get();

      if (isRegister) {
        if (doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('यह आईडी पहले से मौजूद है! दूसरी आईडी चुनें')));
        } else {
          await docRef.set({
            'adminId': id,
            'password': pass,
            'instituteName': inst.isEmpty ? 'शिक्षा केंद्र' : inst,
            'createdAt': FieldValue.serverTimestamp(),
          });
          _openDashboard(id, inst.isEmpty ? 'शिक्षा केंद्र' : inst);
        }
      } else {
        if (doc.exists && doc.data()?['password'] == pass) {
          _openDashboard(id, doc.data()?['instituteName'] ?? 'शिक्षा केंद्र');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('अमान्य आईडी या पासवर्ड!')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDashboard(String id, String inst) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PortalDashboard(adminId: id, instituteName: inst)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF0D253F), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance, size: 50, color: Colors.amber),
              ),
              const SizedBox(height: 12),
              const Text('राष्ट्रीय कोचिंग प्रबंधन पोर्टल', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
              const Text('प्रशासनिक लॉगिन मॉड्यूल', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (isRegister) ...[
                        TextField(controller: _institute, decoration: const InputDecoration(labelText: 'कोचिंग / संस्था का नाम', prefixIcon: Icon(Icons.business), border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                      ],
                      TextField(controller: _adminId, decoration: const InputDecoration(labelText: 'एडमिन आईडी (यूज़रनेम)', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'पासवर्ड', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: _loading ? null : _handleAuth,
                          child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(isRegister ? 'नया खाता पंजीकृत करें' : 'पोर्टल में प्रवेश करें', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => isRegister = !isRegister),
                        child: Text(isRegister ? 'पहले से खाता है? लॉगिन करें' : 'नई कोचिंग का रजिस्ट्रेशन करें'),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- 2. OFFICIAL DASHBOARD ----------------
class PortalDashboard extends StatelessWidget {
  final String adminId;
  final String instituteName;
  const PortalDashboard({super.key, required this.adminId, required this.instituteName});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(instituteName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminAuthScreen()))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0D253F), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.amber, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('अधिकृत एडमिन: $adminId', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(today, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('मुख्य प्रशासनिक मॉड्यूल', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          _item(context, 'दैनिक व मासिक हाजिरी (Attendance)', 'कैलेंडर चयन, फेस सत्यापन व मासिक रिपोर्ट', Icons.how_to_reg, Colors.teal, AttendanceModule(adminId: adminId)),
          _item(context, 'शुल्क संग्रह रजिस्टर (Fee Ledger)', 'भुगतान तिथि, रसीद व बकाया विवरण', Icons.account_balance_wallet, Colors.green.shade800, FeeModule(adminId: adminId)),
          _item(context, 'विषयवार परीक्षा अंक (Test Manager)', 'विषय, पूर्णांक, संपादन व प्राप्तांक', Icons.assignment, Colors.indigo, TestModule(adminId: adminId)),
          _item(context, 'छात्र नामांकन (New Admission)', 'पूर्ण व्यक्तिगत व पारिवारिक विवरण', Icons.person_add_alt_1, Colors.blue.shade800, AddStudentModule(adminId: adminId)),
          _item(context, 'डिजिटल छात्र रिकॉर्ड (Student Dossier)', 'उपस्थिति स्थिरता (%), टेस्ट व पूर्ण प्रोफ़ाइल', Icons.badge, Colors.deepOrange, StudentSearchModule(adminId: adminId)),
        ],
      ),
    );
  }

  Widget _item(BuildContext ctx, String title, String sub, IconData icon, Color col, Widget target) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(backgroundColor: col.withOpacity(0.12), child: Icon(icon, color: col)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => target)),
      ),
    );
  }
}

// ---------------- 3. ADD STUDENT ----------------
class AddStudentModule extends StatefulWidget {
  final String adminId;
  const AddStudentModule({super.key, required this.adminId});
  @override
  State<AddStudentModule> createState() => _AddStudentModuleState();
}

class _AddStudentModuleState extends State<AddStudentModule> {
  final _name = TextEditingController(), _roll = TextEditingController(), _phone = TextEditingController();
  final _father = TextEditingController(), _class = TextEditingController(), _address = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    final n = _name.text.trim(), r = _roll.text.trim();
    if (n.isEmpty || r.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('नाम एवं रोल नंबर अनिवार्य हैं')));
      return;
    }
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('admins').doc(widget.adminId).collection('students').doc(r).set({
      'name': n,
      'roll': r,
      'phone': _phone.text.trim(),
      'father': _father.text.trim(),
      'class': _class.text.trim().isEmpty ? '11th Standard' : _class.text.trim(),
      'address': _address.text.trim(),
      'faceVerified': true,
      'enrolledAt': FieldValue.serverTimestamp(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नवीन छात्र पंजीकरण')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'छात्र का पूरा नाम *', Icons.person),
          _field(_roll, 'अनुक्रमांक (Roll No) *', Icons.numbers, isNum: true),
          _field(_phone, 'अभिभावक / छात्र मोबाइल नंबर', Icons.phone, isNum: true),
          _field(_father, 'पिता / संरक्षक का नाम', Icons.family_restroom),
          _field(_class, 'कक्षा / वर्ग (उदा. 11th Science)', Icons.school),
          _field(_address, 'स्थायी निवास पता (गाँव / वार्ड / पिनकोड)', Icons.location_city),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
            icon: const Icon(Icons.save),
            label: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('अभिलेख सुरक्षित करें'),
            onPressed: _saving ? null : _submit,
          )
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i, {bool isNum = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, keyboardType: isNum ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: l, prefixIcon: Icon(i), border: const OutlineInputBorder())),
  );
}

// ---------------- 4. ATTENDANCE MODULE (CALENDAR & STATUS) ----------------
class AttendanceModule extends StatefulWidget {
  final String adminId;
  const AttendanceModule({super.key, required this.adminId});
  @override
  State<AttendanceModule> createState() => _AttendanceModuleState();
}

class _AttendanceModuleState extends State<AttendanceModule> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, bool> _status = {};

  String get _dKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('दैनिक उपस्थिति पंजिका')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.event, color: Color(0xFF0D253F)),
                const SizedBox(width: 8),
                Text('दिनांक: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                OutlinedButton.icon(icon: const Icon(Icons.edit_calendar, size: 18), label: const Text('दिनांक बदलें'), onPressed: _pickDate),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('admins').doc(widget.adminId).collection('students').snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final students = snap.data!.docs;
                if (students.isEmpty) return const Center(child: Text('कोई छात्र पंजीकृत नहीं है।'));

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('admins').doc(widget.adminId).collection('attendance').where('date', isEqualTo: _dKey).snapshots(),
                  builder: (ctx, attSnap) {
                    if (attSnap.hasData) {
                      for (var doc in attSnap.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        _status[data['roll'].toString()] = data['status'] == 'Present';
                      }
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (c, i) {
                        final s = students[i].data() as Map<String, dynamic>;
                        final roll = s['roll'].toString();
                        final isP = _status[roll] ?? true;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: const Color(0xFF0D253F), child: Text(roll, style: const TextStyle(color: Colors.white))),
                            title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('फेस सत्यापन: अधिकृत ✔ | वर्ग: ${s['class'] ?? ""}'),
                            trailing: Switch(
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              value: isP,
                              onChanged: (v) => setState(() => _status[roll] = v),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.check_circle_outline),
              label: Text('$_dKey की उपस्थिति लॉक करें'),
              onPressed: () async {
                final b = FirebaseFirestore.instance.batch();
                _status.forEach((r, p) {
                  final ref = FirebaseFirestore.instance.collection('admins').doc(widget.adminId).collection('attendance').doc('$_dKey-$r');
                  b.set(ref, {'date': _dKey, 'month': DateFormat('MMMM yyyy').format(_selectedDate), 'roll': r, 'status': p ? 'Present' : 'Absent', 'verifiedAt': FieldValue.serverTimestamp()});
                });
                await b.commit();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('उपस्थिति सफलतापूर्वक दर्ज हो गई!')));
              },
            ),
          )
        ],
      ),
    );
  }
}

// ---------------- 5. FEE REGISTER WITH PAYMENT DATE ----------------
class FeeModule extends StatelessWidget {
  final String adminId;
  const FeeModule({super.key, required this.adminId});

  @override
  Widget build(BuildContext context) {
    final m = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text('मासिक शुल्क रजिस्टर ($m)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('admins').doc(adminId).collection('students').snapshots(),
        builder: (ctx, sSnap) {
          if (!sSnap.hasData) return const Center(child: CircularProgressIndicator());
          final students = sSnap.data!.docs;
          if (students.isEmpty) return const Center(child: Text('कोई छात्र पंजीकृत नहीं है।'));

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('admins').doc(adminId).collection('fees').where('month', isEqualTo: m).snapshots(),
            builder: (ctx, fSnap) {
              final Map<String, dynamic> feeInfo = {};
              if (fSnap.hasData) {
                for (var doc in fSnap.data!.docs) {
                  final d = doc.data() as Map<String, dynamic>;
                  feeInfo[d['roll'].toString()] = d;
                }
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                itemBuilder: (c, i) {
                  final s = students[i].data() as Map<String, dynamic>;
                  final r = s['roll'].toString();
                  final item = feeInfo[r];
                  final isPaid = item != null && item['isPaid'] == true;
                  final paidDate = item?['paidOn'] ?? 'अपेक्षित';

                  return Card(
              
