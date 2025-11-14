import 'package:flutter/material.dart';

// 1. IMPORTE O PACOTE DO SUPABASE
import 'package:supabase_flutter/supabase_flutter.dart';

// 2. IMPORTE AS ROTAS E TODAS AS SUAS TELAS
import 'package:biblio/routes/app_routes.dart';

// Importações das Rotas e Telas

// (NOTA: Os caminhos abaixo são baseados na sua estrutura de pastas.
//  Se os nomes das classes dentro dos arquivos forem diferentes,
//  ajuste-os no 'routes' abaixo)
import 'features/auth/presentation/page/login_page.dart';
import 'package:biblio/features/user/homeUser.dart';
import 'package:biblio/features/user/item_details_page.dart';
import 'package:biblio/features/admin/admin_item_details_page.dart';
import 'package:biblio/features/admin/homeAdmin.dart';

// 2. TRANSFORME O MAIN EM 'async'
Future<void> main() async {
  // 3. GARANTA QUE O FLUTTER ESTÁ INICIALIZADO
  WidgetsFlutterBinding.ensureInitialized();

  // 4. INICIALIZAR O SUPABASE
  // Cole seu URL e Anon Key aqui
  await Supabase.initialize(
    url: 'https://onvlrfliohfyyauitmfu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9udmxyZmxpb2hmeXlhdWl0bWZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjE1NDksImV4cCI6MjA3ODQ5NzU0OX0.oVUMfKp_4RIBGmErnDzt730-9kHsVKKlqXyjyJMu7hM',
  );

  runApp(const BibliotecaUniversitariaApp());
}

// 5. CRIE UMA VARIÁVEL GLOBAL PARA ACESSAR O CLIENTE
//    (Isso é um atalho útil)
final supabase = Supabase.instance.client;

class BibliotecaUniversitariaApp extends StatelessWidget {
  const BibliotecaUniversitariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Library',
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

        AppRoutes.adminItemDetails: (context) => const AdminItemDetailsPage(),
      },
    );
  }
}
