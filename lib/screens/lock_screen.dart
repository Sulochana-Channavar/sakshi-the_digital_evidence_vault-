import 'package:flutter/material.dart';
import 'vault_screen.dart';
import 'dart:convert';
import '../models/evidence.dart';


class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const VaultScreen(),
              ),
            );
          },
          child: const Text("Unlock Vault"),
        ),
      ),
    );
  }
}
