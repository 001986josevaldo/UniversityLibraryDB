import 'package:flutter/material.dart';
// Precisamos das rotas para a função de 'Sair' (Logout)
import '../../../../routes/app_routes.dart';

// Esta é a sua classe "só para isso" (o header reutilizável)
// Ela implementa 'PreferredSizeWidget' para ser usada como uma AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // O título que a tela vai exibir
  final String title;

  // Um booleano para decidir se o botão de 'Sair' deve aparecer
  // (útil se você quiser reusar em uma tela que não precise de logout)
  //final bool showLogoutButton;

  const CustomAppBar({
    super.key,
    required this.title,
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
      title: Text(title),
      backgroundColor: Colors.teal[300], // Usei a cor do seu design
      foregroundColor: Colors.white,
      /*actions: [
        // 'if' para mostrar o botão de logout condicionalmente
        if (showLogoutButton)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _logout(context),
          ),
      ],*/
    );
  }

  // Isso é obrigatório para o Flutter saber o tamanho da AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
