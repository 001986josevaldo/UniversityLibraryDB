import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _mostrarSenha = false;

  void _fazerLogin() {
    final matricula = _matriculaController.text.trim();
    final senha = _senhaController.text.trim();

    // 1. Validação de campos vazios (igual ao seu código)
    if (matricula.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    // --- LÓGICA DE LOGIN FICTÍCIO ---

    // 2. Verifica o login do Administrador
    if (matricula == 'admin' && senha == 'admin123') {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.adminHome,
        arguments: 'admin', // arqumento de admin
      );

      // 3. Verifica o login do Usuário comum
    } else if (matricula == 'user' && senha == 'user123') {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userHome,
        arguments: 'user', // argumento de user
      );

      // 4. Se nenhum for válido, exibe erro
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        // Corrigido para "incorretas" (concordância)
        const SnackBar(content: Text('Matrícula ou senha incorretas!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6F3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                // ---------------------------------------------------------- PAGINA 1 ------------------------------
                'university library',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _matriculaController,
                decoration: const InputDecoration(
                  labelText: 'Matrícula',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: !_mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarSenha ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarSenha = !_mostrarSenha;
                      });
                    },
                  ),
                ),
                onSubmitted: (_) => _fazerLogin(), // Enter → faz login
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _fazerLogin,
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
