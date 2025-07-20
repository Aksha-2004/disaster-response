import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sms/flutter_sms.dart';

class OfflineAlertPage extends StatefulWidget {
  const OfflineAlertPage({super.key});

  @override
  State<OfflineAlertPage> createState() => _OfflineAlertPageState();
}

class _OfflineAlertPageState extends State<OfflineAlertPage> {
  final TextEditingController _messageController = TextEditingController();
  List<String> phoneNumbers = [];

  Future<void> _loadPhoneNumbers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final seen = <String>{};

    setState(() {
      phoneNumbers = snapshot.docs
          .map((doc) => doc['phone']?.toString() ?? '')
          .where((phone) => phone.isNotEmpty && seen.add(phone))
          .toList();
    });
  }

  Future<void> _sendSMS(String message, List<String> recipients) async {
    try {
      await sendSMS(message: message, recipients: recipients, sendDirect: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Alert sent via SMS"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send SMS: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPhoneNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Alert (SMS)"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Alert Message",
                border: OutlineInputBorder(),
                hintText: "Type the disaster alert here...",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: phoneNumbers.isNotEmpty
                  ? () => _sendSMS(_messageController.text.trim(), phoneNumbers)
                  : null,
              icon: const Icon(Icons.sms),
              label: const Text("Send SMS to All"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 10),
            Text("Recipients (${phoneNumbers.length})"),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: phoneNumbers.map((num) => Text("📞 $num")).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
