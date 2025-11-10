import 'package:flutter/material.dart';
import 'package:biblio/features/header/header.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'University Library'),
      body: const Center(child: Text('Bem-vindo, Admin!')),
    );
  }
}
