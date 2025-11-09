import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  // O índice do item que está selecionado
  final int currentIndex;

  // A função que será chamada quando um item for tocado
  // (ela "avisa" a tela principal para mudar o estado)
  final Function(int) onTap;

  const MyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // Lista de itens do menu (os ícones)
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar', // (Poderia ser 'Acervo')
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],

      // Conectamos os valores recebidos
      currentIndex: currentIndex,
      onTap: onTap, // Executa a função recebida
      // Estilo
      selectedItemColor: Colors.teal[800],
      backgroundColor: Colors.teal[50], // Cor de fundo
    );
  }
}
