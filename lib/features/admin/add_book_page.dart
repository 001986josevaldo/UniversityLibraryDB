import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblio/main.dart'; // Para a variável 'supabase'

/// Este é o widget que representa a "tela" da Aba 1 (Adicionar Livro).
class AddBookPage extends StatefulWidget {
  final VoidCallback? onBookAdded; // <-- ADICIONADO

  const AddBookPage({
    super.key,
    this.onBookAdded, // <-- ADICIONADO
  });

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  // Chave global para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo do formulário
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;

  // Função para salvar o livro no Supabase
  Future<void> _saveBook() async {
    // 1. Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return; // Se não for válido, não faz nada
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Pega os valores dos controladores
      final title = _titleController.text;
      final author = _authorController.text;
      final location = _locationController.text;
      // Converte a quantidade para int (ou 0 se for inválido)
      final quantity = int.tryParse(_quantityController.text) ?? 0;

      // 3. Insere no Supabase
      //    (Conforme a sua regra, quantity_available começa igual a quantity_total)
      await supabase.from('books').insert({
        'title': title,
        'author': author,
        'location': location,
        'quantity_total': quantity,
        'quantity_available': quantity,
      });

      // 4. Sucesso!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro "$title" cadastrado com sucesso!'),
            backgroundColor: Colors.green[700],
          ),
        );
        // 🔥 CHAMA O CALLBACK PARA AVISAR A TELA MÃE que um novo livro foi inserido
        widget.onBookAdded?.call();
        // Limpa o formulário
        _formKey.currentState!.reset();
        _titleController.clear();
        _authorController.clear();
        _locationController.clear();
        _quantityController.clear();
      }
    } catch (e) {
      // 5. Erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar livro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Limpa os controladores
    _titleController.dispose();
    _authorController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView para evitar overflow
    // quando o teclado aparecer
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Título ---
              Text(
                'Cadastrar Novo Livro',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              const SizedBox(height: 24),

              // --- Campo Título ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Livro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Campo Autor ---
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um autor.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Campo Localização ---
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localização (Ex: Corredor 1, Seção A)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a localização.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Campo Quantidade Total ---
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Total',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                // Define o teclado para aceitar apenas números
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor, insira um número válido maior que 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- Botão Salvar ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                // Desabilita o botão durante o loading
                onPressed: _isLoading ? null : _saveBook,
                child: Text(
                  _isLoading ? 'Salvando...' : 'Cadastrar Livro',
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
