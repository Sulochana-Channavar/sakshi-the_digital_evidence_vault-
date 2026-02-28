import 'package:flutter/material.dart';

class VaultHome extends StatelessWidget {
  const VaultHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sakshi Vault")),
      body: const Center(
        child: Text(
          "Vault Unlocked ✅",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
