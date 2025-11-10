import 'package:flutter/material.dart';
import 'package:biblio/features/models/book_model.dart';
import '../../../../routes/app_routes.dart';
import 'package:biblio/features/header/header.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<BookModel> _allBooks = [
    BookModel(
      title: 'Livro1',
      author: 'Autor do Livro 1',
      status: 'Disponível',
      location: 'Corredor 5, Seção A',
    ),
    BookModel(
      title: 'Livro2',
      author: 'Autor do Livro 2',
      status: 'Emprestado',
      location: 'Corredor 2, Seção B',
    ),
    BookModel(
      title: 'Flutter',
      author: 'Alex Silva',
      status: 'Disponível',
      location: 'Corredor 1, Seção A',
    ),
    BookModel(
      title: 'Dart',
      author: 'Maria Souza',
      status: 'Disponível',
      location: 'Corredor 1, Seção A',
    ),
    BookModel(
      title: 'Engenharia',
      author: 'Carlos Paiva',
      status: 'Emprestado',
      location: 'Corredor 3, Seção C',
    ),
  ];

  List<BookModel> _filteredBooks = [];
  bool _searchPerformed = false;

  // Função de busca
  void _runSearch() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredBooks = [];
        _searchPerformed = false;
      } else {
        _searchPerformed = true;
        _filteredBooks = _allBooks.where((book) {
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    return status == 'Disponível' ? Colors.green[700]! : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    final userType = ModalRoute.of(context)!.settings.arguments as String;

    final IconData userIcon = (userType == 'admin')
        ? Icons.admin_panel_settings
        : Icons.person;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'University Library',
        leading: Icon(userIcon, size: 28),
      ),
      body: Column(
        children: [
          // Cabeçalho da busca
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(Icons.menu, color: Colors.teal[800]),
                const SizedBox(width: 16),
                Text(
                  'Buscar no Acervo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
          ),

          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite sua busca...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _runSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _runSearch(),
            ),
          ),

          // Resultados
          Expanded(child: _buildResultsArea(userType)),
        ],
      ),
    );
  }

  Widget _buildResultsArea(String userType) {
    if (!_searchPerformed) return Container();

    if (_filteredBooks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Nenhum resultado encontrado.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Text(
              '— Resultados —',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Lista de resultados
        Expanded(
          child: ListView.builder(
            itemCount: _filteredBooks.length,
            itemBuilder: (context, index) {
              final book = _filteredBooks[index];

              return InkWell(
                onTap: () async {
                  // Define rota conforme tipo de usuário
                  final String destinationRoute = (userType == 'admin')
                      ? AppRoutes.adminItemDetails
                      : AppRoutes.itemDetails;

                  final arguments = {'book': book, 'userType': userType};

                  // Usuário comum só pode abrir livros disponíveis
                  if (userType == 'user' && !book.isAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Este livro não está disponível para reserva.',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  await Navigator.pushNamed(
                    context,
                    destinationRoute,
                    arguments: arguments,
                  );

                  // Limpa busca ao retornar
                  if (mounted) {
                    setState(() {
                      _searchController.clear();
                      _filteredBooks = [];
                      _searchPerformed = false;
                    });
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  color: Colors.teal[50],
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(book.author, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(
                          'Status: [${book.status}]',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(book.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
