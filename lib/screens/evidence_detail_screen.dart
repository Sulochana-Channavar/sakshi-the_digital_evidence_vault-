import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/evidence.dart';
import '../services/legal_report_service.dart';

class EvidenceDetailScreen extends StatefulWidget {
  final Evidence evidence;

  const EvidenceDetailScreen({
    super.key,
    required this.evidence,
  });

  @override
  State<EvidenceDetailScreen> createState() =>
      _EvidenceDetailScreenState();
}

class _EvidenceDetailScreenState
    extends State<EvidenceDetailScreen> {

  bool? isVerified;

  // =====================================================
  // VERIFY INTEGRITY
  // =====================================================
  Future<void> verifyIntegrity() async {

    final e = widget.evidence;

    // ✅ TEXT-ONLY COMPLAINT (NO FILE)
    if (e.imagePath.isEmpty) {

      final textData =
          (e.caption ?? "") +
          (e.description ?? "") +
          e.timestamp;

      final digest =
          sha256.convert(utf8.encode(textData)).toString();

      setState(() {
        isVerified = digest == e.hash;
      });

      return;
    }

    final file = File(e.imagePath);

    // FILE MISSING
    if (!await file.exists()) {
      setState(() => isVerified = false);

      e.custody.add(
        CustodyEvent(
          event: "Tamper Detected (File Missing)",
          time: DateTime.now().toString(),
        ),
      );

      showTamperAlert();
      return;
    }

    final bytes = await file.readAsBytes();
    final newHash = sha256.convert(bytes).toString();

    final verified = newHash == e.hash;

    setState(() => isVerified = verified);

    e.custody.add(
      CustodyEvent(
        event:
            verified ? "Integrity Verified" : "Tamper Detected",
        time: DateTime.now().toString(),
      ),
    );

    if (!verified) showTamperAlert();
  }

  // =====================================================
  // ALERT
  // =====================================================
  void showTamperAlert() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text(
            "⚠ Evidence Tampered",
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            "Integrity verification failed.\n"
            "Evidence may have been modified.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    verifyIntegrity();
  }

  // =====================================================
  // MEDIA PREVIEW
  // =====================================================
  Widget buildMediaPreview() {

    final path = widget.evidence.imagePath;

    // ✅ TEXT ONLY CASE
    if (path.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 50),
            SizedBox(height: 8),
            Text("Written Complaint (No Media)")
          ],
        ),
      );
    }

    // VIDEO
    if (path.endsWith(".mp4")) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        color: Colors.black12,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 60),
            SizedBox(height: 8),
            Text("Video Evidence"),
          ],
        ),
      );
    }

    // IMAGE
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {

    final e = widget.evidence;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evidence Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= MEDIA =================
            buildMediaPreview(),

            const SizedBox(height: 20),

            // ================= BASIC DETAILS =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text("Evidence ID",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(e.evidenceId),

                    const SizedBox(height: 10),

                    const Text("Timestamp",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(e.timestamp),

                    const SizedBox(height: 10),

                    const Text("SHA-256 Hash",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(e.hash),

                    const SizedBox(height: 15),

                    isVerified == null
                        ? const Center(
                            child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Icon(
                                isVerified!
                                    ? Icons.verified
                                    : Icons.warning,
                                color: isVerified!
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isVerified!
                                    ? "Integrity Verified"
                                    : "Evidence Tampered",
                                style: TextStyle(
                                  color: isVerified!
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= INCIDENT REPORT =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text("Incident Caption",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(e.caption?.isEmpty ?? true ? "-" : e.caption!),

                    const SizedBox(height: 12),

                    const Text("Incident Description",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(e.description?.isEmpty ?? true
                        ? "-"
                        : e.description!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= LEGAL REPORT =================
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate Legal Report (65B)"),
              onPressed: () {
                LegalReportService.generateReport(e);
              },
            ),

            const SizedBox(height: 25),

            // ================= CHAIN OF CUSTODY =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chain of Custody",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            ...e.custody.map(
              (c) => Card(
                child: ListTile(
                  leading: Icon(
                    c.event.contains("Tamper")
                        ? Icons.warning
                        : Icons.check_circle,
                    color: c.event.contains("Tamper")
                        ? Colors.red
                        : Colors.green,
                  ),
                  title: Text(c.event),
                  subtitle: Text(c.time),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}