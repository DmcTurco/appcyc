import 'package:cyc/models/installation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallationCard extends StatelessWidget {
  final Installation installation;

  const InstallationCard({super.key, required this.installation});

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

  void _openMaps(BuildContext context, String ubicacion) {
    final coordinates = ubicacion.split(',');
    final url = 'google.navigation:q=${coordinates[0]},${coordinates[1]}';
    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al abrir el mapa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solicitud #${installation.numeroSolicitud}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusChip(
                        installation.estadoNombre, installation.estadoBadge),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Cliente:', installation.solicitanteNombre),
                _buildInfoRow('Suministro:', installation.numeroSuministro),
                _buildInfoRow('Dirección:', installation.direccion),
                _buildInfoRow('Distrito:', installation.distrito),
              ],
            ),
          ),
          OverflowBar(
            spacing: 8,
            children: [
              if (installation.ubicacion != null)
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: () => _openMaps(context, installation.ubicacion!),
                  color: Colors.blue,
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'start', child: Text('Iniciar')),
                  const PopupMenuItem(value: 'finish', child: Text('Finalizar')),
                  const PopupMenuItem(value: 'reassign', child: Text('Reasignar')),
                  const PopupMenuItem(value: 'cancel', child: Text('Cancelar')),
                ],
                onSelected: (value) => print('Selected: $value'),
              ),
            ],
          )
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? '-'),
          ),
        ],
      ),
    );
  }
}
