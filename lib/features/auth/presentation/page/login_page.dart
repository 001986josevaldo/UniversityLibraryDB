import 'package:flutter/material.dart';
// 1. IMPORTE O SUPABASE E O CLIENTE
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:biblio/main.dart'; // Importa a variável 'supabase'
import '../../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. MUDAMOS OS NOMES DOS CONTROLLERS PARA CLAREZA
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _mostrarSenha = false;
  bool _isLoading = false; // 3. ESTADO DE LOADING

  // 4. FUNÇÃO DE LOGIN TOTALMENTE REFEITA
  Future<void> _fazerLogin() async {
    // Validação de campos vazios
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    // Inicia o loading
    setState(() {
      _isLoading = true;
    });

    try {
      // ------------------------------------------------
      // DEBUG: ADICIONAMOS PRINTS AQUI
      // ------------------------------------------------
      debugPrint("1. Tentando fazer login com: $email");

      // 5. TENTA FAZER O LOGIN NO SUPABASE AUTH
      await supabase.auth.signInWithPassword(email: email, password: senha);

      debugPrint("2. Login OK! Buscando perfil...");

      // 6. SE O LOGIN DER CERTO, BUSCA O 'ROLE' NA TABELA 'PROFILES'
      //    (Exatamente como planejamos no banco de dados)
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select('role') // Queremos saber se é 'admin' ou 'user'
          .eq('id', userId)
          .single(); // Pega apenas um resultado

      final role = data['role'] as String;

      debugPrint("3. Perfil OK! Role é: $role");

      // 7. USA O 'ROLE' PARA NAVEGAR (E PASSA O 'ROLE' ADIANTE)
      if (!mounted) return; // Checagem de segurança em funções async

      // ------------------------------------------------
      // DEBUG: CORRIGIMOS A ROTA TEMPORARIAMENTE
      // ------------------------------------------------
      // Seu 'AppRoutes.adminHome' pode não estar registrado no main.dart ainda.
      // Vamos forçar a ida para 'userHome' por enquanto.
      final destination = (role == 'admin')
          ? AppRoutes.adminHome
          : AppRoutes.userHome;

      // (A linha original era:)
      // final destination =
      //     (role == 'admin') ? AppRoutes.adminHome : AppRoutes.userHome;

      Navigator.pushReplacementNamed(
        context,
        destination,
        arguments: role, // Passa o 'role' (admin/user)
      );
    } on AuthException catch (e) {
      // 8. TRATA ERROS DE AUTENTICAÇÃO
      debugPrint("ERRO DE AUTH: ${e.message}"); // DEBUG
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      // 9. TRATA ERROS GERAIS (Ex: Falha de rede)
      debugPrint("ERRO GERAL: ${e.toString()}"); // DEBUG
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorreu um erro. Tente novamente.')),
        );
      }
    } finally {
      // 10. PARA O LOADING, INDEPENDENTE DE SUCESSO OU FALHA
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                'University Library',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 32),
              // 11. CAMPO MUDADO PARA "Email"
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email', // <-- MUDANÇA AQUI
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
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
                onSubmitted: (_) => _fazerLogin(),
              ),
              const SizedBox(height: 24),
              // 12. BOTÃO DESABILITADO DURANTE O LOADING
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 48),
                ),
                // Se estiver carregando (_isLoading), 'onPressed' é null
                onPressed: _isLoading ? null : _fazerLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
