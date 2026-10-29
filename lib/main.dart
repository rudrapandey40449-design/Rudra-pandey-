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

// 1. ADMIN AUTH
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

// 2. DASHBOARD
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
            child: Text('अधिकृत एडमिन: $aId \vert{} दिनांक: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}', style: const TextStyle(color: Colors.white, fontSize: 13)),
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
      title: Text(t, style:
                  
