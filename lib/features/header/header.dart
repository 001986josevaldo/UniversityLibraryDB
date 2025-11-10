import 'package:flutter/material.dart';
// Precisamos das rotas para a função de 'Sair' (Logout)
import '../../../../routes/app_routes.dart';

// Esta é a sua classe "só para isso" (o header reutilizável)
// Ela implementa 'PreferredSizeWidget' para ser usada como uma AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // O título que a tela vai exibir
  final String title;
  final Widget? leading; // icone que vai ser alterado

  // Um booleano para decidir se o botão de 'Sair' deve aparecer
  // (útil se você quiser reusar em uma tela que não precise de logout)
  //final bool showLogoutButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    //this.showLogoutButton = true, // Por padrão, o botão aparece
  });

  // Método de logout
  void _logout(BuildContext context) {
    // Navega para a tela de login e remove todas as outras telas da pilha
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 1. USA O WIDGET 'leading' QUE FOI PASSADO
      leading: leading,

      // 2. Título
      title: Text(title),

      // 3. Ações da Direita (Sair)
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, size: 28),
          tooltip: 'Sair',
          onPressed: () {
            // Volta para a tela de login
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false, // Remove todas as telas anteriores
            );
          },
        ),
      ],
      backgroundColor: Colors.teal[300]!,
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
