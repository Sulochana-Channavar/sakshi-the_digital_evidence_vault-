import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import '../models/evidence.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'evidence_detail_screen.dart';
import '../widgets/panic_detector.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {

  List<Evidence> evidenceList = [];
  bool courtMode = false;
  bool isRecordingVideo = false;

  final captionController = TextEditingController();
  final descriptionController = TextEditingController();

  bool panicRecording = false;
  bool blink = true;
  Timer? blinkTimer;

  CameraController? cameraController;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    loadEvidenceList();
  }

  @override
  void dispose() {
    blinkTimer?.cancel();
    cameraController?.dispose();
    captionController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void disableCourtMode() {
    setState(() => courtMode = false);
  }

  // ================= CAMERA =================
  Future<void> initCamera() async {
    cameras ??= await availableCameras();

    cameraController = CameraController(
      cameras!.first,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    await cameraController!.initialize();
  }

  // ================= PANIC MODE =================
  Future<void> startPanicMode() async {
    if (panicRecording) return;

    await initCamera();
    await cameraController!.startVideoRecording();

    setState(() => panicRecording = true);

    blinkTimer =
        Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() => blink = !blink);
    });
  }

  Future<void> stopPanicMode() async {
    if (!panicRecording) return;

    blinkTimer?.cancel();

    final video =
        await cameraController!.stopVideoRecording();

    final file = File(video.path);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final savedVideo = await file.copy(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');

    addEvidence(savedVideo.path, digest.toString(),
        "Panic Video Recorded",
        prefix: "VID");
  }

  // ================= VIDEO CAPTURE =================
  Future<void> startVideoCapture() async {
    await initCamera();
    await cameraController!.startVideoRecording();

    setState(() => isRecordingVideo = true);
  }

  Future<void> stopVideoCapture() async {
    if (!isRecordingVideo) return;

    final video =
        await cameraController!.stopVideoRecording();

    setState(() => isRecordingVideo = false);

    final file = File(video.path);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final savedVideo = await file.copy(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');

    addEvidence(savedVideo.path, digest.toString(),
        "Video Evidence Recorded",
        prefix: "VID");
  }

  // ================= IMAGE =================
  Future<void> captureEvidence() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final saved = await file.copy(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    addEvidence(saved.path, digest.toString(),
        "Evidence Captured");
  }

  Future<void> uploadEvidence() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final saved = await file.copy(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    addEvidence(saved.path, digest.toString(),
        "Evidence Uploaded");
  }

  // ================= ADD EVIDENCE =================
  Future<void> addEvidence(
      String path, String hash, String event,
      {String prefix = "EVID"}) async {

    final now = DateTime.now().toString();

    final newEvidence = Evidence(
      imagePath: path,
      hash: hash,
      evidenceId: "$prefix-${DateTime.now().millisecondsSinceEpoch}",
      timestamp: now,
      caption: captionController.text,
      description: descriptionController.text,
      custody: [CustodyEvent(event: event, time: now)],
    );

    setState(() {
      panicRecording = false;
      blink = true;
      evidenceList.insert(0, newEvidence);
      courtMode = true;
    });

    captionController.clear();
    descriptionController.clear();

    await saveEvidenceList();
  }

  // ================= COMPLAINT =================
  Future<void> submitComplaintOnly() async {
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write description")),
      );
      return;
    }

    final now = DateTime.now().toString();

    final digest = sha256
        .convert(utf8.encode(
            captionController.text +
                descriptionController.text +
                now))
        .toString();

    addEvidence("", digest,
        "Written Complaint Submitted",
        prefix: "STAT");
  }

  // ================= SAVE / LOAD =================
  Future<void> saveEvidenceList() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/evidence.json');
    final jsonList = evidenceList.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> loadEvidenceList() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/evidence.json');
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final List decoded = jsonDecode(content);

    setState(() {
      evidenceList =
          decoded.map((e) => Evidence.fromJson(e)).toList();
      if (evidenceList.isNotEmpty) courtMode = true;
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return PanicDetector(
      onPanic: startPanicMode,
      child: GestureDetector(
        onLongPress: stopPanicMode,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Sakshi Vault"),
            actions: [
              if (courtMode)
                IconButton(
                    icon: const Icon(Icons.lock_open),
                    onPressed: disableCourtMode),
              IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: logout),
            ],
          ),

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              if (panicRecording && blink)
                const Text("🔴 PANIC RECORDING",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),

              // ===== QUICK ACTIONS =====
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload"),
                      onPressed:
                          courtMode ? null : uploadEvidence,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Photo"),
                      onPressed:
                          courtMode ? null : captureEvidence,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(isRecordingVideo
                          ? Icons.stop
                          : Icons.videocam),
                      label: Text(
                          isRecordingVideo ? "Stop" : "Video"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isRecordingVideo
                                ? Colors.red
                                : null,
                      ),
                      onPressed: courtMode
                          ? null
                          : (isRecordingVideo
                              ? stopVideoCapture
                              : startVideoCapture),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text("Evidence History",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),

              ...evidenceList.map(
                (e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(e.evidenceId),
                    subtitle: Text(e.timestamp),
                    trailing:
                        const Icon(Icons.arrow_forward_ios,
                            size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EvidenceDetailScreen(
                                  evidence: e),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}