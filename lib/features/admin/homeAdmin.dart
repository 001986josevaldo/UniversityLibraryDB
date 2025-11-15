import 'package:flutter/material.dart';
import 'package:biblio/features/models/book_model.dart';
import '../../../../routes/app_routes.dart';
import 'package:biblio/features/header/header.dart';
import 'package:biblio/main.dart'; // para supabase
// 2. IMPORTA bottom,NavBar
import 'package:biblio/features/navBar/bottomNavBarAdmin.dart';
// 3. IMPORTE A NOVA PÁGINA/ABA DE ADICIONAR
import 'package:biblio/features/admin/add_book_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController _searchController = TextEditingController();

  // --- ESTADOS DA TELA ---
  List<BookModel> _masterBookList = [];
  List<BookModel> _filteredBooks = [];
  bool _isLoading = true;
  String _userType = '';
  int _selectedIndex = 0; // "Buscar" é a aba 0 (inicial)

  @override
  void initState() {
    super.initState();
    _fetchInitialBooks(); // Carrega os livros
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userType.isEmpty) {
      // Recebe 'admin' da tela de login
      _userType = ModalRoute.of(context)!.settings.arguments as String;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Função chamada pela barra de navegação
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- FUNÇÕES DE BUSCA ---
  // (Esta lógica é idêntica à da UserHomePage)
  Future<void> _fetchInitialBooks() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await supabase.from('books').select();

      if (mounted) {
        final books = data.map((map) => BookModel.fromMap(map)).toList();
        setState(() {
          _masterBookList = books;
          _filterBooks(_searchController.text.trim().toLowerCase());
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar livros: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    _filterBooks(query);
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _masterBookList;
      } else {
        _filteredBooks = _masterBookList.where((book) {
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

  // função para atualizar a lista de livros
  void _refreshBooks() async {
    await _fetchInitialBooks();
  }

  // ✨ 1. NOVA FUNÇÃO (CALLBACK)
  // Esta função irá ATUALIZAR a lista E MUDAR a aba
  void _handleBookAdded() async {
    // 1. Atualiza a lista de livros
    await _fetchInitialBooks();

    // 2. Muda para a aba "Buscar" (índice 0)
    if (mounted) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A lógica do ícone (userIcon) já funciona e mostrará o ícone de admin
    final IconData userIcon = (_userType == 'admin')
        ? Icons.admin_panel_settings
        : Icons.person;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'University Library', // Título atualizado
        leading: Icon(userIcon, size: 28),
      ),

      // 3. O 'body' USA O 'IndexedStack' COM AS ABAS DO ADMIN
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Tela 0: Buscar (A mesma lógica da UserHomePage)
          _buildSearchPage(),

          // Tela 1: Adicionar Livro
          AddBookPage(
            // ✨ 2. MUDANÇA AQUI
            // Trocamos _refreshBooks por _handleBookAdded
            onBookAdded: _handleBookAdded,
          ),

          // Tela 2: Gerenciar (Placeholder)
          _buildPlaceholderPage('Gerenciar Empréstimos'),
        ],
      ),

      // 4. USA A BARRA DE NAVEGAÇÃO DO ADMIN
      bottomNavigationBar: CustomAdminNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // --- WIDGETS DAS ABAS ---
  // (O restante do arquivo permanece exatamente igual)

  // A LÓGICA DE BUSCA (Aba 0)
  Widget _buildSearchPage() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            // ... (código idêntico) ...
            children: [
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

  // Área de Resultados (Aba 0)
  Widget _buildResultsArea() {
    // ... (código idêntico) ...
    if (_filteredBooks.isEmpty) {
      if (_masterBookList.isEmpty && !_isLoading) {
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
                  bool didNavigate = false;

                  // O admin SEMPRE é direcionado para a tela de admin
                  // (Esta lógica já estava correta na UserHomePage)
                  if (_userType == 'admin') {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.adminItemDetails,
                      arguments: {'book': book, 'userType': _userType},
                    );
                    didNavigate = true;
                  }

                  // Recarrega os livros do Supabase ao voltar
                  if (didNavigate && mounted) {
                    _searchController.clear();
                    await _fetchInitialBooks();
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

  // Placeholder para as Abas 1 e 2
  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        '$title (Em breve)',
        style: const TextStyle(fontSize: 24, color: Colors.grey),
      ),
    );
  }
}
