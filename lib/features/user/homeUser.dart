import 'package:flutter/material.dart';
import 'package:biblio/features/models/book_model.dart';
import '../../../../routes/app_routes.dart';
import 'package:biblio/features/header/header.dart';
import 'package:biblio/main.dart'; // para supabase
// 2. IMPORTA bottom,NavBar
import 'package:biblio/features/navBar/bottomNavBar.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();

  // --- ESTADOS DA TELA ---

  List<BookModel> _masterBookList = []; // Guarda a todos os livros do DB
  List<BookModel> _filteredBooks = []; // Guarda a lista filtrada
  bool _isLoading = true; // Controla o loading inicial
  String _userType = ''; // Guarda o tipo de usuário
  // 3. NOVO ESTADO PARA CONTROLAR A ABA ATIVA
  int _selectedIndex = 0; // "Buscar" é a aba 0 (inicial)

  // 2. BUSCA OS DADOS NO 'initState' (QUANDO A TELA INICIA)
  @override
  void initState() {
    super.initState();
    // Adiciona o listener para o filtro em tempo real
    _searchController.addListener(_onSearchChanged);
    // Busca os livros
    _fetchInitialBooks(); // busca os dados a primeira vez
  }

  // 3. PEGA O 'userType' QUANDO AS DEPENDÊNCIAS MUDAM
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pega o 'userType' ('admin' ou 'user') vindo do login
    _userType = ModalRoute.of(context)!.settings.arguments as String;
  }

  // 4. LIMPEZA DOS CONTROLLERS
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // 4. NOVA FUNÇÃO CHAMADA QUANDO UMA ABA É TOCADA
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 4. FUNÇÃO DE BUSCA NO SUPABASE
  //    (AGORA TAMBÉM MOSTRA O LOADING)
  Future<void> _fetchInitialBooks() async {
    // 1. ADICIONAMOS O LOADING NO INÍCIO
    //    (Isso garante que o loading apareça ao recarregar)
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
          // 2. ATUALIZAMOS O FILTRO
          //    Isso garante que, se o usuário voltar,
          //    o filtro (mesmo limpo) seja aplicado aos novos dados.
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

  // 6. FUNÇÃO DO FILTRO EM TEMPO REAL (COMO VOCÊ PEDIU)
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    _filterBooks(query);
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        // Se a busca está vazia, mostra todos os livros
        _filteredBooks = _masterBookList;
      } else {
        // Filtra a lista mestre
        _filteredBooks = _masterBookList.where((book) {
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // FUNÇÃO DE COR
  Color _getAvailabilityColor(int available) {
    if (available > 1) {
      return Colors.green[700]!; // Disponível para reserva
    }
    if (available == 1) {
      return Colors.orange[800]!; // Mínimo atingido (não reserva)
    }
    return Colors.grey[600]!; // Emprestado
  }

  @override
  Widget build(BuildContext context) {
    // Escolhe o ícone do usuário para a AppBar
    final IconData userIcon = (_userType == 'admin')
        ? Icons.admin_panel_settings
        : Icons.person;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'University Library',
        leading: Icon(userIcon, size: 28),
      ),

      // 5. O 'body' AGORA USA O 'IndexedStack' PARA TROCAR DE TELA
      //    sem perder o estado de cada aba
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Tela 0: Buscar (Sua lógica antiga)
          _buildSearchPage(),
          // Tela 1: Minhas Reservas (Placeholder)
          _buildPlaceholderPage('Minhas Reservas'),
          // Tela 2: Perfil (Placeholder)
          _buildPlaceholderPage('Perfil'),
        ],
      ),

      // 6. ADICIONA A BARRA DE NAVEGAÇÃO REUTILIZÁVEL
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // 7. A LÓGICA DE BUSCA FOI MOVIDA PARA ESTE WIDGET
  Widget _buildSearchPage() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
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

  // Área de Resultados (Não mudou)
  Widget _buildResultsArea() {
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

    // Se temos resultados, mostramos a lista
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

                  // Se for ADMIN
                  if (_userType == 'admin') {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.adminItemDetails,
                      arguments: {'book': book, 'userType': _userType},
                    );
                    didNavigate = true;
                  }
                  // Se for USER
                  else if (book.canBeReserved) {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.itemDetails,
                      arguments: {'book': book, 'userType': _userType},
                    );
                    didNavigate = true;
                  }
                  // Se for USER e não pode reservar
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Este livro não está disponível para reserva no momento.',
                        ),
                        backgroundColor: Colors.orange[800],
                      ),
                    );
                  }

                  // A CORREÇÃO:
                  //    Recarrega os livros do Supabase ao voltar
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

  // 8. WIDGET DE PLACEHOLDER PARA AS NOVAS ABAS
  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        '$title (Em breve)',
        style: const TextStyle(fontSize: 24, color: Colors.grey),
      ),
    );
  }
}
