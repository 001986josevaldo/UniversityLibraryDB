// features/admin/tabs/admin_search_tab.dart
import 'package:flutter/material.dart';
import 'package:biblio/features/models/book_model.dart';
import 'package:biblio/routes/app_routes.dart';

class AdminSearchTab extends StatefulWidget {
  final List<BookModel> masterBookList;
  final bool isLoading;
  final String userType;
  // Callback para o homeAdmin recarregar os livros
  final Future<void> Function() onRefresh;

  const AdminSearchTab({
    super.key,
    required this.masterBookList,
    required this.isLoading,
    required this.userType,
    required this.onRefresh,
  });

  @override
  State<AdminSearchTab> createState() => _AdminSearchTabState();
}

class _AdminSearchTabState extends State<AdminSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    // Inicia o filtro com a lista mestra recebida
    _filterBooks(widget.masterBookList, _searchController.text);
    // Adiciona o listener para filtrar em tempo real
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant AdminSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a lista mestra mudou (ex: após adicionar um livro),
    // atualiza o filtro
    if (oldWidget.masterBookList != widget.masterBookList) {
      _filterBooks(widget.masterBookList, _searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterBooks(widget.masterBookList, _searchController.text);
  }

  void _filterBooks(List<BookModel> masterList, String queryText) {
    final query = queryText.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = masterList;
      } else {
        _filteredBooks = masterList.where((book) {
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Color _getAvailabilityColor(int available) {
    if (available > 1) {
      return Colors.green[700]!;
    }
    if (available == 1) {
      return Colors.orange[800]!;
    }
    return Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Digite o título ou autor...',
              suffixIcon: IconButton(
                icon: _searchController.text.isEmpty
                    ? const Icon(Icons.search)
                    : const Icon(Icons.clear),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _searchController.clear();
                  }
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(child: _buildResultsArea()),
      ],
    );
  }

  Widget _buildResultsArea() {
    if (_filteredBooks.isEmpty) {
      if (widget.masterBookList.isEmpty && !widget.isLoading) {
        return const Center(
          child: Text(
            'Nenhum livro cadastrado no sistema.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
      }
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
        Expanded(
          child: ListView.builder(
            itemCount: _filteredBooks.length,
            itemBuilder: (context, index) {
              final book = _filteredBooks[index];

              return InkWell(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.adminItemDetails,
                    arguments: {'book': book, 'userType': widget.userType},
                  );

                  // Ao voltar, chama o callback de refresh do homeAdmin
                  if (mounted) {
                    _searchController.clear();
                    await widget.onRefresh();
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
                          'Disponíveis: ${book.quantity_available} (de ${book.quantity_total})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _getAvailabilityColor(
                              book.quantity_available,
                            ),
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
