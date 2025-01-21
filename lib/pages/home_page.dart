import 'dart:convert';
import 'package:cyc/models/installation.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _loadTecnicoInfo(),
      _loadInstallations(),
    ]);
    setState(() => isLoading = false);
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
          installations =
              data.map((json) => Installation.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error cargando instalaciones: $e');
    }
  }

  Future<void> _loadTecnicoInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tecnicoData = prefs.getString('tecnico_data');
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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildQuickActions(),
                    _buildSummaryCard(),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E4C90),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola,',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nombreTecnico ?? 'Técnico',
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido al Portal Técnico',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionItem(
        icon: Icons.build_outlined,
        label: 'Instalaciones',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InstallationListPage()),
        ),
      ),
      _ActionItem(
        icon: Icons.engineering_outlined,
        label: 'Mantenimiento',
        onTap: () {},
      ),
      _ActionItem(
        icon: Icons.assessment_outlined,
        label: 'Reportes',
        onTap: () {},
      ),
      _ActionItem(
        icon: Icons.inventory_2_outlined,
        label: 'Inventario',
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E4C90),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                actions.map((action) => _buildActionButton(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(_ActionItem action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E4C90).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                action.icon,
                color: const Color(0xFF1E4C90),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/logo.svg',
            height: 32,
          ),
          const SizedBox(width: 12),
          const Text(
            'Portal Técnico',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E4C90),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          color: const Color(0xFF1E4C90),
        ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4C90).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.today,
                    color: Color(0xFF1E4C90),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumen del Día',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E4C90),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusRow(
              'Instalaciones Pendientes',
              '5',
              Icons.build_outlined,
            ),
            _buildStatusRow(
              'Mantenimientos Programados',
              '3',
              Icons.engineering_outlined,
            ),
            _buildStatusRow(
              'Reportes por Completar',
              '2',
              Icons.assessment_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String title, String count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4C90).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Color(0xFF1E4C90),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4C90).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF1E4C90),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E4C90),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (installations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No hay actividades recientes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: installations.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  final installation = installations[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E4C90).withOpacity(0.1),
                      child: const Icon(
                        Icons.build_outlined,
                        color: Color(0xFF1E4C90),
                      ),
                    ),
                    title: Text(
                      installation.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Estado: ${installation.toString()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
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
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
