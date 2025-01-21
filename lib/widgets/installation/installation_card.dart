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
        const SnackBar(
          content: Text('Error al abrir el mapa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChangeStatusModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cambiar Estado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatusOption(
              context,
              'Iniciar Instalación',
              Icons.play_circle_outline,
              Colors.green,
              () => _updateStatus(context, 'start'),
            ),
            _buildStatusOption(
              context,
              'Finalizar Instalación',
              Icons.check_circle_outline,
              Colors.blue,
              () => _updateStatus(context, 'finish'),
            ),
            _buildStatusOption(
              context,
              'Cancelar Instalación',
              Icons.cancel_outlined,
              Colors.red,
              () => _updateStatus(context, 'cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _updateStatus(BuildContext context, String action) {
    // Aquí implementarías la lógica para actualizar el estado
    Navigator.pop(context); // Cierra el modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cambio'),
        content: Text('¿Estás seguro de que deseas ${_getActionText(action)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Aquí implementarías la llamada a la API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Estado actualizado: ${_getActionText(action)}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'start':
        return 'iniciar la instalación';
      case 'finish':
        return 'finalizar la instalación';
      case 'cancel':
        return 'cancelar la instalación';
      default:
        return 'actualizar el estado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildBody(),
          if (installation.ubicacion != null) _buildMap(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E4C90).withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                  fontSize: 18,
                  color: Color(0xFF1E4C90),
                ),
              ),
              _buildStatusChip(
                  installation.estadoNombre, installation.estadoBadge),
            ],
          ),
          if (installation.numeroSuministro != null) ...[
            const SizedBox(height: 8),
            Text(
              'Suministro: ${installation.numeroSuministro}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoSection(
            'Información del Cliente',
            Icons.person_outline,
            [
              _buildInfoRow('Cliente:', installation.solicitanteNombre),
              if (installation.numeroContratoSuministro != null)
                _buildInfoRow(
                    'Contrato:', installation.numeroContratoSuministro),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            'Ubicación',
            Icons.location_on_outlined,
            [
              _buildInfoRow('Dirección:', installation.direccion),
              _buildInfoRow('Distrito:', installation.distrito),
              if (installation.ubicacion != null)
                _buildInfoRow('Coordenadas:', installation.ubicacion),
            ],
          ),
          if (installation.fechaAprobacionContrato != null) ...[
            const SizedBox(height: 16),
            _buildInfoSection(
              'Información Adicional',
              Icons.info_outline,
              [
                _buildInfoRow(
                  'Fecha Aprobación:',
                  _formatDate(installation.fechaAprobacionContrato!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E4C90)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E4C90),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.map,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () => _openMaps(
                  context,
                  installation.ubicacion!,
                ),
                backgroundColor: const Color(0xFF1E4C90),
                child: const Icon(Icons.directions),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            'Cambiar Estado',
            Icons.refresh,
            () => _showChangeStatusModal(context),
          ),
          if (installation.ubicacion != null)
            _buildActionButton(
              context,
              'Ver en Mapa',
              Icons.map,
              () => _openMaps(context, installation.ubicacion!),
            ),
          _buildActionButton(
            context,
            'Más Opciones',
            Icons.more_horiz,
            () {
              // Implementar más opciones
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1E4C90)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E4C90),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, String badge) {
    final color = _getStatusColor(badge);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
