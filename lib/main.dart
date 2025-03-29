import 'package:cyc/helpers/api_helper.dart';
import 'package:cyc/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() async {
  // Inicializa Flutter antes de ejecutar código asíncrono
  WidgetsFlutterBinding.ensureInitialized();
    // Configura la aplicación para usar la URL de producción
  await ApiHelper.setProductionMode(true);
    // Opcional: imprime la URL para verificar
  print('API URL: ${await ApiHelper.getBaseUrl()}');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi proyecto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
