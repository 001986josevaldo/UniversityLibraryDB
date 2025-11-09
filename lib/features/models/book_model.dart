// Este modelo ajuda a organizar os dados do livro
class BookModel {
  final String title;
  final String author;
  final String status;
  final String location;

  BookModel({
    required this.title,
    required this.author,
    required this.status,
    required this.location,
  });

  // Um getter para verificar facilmente se está disponível
  bool get isAvailable => status == 'Disponível';
}
