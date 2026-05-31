import 'dart:convert';

import 'package:cyc/helpers/api_helper.dart';
import 'package:flutter/material.dart';
import '../../models/installation.dart';
import '../../widgets/installation/installation_card.dart';
import 'package:http/http.dart' as http;

class InstallationDetailPage extends StatefulWidget {
  final Installation installation;

  const InstallationDetailPage({super.key, required this.installation});

  @override
  State<InstallationDetailPage> createState() => _InstallationDetailPageState();
}

class _InstallationDetailPageState extends State<InstallationDetailPage> {
  late Installation _currentInstallation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentInstallation = widget.installation;
  }

// Método para refrescar los datos de la instalación
  Future<void> _refreshInstallation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(await ApiHelper.getEndpoint(
            'solicitudes/${_currentInstallation.id}')),
        headers: await ApiHelper.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentInstallation = Installation.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Error al obtener la información actualizada');
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleStatusChanged(int nuevoEstadoId, String nuevoEstadoNombre) {
    _refreshInstallation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Solicitud #${_currentInstallation.numeroSolicitud}',
            style: const TextStyle(
              color: Color(0xFF1E4C90),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _refreshInstallation,
              color: const Color(0xFF1E4C90),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Implementar compartir
              },
              color: const Color(0xFF1E4C90),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshInstallation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InstallationCard(
                      installation: _currentInstallation,
                      onStatusChanged: _handleStatusChanged,
                    ),
                  ),
                ),
              ));
  }
}
