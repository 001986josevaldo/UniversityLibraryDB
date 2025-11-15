import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblio/main.dart';
import 'package:biblio/features/models/book_model.dart';

class AddBookPage extends StatefulWidget {
  final VoidCallback? onBookAdded;
  final BookModel? existingBook;

  const AddBookPage({super.key, this.onBookAdded, this.existingBook});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Preenche dados caso seja edição
    if (widget.existingBook != null) {
      _titleController.text = widget.existingBook!.title;
      _authorController.text = widget.existingBook!.author;
      _locationController.text = widget.existingBook!.location;
      _quantityController.text = widget.existingBook!.quantity_total.toString();
    }
  }

  // --- Criar ou Editar Livro ---
  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final author = _authorController.text.trim();
      final location = _locationController.text.trim();
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

      // ======== EDITAR ========
      if (widget.existingBook != null) {
        await supabase
            .from('books')
            .update({
              'title': title,
              'author': author,
              'location': location,
              'quantity_total': quantity,
            })
            .eq('id', widget.existingBook!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Livro "$title" atualizado com sucesso!'),
              backgroundColor: Colors.green[700],
            ),
          );
        }

        Navigator.pop(context, true);
        return;
      }

      // ======== CRIAR ========
      await supabase.from('books').insert({
        'title': title,
        'author': author,
        'location': location,
        'quantity_total': quantity,
        'quantity_available': quantity,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro "$title" cadastrado com sucesso!'),
            backgroundColor: Colors.green[700],
          ),
        );

        widget.onBookAdded?.call();

        _formKey.currentState!.reset();
        _titleController.clear();
        _authorController.clear();
        _locationController.clear();
        _quantityController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar livro: $e'),
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
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBook != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Livro' : 'Cadastrar Novo Livro',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Livro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o autor' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a localização' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Total',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quantidade';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveBook,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                ),
                child: Text(
                  _isLoading
                      ? 'Salvando...'
                      : isEditing
                      ? 'Salvar Alterações'
                      : 'Cadastrar Livro',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
