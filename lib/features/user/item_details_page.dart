import 'package:flutter/material.dart';
// Importe seu modelo de dados
import 'package:biblio/features/models/book_model.dart';
import 'package:biblio/features/header/header.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  // Estado para controlar se o botão "Reservar" foi clicado
  bool _isReserved = false;

  // Função chamada pelo botão "Reservar"
  void _handleReservation(String bookTitle) {
    setState(() {
      _isReserved = true;
    });

    // Mostra a confirmação (RF006)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Livro "$bookTitle" reservado com sucesso!'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );

    // ✅ Retorna automaticamente após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Recebe o objeto 'book' que foi passado pela UserHomePage
    // ✅ Recebe o mapa com os dados vindos da UserHomePage
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final BookModel book = args['book'];
    final String userType = args['userType'];

    // Cores baseadas na sua imagem
    //final Color primaryColor = Colors.teal[300]!;
    final Color secondaryColor = Colors.teal[50]!;
    final Color buttonColor = Colors.teal[600]!;

    return Scaffold(
      backgroundColor: secondaryColor, // Cor de fundo do corpo

      appBar: const CustomAppBar(title: 'University Library'),

      // Usamos Column para empilhar o conteúdo e o botão
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------------------------
          // Conteúdo Principal (Informações)
          // ---------------------------------
          // 'Expanded' faz o conteúdo ocupar todo o espaço
          // disponível, empurrando o botão para baixo.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title, // "Título do (Livro 1)"
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author, // "Autor do (Livro 1)"
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Localização:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.location, // "Corredor 5, Seção A"
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------
          // Botão "Reservar" (no rodapé)
          // ---------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Espaçamento
            child: ElevatedButton(
              // Desabilita o botão se já estiver reservado
              onPressed: _isReserved
                  ? null
                  : () => _handleReservation(book.title),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Muda o texto do botão após a reserva
              child: Text(_isReserved ? 'Reservado' : 'Reservar'),
            ),
          ),
        ],
      ),
    );
  }
}
