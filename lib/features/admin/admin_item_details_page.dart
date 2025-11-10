import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:biblio/features/header/header.dart';

/// (Página RF009, RF010)
/// Tela que o Admin vê ao clicar em um item da busca.
/// Exibe os detalhes e permite ações administrativas.
class AdminItemDetailsPage extends StatelessWidget {
  const AdminItemDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recebe os argumentos (o livro e o userType)
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final book = arguments['book'] as BookModel;
    // final userType = arguments['userType'] as String; // (userType será 'admin')

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Detalhes (Admin)',
        // A seta "Voltar" é adicionada automaticamente
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(book.author, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text(
              'Local: ${book.location}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${book.status}',
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(), // Empurra os botões para baixo
            // (RF009) Botão de Remover
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                // (Lógica de remoção (RF010) iria aqui)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emprestimo Cancelado'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context); // Volta para a tela de busca
              },
              child: const Text(
                'Baixa Emprestimo',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            // Botão de Editar (placeholder)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                // (Lógica de edição iria aqui)
              },
              child: const Text('Remover Item', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
