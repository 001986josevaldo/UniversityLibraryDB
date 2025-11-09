import 'package:flutter/material.dart';
import 'features/auth/presentation/page/login_page.dart';
import 'features/user/homeUser.dart';
import 'features/admin/homeAdmin.dart';
import 'features/user/item_details_page.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const BibliotecaUniversitariaApp());
}

class BibliotecaUniversitariaApp extends StatelessWidget {
  const BibliotecaUniversitariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'university library',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.login,

      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        // Quando o Navigator chamar '/user/home', ele constrói a UserHomePage
        AppRoutes.userHome: (context) => const UserHomePage(),
        // pagina de detalhes do livro e reservar
        AppRoutes.itemDetails: (context) => const ItemDetailsPage(),

        // Quando o Navigator chamar '/admin/home', ele constrói a AdminHomePage
        AppRoutes.adminHome: (context) => const AdminHomePage(),
      },
    );
  }
}
