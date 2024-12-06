// lib/pages/home_page.dart
import 'dart:convert';
import 'package:cyc/models/installation.dart';
import 'package:cyc/pages/installation/installation_detail_page.dart';
import 'package:cyc/pages/installation/installation_list_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../helpers/api_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? nombreTecnico;
  List<Installation> installations = [];
  @override
  void initState() {
    super.initState();
    _loadTecnicoInfo();
    _loadInstallations();
  }

  Future<void> _loadInstallations() async {
    try {
      final response = await http.get(
        Uri.parse(ApiHelper.getEndpoint('solicitudes')),
        headers: await ApiHelper.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          installations = data.map((json) => Installation.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error cargando instalaciones: $e');
    }
  }

  Widget _buildRecentRequests() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Solicitudes Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E4C90),
              ),
            ),
          ),
          ...installations.take(3).map((installation) => ListTile(
            title: Text('Solicitud #${installation.numeroSolicitud}'),
            subtitle: Text(installation.solicitanteNombre ?? ''),
            trailing: _buildStatusChip(installation.estadoNombre, installation.estadoBadge),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InstallationDetailPage(installation: installation),
              ),
            ),
          )),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InstallationListPage()),
            ),
            child: const Text('Ver todas'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(badge),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String badge) {
    switch (badge) {
      case 'bg-gradient-warning':
        return Colors.orange;
      case 'bg-gradient-info':
        return Colors.blue;
      case 'bg-gradient-danger':
        return Colors.red;
      default:
        return const Color(0xFF1E4C90);
    }
  }
 Future<void> _loadTecnicoInfo() async {
   try {
     final prefs = await SharedPreferences.getInstance();
     final tecnicoData = prefs.getString('tecnico_data');
     print('Tecnico data: $tecnicoData'); 
     if (tecnicoData != null) {
       final data = json.decode(tecnicoData);
       setState(() {
         nombreTecnico = data['tecnico']['nombre'].split(' ')[0];
       });
     }
   } catch (e) {
     print('Error cargando nombre: $e');
   }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildRecentRequests(),
            _buildQuickActions(),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1E4C90),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Text(
        'Hola, ${nombreTecnico ?? 'Técnico'}',
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    const labels = {
      'build_outlined': 'Instalac.',
      'engineering_outlined': 'Mantenim.',
      'assessment_outlined': 'Reportes',
      'inventory_2_outlined': 'Invent.',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.build_outlined, labels['build_outlined']!,
              () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InstallationListPage()));
          }),
          _buildActionButton(Icons.engineering_outlined,labels['engineering_outlined']!, () {}),
          _buildActionButton(Icons.assessment_outlined, labels['assessment_outlined']!, () {}),
          _buildActionButton(Icons.inventory_2_outlined,labels['inventory_2_outlined']!, () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E4C90),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/logo.svg',
            height: 40,
          ),
          const SizedBox(width: 8),
          const Text('Portal Técnico'),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
          color: const Color(0xFF1E4C90),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E4C90),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Instalaciones Pendientes', '5'),
            _buildStatusRow('Mantenimientos Programados', '3'),
            _buildStatusRow('Reportes por Completar', '2'),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No hay token guardado');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiHelper.getEndpoint('logout')),
        headers: ApiHelper.getHeaders(token: token),
      );

      print('Status code logout: ${response.statusCode}');
      print('Response body logout: ${response.body}');

      await prefs.remove('token');

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error durante logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatusRow(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4C90),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
