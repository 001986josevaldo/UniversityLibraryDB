📚 Aplicativo da Biblioteca Universitária

Este é um protótipo de aplicativo de biblioteca universitária desenvolvido em Flutter. O projeto simula o fluxo de um usuário (aluno) para buscar e reservar livros, e também inclui a base para um fluxo administrativo.

O aplicativo foca em uma arquitetura limpa, separando lógica, páginas, rotas e widgets reutilizáveis.

🌟 Funcionalidades Implementadas

Login de Usuário e Admin: Sistema de login fictício com redirecionamento baseado no tipo de usuário.

Navegação por Rotas: Gerenciamento centralizado de rotas (app_routes.dart).

Widget de AppBar Reutilizável: Um CustomAppBar flexível que se adapta a diferentes telas (mostrando ícone de usuário na home, seta de "voltar" em telas internas e um botão de "Sair").

Busca no Acervo: O usuário pode buscar livros pelo título.

Exibição de Resultados: Mostra uma lista de livros filtrados ou uma mensagem "Results empty" se nada for encontrado.

Detalhes do Livro: Exibe informações detalhadas (Autor, Localização, Status) ao selecionar um item.

Reserva de Livros: Permite ao usuário reservar um livro se ele estiver "Disponível" e exibe uma confirmação.

Controle de Estado: A tela de busca é limpa automaticamente quando o usuário retorna da tela de detalhes, pronta para uma nova pesquisa.
