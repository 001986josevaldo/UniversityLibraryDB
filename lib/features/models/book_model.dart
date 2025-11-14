// Este modelo ajuda a organizar os dados do livro
class BookModel {
  final int id;
  final String title;
  final String author;
  final String location;

  // 1. CAMPOS DE QUANTIDADE
  final int quantity_total;
  final int quantity_available;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.location,
    required this.quantity_total, // Quantidade total de cópias
    required this.quantity_available, // Quantidade disponível na prateleira
  });

  // 2. LÓGICA DE NEGÓCIO (GETTER)
  //    Isso implementa a sua regra de "sempre ter 1 na biblioteca".
  //    Um livro só pode ser reservado se houver MAIS DE 1 disponível.
  bool get canBeReserved => quantity_available > 1;

  // 3. CONSTRUTOR 'fromMap' (O MAIS IMPORTANTE)
  //    Converte o 'Map' (JSON) que vem do Supabase em um objeto BookModel.
  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as int,
      title: map['title'] as String,
      author: map['author'] as String,
      location: map['location'] as String,
      // Lendo os novos campos de quantidade
      quantity_total: map['quantity_total'] as int,
      quantity_available: map['quantity_available'] as int,
    );
  }
}
