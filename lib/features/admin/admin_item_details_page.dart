import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:biblio/features/header/header.dart';
import 'package:biblio/main.dart'; // Para a variável 'supabase'

/// (Página RF009, RF010)
/// Tela que o Admin vê ao clicar em um item da busca.
/// Exibe os detalhes e permite ações administrativas.
class AdminItemDetailsPage extends StatefulWidget {
  const AdminItemDetailsPage({super.key});

  @override
  State<AdminItemDetailsPage> createState() => _AdminItemDetailsPageState();
}

class _AdminItemDetailsPageState extends State<AdminItemDetailsPage> {
  // 2. ESTADO DE LOADING PARA A EXCLUSÃO
  bool _isDeleting = false;
  // 2. NOVO ESTADO DE LOADING PARA A DEVOLUÇÃO
  bool _isReturning = false;

  // 3. FUNÇÃO PARA REMOVER O LIVRO (CHAMA O SUPABASE)
  Future<void> _deleteBook(BookModel book) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // (RF009) Executa a exclusão na tabela 'books'
      await supabase.from('books').delete().eq('id', book.id);

      if (mounted) {
        // (RF010) Mostra a confirmação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro "${book.title}" removido com sucesso.'),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context); // Volta para a tela de busca
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

  // 4. NOVA FUNÇÃO PARA "DAR BAIXA" (DEVOLVER O LIVRO)
  Future<void> _returnBook(BookModel book) async {
    setState(() {
      _isReturning = true;
    });

    try {
      // Chama a função 'return_book' que criamos no SQL
      await supabase.rpc('return_book', params: {'book_id_to_return': book.id});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Baixa de empréstimo do livro "${book.title}" registrada.',
            ),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context); // Volta para a home (e força a recarregar)
      }
    } catch (e) {
      // Captura o erro da nossa função SQL
      final String errorMessage = e.toString().contains("Estoque já está cheio")
          ? 'Não é possível devolver: Estoque já está cheio.'
          : 'Erro ao dar baixa: ${e.toString()}';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReturning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recebe os argumentos (o livro e o userType)
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
            // (O resto dos detalhes do livro)
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
              '${book.quantity_available} disponíveis (de ${book.quantity_total} no total)',
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            // (RF009) Botão de Remover (Não mudou)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _isDeleting ? null : () => _deleteBook(book),
              child: Text(
                _isDeleting ? 'Removendo...' : 'Remover Item',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),

            // 5. BOTÃO "BAIXA EMPRÉSTIMO" (ATUALIZADO)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              // Chama a nova função _returnBook
              onPressed: _isReturning ? null : () => _returnBook(book),
              child: Text(
                _isReturning ? 'Dando Baixa...' : 'Baixa Empréstimo',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
