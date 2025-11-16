import 'package:flutter/material.dart';
import 'package:biblio/features/models/book_model.dart';
import '../../../../routes/app_routes.dart';
import 'package:biblio/features/header/header.dart';
import 'package:biblio/main.dart'; // para supabase
import 'package:biblio/features/navBar/bottomNavBarAdmin.dart';
import 'package:biblio/features/admin/add_book_page.dart';

// ✨ 1. IMPORTE AS ABAS QUE CRIAMOS
import 'package:biblio/features/admin/tabs/admin_search_tab.dart';
import 'package:biblio/features/admin/tabs/admin_reservations_tab.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // ✨ 2. ESTADO MÍNIMO
  List<BookModel> _masterBookList = [];
  bool _isLoading = true;
  String _userType = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialBooks();
  }

  // ✨ 3. CORREÇÃO DO ERRO 'TypeError' (Tela Vermelha)
  // (Substituindo o)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userType.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _userType = args;
      } else {
        _userType = 'admin'; // Valor padrão para segurança
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Apenas busca os livros, as abas fazem o filtro
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

  void _handleBookAdded() async {
    await _fetchInitialBooks();
    if (mounted) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData userIcon = (_userType == 'admin')
        ? Icons.admin_panel_settings
        : Icons.person;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'University Library',
        leading: Icon(userIcon, size: 28),
      ),

      // ✨ 4. BODY CORRIGIDO
      // (Substituindo o pelo IndexedStack)
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Tela 0: Buscar (Usa o widget AdminSearchTab)
          AdminSearchTab(
            masterBookList: _masterBookList,
            isLoading: _isLoading,
            userType: _userType,
            onRefresh: _fetchInitialBooks,
          ),

          // Tela 1: Adicionar Livro
          AddBookPage(onBookAdded: _handleBookAdded),

          // Tela 2: Reservas (Usa o widget AdminReservationsTab)
          AdminReservationsTab(
            masterBookList: _masterBookList, // (ignorado pela aba)
            isLoading: _isLoading, // (ignorado pela aba)
            userType: _userType,
            onRefresh: _fetchInitialBooks,
          ),
        ],
      ),

      bottomNavigationBar: CustomAdminNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
