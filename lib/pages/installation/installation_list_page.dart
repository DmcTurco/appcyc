import 'package:cyc/pages/installation/installation_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../helpers/api_helper.dart';
import '../../models/installation.dart';

class InstallationListPage extends StatefulWidget {
  const InstallationListPage({super.key});

  @override
  State<InstallationListPage> createState() => _InstallationListPageState();
}

class _InstallationListPageState extends State<InstallationListPage> {
  List<Installation> installations = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstallations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstallations() async {
    setState(() => isLoading = true);
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
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar instalaciones');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => isLoading = false);
    }
  }

  List<Installation> get filteredInstallations {
    if (searchQuery.isEmpty) return installations;
    return installations.where((installation) {
      final searchLower = searchQuery.toLowerCase();
      return installation.numeroSolicitud.toLowerCase().contains(searchLower) ||
          installation.solicitanteNombre.toLowerCase().contains(searchLower) ||
          installation.distrito.toLowerCase().contains(searchLower) ||
          (installation.numeroSuministro?.toLowerCase().contains(searchLower) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildInstallationsList(),
          ),
        ],
      ),
    );
  }

  //Una barra de navegación (_buildAppBar())
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Instalaciones',
        style: TextStyle(
          color: Color(0xFF1E4C90),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: const Color(0xFF1E4C90),
          onPressed: () => _showFilterOptions(),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('Todas las instalaciones', Icons.list),
            _buildFilterOption('Pendientes', Icons.pending),
            _buildFilterOption('En proceso', Icons.trending_up),
            _buildFilterOption('Completadas', Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E4C90)),
      title: Text(title),
      onTap: () {
        // Implementar lógica de filtrado
        Navigator.pop(context);
      },
    );
  }

  //Una barra de búsqueda (_buildSearchBar())
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar por número, solicitante o distrito...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1E4C90)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  //Una lista de instalaciones (_buildInstallationsList())
  Widget _buildInstallationsList() {
    if (filteredInstallations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadInstallations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.engineering_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty
                        ? 'No hay instalaciones disponibles'
                        : 'No se encontraron resultados',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadInstallations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1E4C90),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInstallations,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filteredInstallations.length,
        itemBuilder: (context, index) {
          final installation = filteredInstallations[index];
          return _buildInstallationCard(installation);
        },
      ),
    );
  }
  // Widget _buildInstallationsList() {
  //   if (filteredInstallations.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.engineering_outlined,
  //             size: 64,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             searchQuery.isEmpty
  //                 ? 'No hay instalaciones disponibles'
  //                 : 'No se encontraron resultados',
  //             style: TextStyle(
  //               color: Colors.grey[600],
  //               fontSize: 16,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return RefreshIndicator(
  //     onRefresh: _loadInstallations,
  //     child: ListView.builder(
  //       padding: const EdgeInsets.all(8),
  //       itemCount: filteredInstallations.length,
  //       itemBuilder: (context, index) {
  //         final installation = filteredInstallations[index];
  //         return _buildInstallationCard(installation);
  //       },
  //     ),
  //   );
  // }

  //Tarjetas para cada instalación (_buildInstallationCard())
  Widget _buildInstallationCard(Installation installation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InstallationDetailPage(installation: installation),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      Icons.build_outlined,
                      color: Color(0xFF1E4C90),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitud #${installation.numeroSolicitud}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E4C90),
                          ),
                        ),
                        if (installation.numeroSuministro != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Suministro: ${installation.numeroSuministro}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(
                    installation.estadoNombre,
                    installation.estadoBadge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información del solicitante
              _buildInfoRow(
                Icons.person_outline,
                installation.solicitanteNombre,
              ),
              const SizedBox(height: 8),
              // Fecha de aprobación si existe
              if (installation.fechaAprobacionContrato != null) ...[
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  _formatDate(installation.fechaAprobacionContrato!),
                ),
                const SizedBox(height: 8),
              ],
              // Ubicación
              if (installation.direccion != null ||
                  installation.distrito.isNotEmpty)
                _buildLocationInfo(installation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Installation installation) {
    return InkWell(
      // onTap: () => _showLocationDetails(installation),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (installation.direccion != null)
                  Text(
                    installation.direccion!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  installation.distrito,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Icon(
          //   Icons.arrow_forward_ios,
          //   size: 12,
          //   color: Colors.grey[400],
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // void _showLocationDetails(Installation installation) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Detalles de Ubicación'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (installation.direccion != null) ...[
  //             const Text(
  //               'Dirección:',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(installation.direccion!),
  //             const SizedBox(height: 12),
  //           ],
  //           const Text(
  //             'Distrito:',
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(installation.distrito),
  //           if (installation.ubicacion != null) ...[
  //             const SizedBox(height: 12),
  //             const Text(
  //               'Ubicación:',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(installation.ubicacion!),
  //           ],
  //           const SizedBox(height: 16),
  //           Container(
  //             height: 200,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[200],
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Center(
  //               child: Icon(Icons.map, size: 48, color: Colors.grey),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         if (installation.ubicacion != null)
  //           TextButton(
  //             onPressed: () {
  //               // Aquí podrías implementar la apertura en Google Maps
  //               // usando el valor de installation.ubicacion
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Abrir en Maps'),
  //           ),
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Cerrar'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatusChip(String status, String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(badge).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(badge).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(badge),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String badge) {
    switch (badge) {
      case 'bg-gradient-primary':
        return Colors.blue;
      case 'bg-gradient-warning':
        return Colors.orange;
      case 'bg-gradient-danger':
        return Colors.red;
      case 'bg-gradient-info':
        return Colors.cyan;
      default:
        return const Color(0xFF1E4C90);
    }
  }
}
