import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:biblio/features/header/header.dart';
import 'package:biblio/main.dart';

class AdminItemDetailsPage extends StatefulWidget {
  const AdminItemDetailsPage({super.key});

  @override
  State<AdminItemDetailsPage> createState() => _AdminItemDetailsPageState();
}

class _AdminItemDetailsPageState extends State<AdminItemDetailsPage> {
  bool _isDeleting = false;
  bool _isReturning = false;

  // --- Remover Livro ---
  Future<void> _deleteBook(BookModel book) async {
    // 🔍 1. Verificar se o livro possui reservas
    final reservations = await supabase
        .from('reservations')
        .select()
        .eq('book_id', book.id);

    if (reservations.isNotEmpty) {
      // ❌ Não permite excluir se houver reservas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não é possível remover: ainda existem reservas relacionadas a este livro.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // 🔚 encerra a função aqui
    }

    // 🔄 2. Se chegou aqui, pode excluir normalmente
    setState(() {
      _isDeleting = true;
    });

    try {
      await supabase.from('books').delete().eq('id', book.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro "${book.title}" removido com sucesso.'),
            backgroundColor: Colors.green[700],
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover livro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // --- Dar baixa ---
  Future<void> _returnBook(BookModel book) async {
    setState(() => _isReturning = true);

    try {
      await supabase.rpc('return_book', params: {'book_id_to_return': book.id});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Baixa registrada com sucesso!'),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      final String msg = e.toString().contains("Estoque já está cheio")
          ? 'Não é possível devolver: Estoque cheio.'
          : 'Erro ao dar baixa: $e';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isReturning = false);
    }
  }

  // --- Editar Livro (placeholder) ---
  void _editBook(BookModel book) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela de edição ainda não implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final book = arguments['book'] as BookModel;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes (Admin)'),

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
            const SizedBox(height: 24),

            const Text(
              'Localização:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(book.location, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            const Text(
              'Inventário:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${book.quantity_available} disponíveis (de ${book.quantity_total})',
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),
          ],
        ),
      ),

      // -----------------------------
      // NOVO “NAVBAR ADMINISTRATIVO”
      // -----------------------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,

        onTap: (index) {
          switch (index) {
            case 0:
              if (!_isDeleting) _deleteBook(book);
              break;
            case 1:
              if (!_isReturning) _returnBook(book);
              break;
            case 2:
              _editBook(book);
              break;
          }
        },

        items: [
          BottomNavigationBarItem(
            icon: _isDeleting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            label: "Remover",
          ),
          BottomNavigationBarItem(
            icon: _isReturning
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.restart_alt),
            label: "Baixa",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Editar",
          ),
        ],
      ),
    );
  }
}
