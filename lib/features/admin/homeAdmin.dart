import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home do Admin')),
      body: const Center(child: Text('Bem-vindo, Admin!')),
    );
  }
}
