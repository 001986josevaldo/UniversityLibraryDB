import 'package:flutter/material.dart';

/// Um widget reutilizável para a barra de navegação
/// específica do Administrador.
class CustomAdminNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomAdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // 1. Conecta os valores recebidos do widget "mãe"
      currentIndex: currentIndex,
      onTap: onTap,

      // 2. Define os itens da barra
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar', // (Aba 0)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Adicionar', // (Aba 1)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Gerenciar', // (Aba 2)
        ),
      ],

      // 3. Estilo
      selectedItemColor: Colors.teal[800],
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
    );
  }
}
