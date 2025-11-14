import 'package:flutter/material.dart';
// Importe seu modelo de dados
import 'package:biblio/features/models/book_model.dart';
import 'package:biblio/features/header/header.dart';
// 2. IMPORTE O CLIENTE SUPABASE
import 'package:biblio/main.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  // 3. ESTADO DE LOADING PARA A RESERVA
  bool _isReservando = false;
  //String _userType = ''; // Guarda o tipo de usuário

  // 4. FUNÇÃO DE RESERVA (AGORA CHAMA O SUPABASE)
  Future<void> _handleReservation(BookModel book) async {
    // Inicia o loading
    setState(() {
      _isReservando = true;
    });

    try {
      // 5. CHAMA A FUNÇÃO 'reserve_book' QUE CRIAMOS NO SQL
      //    Ela cuidará de diminuir a quantidade E criar a reserva
      await supabase.rpc(
        'reserve_book',
        params: {'book_id_to_reserve': book.id},
      );

      // 6. SUCESSO
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro "${book.title}" reservado com sucesso!'),
            backgroundColor: Colors.green[700],
          ),
        );
        // Volta para a tela anterior (a home)
        Navigator.pop(context);
      }
    } catch (e) {
      // 7. FALHA (Ex: Se a função do Supabase der o ERRO "quantidade mínima")
      if (mounted) {
        // Pega a mensagem de erro vinda do Supabase
        final String errorMessage = e.toString().contains("Quantidade mínima")
            ? 'Não é possível reservar: Quantidade mínima atingida.'
            : 'Erro ao reservar: ${e.toString()}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Para o loading, independente do resultado
      if (mounted) {
        setState(() {
          _isReservando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final book = arguments['book'] as BookModel;
    // final userType = arguments['userType'] as String; // (Não usado aqui, mas recebido)

    final Color secondaryColor = Colors.teal[50]!;
    final Color buttonColor = Colors.teal[600]!;

    // 8. VERIFICA A SUA REGRA DE NEGÓCIO (usando o getter do book_model.dart)
    //    (O botão deve ser clicável?)
    final bool podeReservar =
        book.canBeReserved; // (true se quantity_available > 1)

    // final IconData userIcon = (_userType == 'admin')
    //     ? Icons.admin_panel_settings
    //     : Icons.person;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: CustomAppBar(
        title: 'University Library',
        //leading: Icon(userIcon, size: 28),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Localização:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.location,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  // 9. MOSTRA A QUANTIDADE ATUAL
                  const Text(
                    'Disponíveis:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${book.quantity_available} de ${book.quantity_total} cópias',
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------
          // Botão "Reservar" (no rodapé)
          // ---------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: ElevatedButton(
              // 10. LÓGICA DO BOTÃO ATUALIZADA
              //     Desabilita se estiver 'Reservando' OU se 'não pode reservar'
              onPressed: (_isReservando || !podeReservar)
                  ? null // Botão desabilitado
                  : () => _handleReservation(book),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                // Fica cinza se estiver desabilitado
                disabledBackgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 11. TEXTO DO BOTÃO ATUALIZADO
              child: Text(
                _isReservando
                    ? 'Reservando...'
                    : (podeReservar
                          ? 'Reservar'
                          : 'Quantidade mínima atingida'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
