import 'package:flutter/material.dart';

/// Um widget reutilizável para a barra de navegação inferior.
///
/// Ele é "burro", ou seja, não guarda estado. Ele recebe o
/// índice atual e uma função 'onTap' da tela "mãe" (a home).
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
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
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark),
          label: 'Minhas Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],

      // 3. Estilo
      selectedItemColor: Colors.teal[800],
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed, // Para mostrar o label de todos
    );
  }
}
