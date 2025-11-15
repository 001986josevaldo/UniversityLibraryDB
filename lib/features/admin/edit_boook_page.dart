import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para TextInputFormatters
import '../models/book_model.dart';
import 'package:biblio/main.dart'; // Para 'supabase'
import 'package:biblio/features/header/header.dart'; // Para CustomAppBar

class EditBookPage extends StatefulWidget {
  final BookModel book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para os campos do formulário
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _locationController;
  late TextEditingController _totalQuantityController;

  @override
  void initState() {
    super.initState();
    // 1. Pré-preenche os controladores com os dados do livro
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _locationController = TextEditingController(text: widget.book.location);
    _totalQuantityController = TextEditingController(
      text: widget.book.quantity_total.toString(),
    );
  }

  @override
  void dispose() {
    // 2. Limpa os controladores ao sair da tela
    _titleController.dispose();
    _authorController.dispose();
    _locationController.dispose();
    _totalQuantityController.dispose();
    super.dispose();
  }

  // 3. Função para salvar as alterações
  Future<void> _saveChanges() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTitle = _titleController.text.trim();
      final newAuthor = _authorController.text.trim();
      final newLocation = _locationController.text.trim();
      final newTotalQuantity = int.parse(_totalQuantityController.text);

      // LÓGICA IMPORTANTE:
      // Precisamos recalcular a 'quantidade_disponivel' com base na nova 'total'.
      // Ex: Se haviam 10 (total) e 8 (disponivel), 2 estavam reservados.
      // Se o novo total for 12, o novo disponivel será 12 - 2 = 10.
      final int currentReservations =
          widget.book.quantity_total - widget.book.quantity_available;

      // Validação: O novo total não pode ser menor que o n° de reservas
      if (newTotalQuantity < currentReservations) {
        throw Exception(
          'A quantidade total não pode ser menor que o número de livros já reservados/emprestados ($currentReservations).',
        );
      }

      final newAvailableQuantity = newTotalQuantity - currentReservations;

      // 4. Envia a atualização para o Supabase
      await supabase
          .from('books')
          .update({
            'title': newTitle,
            'author': newAuthor,
            'location': newLocation,
            'quantity_total': newTotalQuantity,
            'quantity_available':
                newAvailableQuantity, // Atualiza o disponível!
          })
          .eq('id', widget.book.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livro atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para a tela de detalhes
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Editar Livro'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // --- Campo Título ---
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O título é obrigatório.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Autor ---
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Autor'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O autor é obrigatório.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Localização ---
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localização (Ex: A-01)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'A localização é obrigatória.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Quantidade Total ---
            TextFormField(
              controller: _totalQuantityController,
              decoration: const InputDecoration(labelText: 'Quantidade Total'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'A quantidade é obrigatória.';
                }
                if (int.tryParse(value) == null) {
                  return 'Insira um número válido.';
                }
                if (int.parse(value) < 0) {
                  return 'A quantidade não pode ser negativa.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // --- Botão Salvar ---
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
