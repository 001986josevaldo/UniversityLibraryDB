// features/admin/tabs/admin_reservations_tab.dart
import 'package:flutter/material.dart';
import 'package:biblio/features/models/book_model.dart';
import 'package:biblio/routes/app_routes.dart';
import 'package:biblio/main.dart';
import 'package:intl/intl.dart';

class ReservationDetail {
  final int id;
  final String status;
  final DateTime? dueDate;
  final String bookTitle;
  final String bookAuthor;
  final String userMatricula;
  final String userEmail;
  final Map<String, dynamic> bookData;

  ReservationDetail({
    required this.id,
    required this.status,
    this.dueDate,
    required this.bookTitle,
    required this.bookAuthor,
    required this.userMatricula,
    required this.userEmail,
    required this.bookData,
  });

  factory ReservationDetail.fromMap(Map<String, dynamic> map) {
    final bookData = map['books'] as Map<String, dynamic>? ?? {};
    final profileData = map['profiles'] as Map<String, dynamic>? ?? {};

    return ReservationDetail(
      id: map['id'] ?? 0,
      status: map['status'] ?? 'desconhecido',
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      bookTitle: bookData['title'] ?? 'Livro desconhecido',
      bookAuthor: bookData['author'] ?? 'Autor desconhecido',

      // LER DIRETO DO JOIN DE PROFILES
      userMatricula: profileData['matricula'] ?? 'Sem matrícula',
      userEmail: profileData['email'] ?? 'Sem email',

      bookData: bookData,
    );
  }
}

class AdminReservationsTab extends StatefulWidget {
  final List<BookModel> masterBookList;
  final bool isLoading;
  final String userType;
  final Future<void> Function() onRefresh;

  const AdminReservationsTab({
    super.key,
    required this.masterBookList,
    required this.isLoading,
    required this.userType,
    required this.onRefresh,
  });

  @override
  State<AdminReservationsTab> createState() => _AdminReservationsTabState();
}

class _AdminReservationsTabState extends State<AdminReservationsTab> {
  List<ReservationDetail> _reservations = [];
  bool _isTabLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchReservations(); // toda vez que a tela voltar ao foco
  }

  Future<void> _fetchReservations() async {
    if (mounted) {
      setState(() => _isTabLoading = true);
    }

    try {
      //
      // JOIN 100% CORRETO:
      // reservations.user_id -> profiles.id
      //
      final data = await supabase
          .from('reservations')
          .select('''
            id,
            status,
            due_date,
            books:book_id (*),
            profiles:user_id (
              id,
              matricula,
              email
            )
          ''')
          .inFilter('status', ['reservado', 'emprestado']);

      final reservations = data
          .map((map) => ReservationDetail.fromMap(map as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _reservations = reservations;
          _isTabLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTabLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao buscar reservas: $e')));
      }
      print('Erro ao buscar reservas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isTabLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.bookmark_added, color: Colors.teal[800]),
              const SizedBox(width: 16),
              Text(
                'Reservas e Empréstimos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        Expanded(child: _buildReservationsList()),
      ],
    );
  }

  Widget _buildReservationsList() {
    if (_reservations.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma reserva ativa no momento.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        final book = BookModel.fromMap(reservation.bookData);

        String formattedDate = 'Data não definida';
        if (reservation.dueDate != null) {
          formattedDate = DateFormat('dd/MM/yyyy').format(reservation.dueDate!);
        }

        final cardColor = reservation.status == 'reservado'
            ? Colors.yellow[100]
            : Colors.orange[100];
        final statusColor = reservation.status == 'reservado'
            ? Colors.black87
            : Colors.red[700];

        return InkWell(
          onTap: () async {
            await Navigator.pushNamed(
              context,
              AppRoutes.adminItemDetails,
              arguments: {'book': book, 'userType': widget.userType},
            );

            if (mounted) {
              await widget.onRefresh();
              await _fetchReservations();
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: cardColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Matrícula: ${reservation.userMatricula}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    reservation.userEmail,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const Divider(height: 12, color: Colors.grey),

                  Text(
                    reservation.bookTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    reservation.bookAuthor,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Status: ${reservation.status.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    'Devolução: $formattedDate',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
