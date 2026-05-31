import 'dart:convert';
import 'dart:math';
import 'package:cyc/helpers/api_helper.dart';
import 'package:cyc/models/installation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class InstallationCard extends StatefulWidget {
  final Installation installation;
  final Function? onStatusChanged; // Opcional: Callback para notificar cambios

  const InstallationCard({
    super.key,
    required this.installation,
    this.onStatusChanged,
  });

  @override
  State<InstallationCard> createState() => _InstallationCardState();
}

class _InstallationCardState extends State<InstallationCard> {
  bool _isLoading = false;

  Installation get installation => widget.installation;

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

// Método de debug para verificar la conexión con la API
  Future<void> _debugApiConnection(BuildContext context) async {
    try {
      // Obtener la URL y headers
      final url = await ApiHelper.getEndpoint('solicitudes/estado');
      final headers = await ApiHelper.getAuthHeaders();

      // Mostrar información de conexión
      print('URL: $url');
      print('Headers: $headers');

      // Intentar una petición GET para verificar si hay problemas de conexión
      try {
        final testResponse = await http.get(
          Uri.parse(await ApiHelper.getEndpoint('solicitudes')),
          headers: headers,
        );
        print('Test GET respuesta: ${testResponse.statusCode}');
        print(
            'Test GET cuerpo: ${testResponse.body.substring(0, min(200, testResponse.body.length))}');
      } catch (e) {
        print('Error en petición GET: $e');
      }

      // Intentar una petición PUT vacía para ver si hay problemas con ese método
      try {
        final testPutResponse = await http.put(
          Uri.parse(url),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: json.encode({'test': true}),
        );
        print('Test PUT respuesta: ${testPutResponse.statusCode}');
        print('Test PUT cuerpo: ${testPutResponse.body}');
      } catch (e) {
        print('Error en petición PUT: $e');
      }
    } catch (e) {
      print('Error de debug: $e');
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
            // Botón para debug - temporal
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.bug_report, color: Colors.purple, size: 28),
              title: const Text('Verificar API (Debug)'),
              onTap: () {
                Navigator.pop(context);
                _debugApiConnection(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Revisando conexión con API, ver consola para detalles'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
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
    // Cerramos el modal primero
    Navigator.pop(context);

    // Mostramos el diálogo de confirmación
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
              Navigator.pop(context); // Cerrar el diálogo
              _sendStatusUpdate(context, action); // Llamar a la API
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

// Método para enviar la actualización de estado a la API
// Método para enviar la actualización de estado a la API
  Future<void> _sendStatusUpdate(BuildContext context, String action) async {
    setState(() => _isLoading = true);

    try {
      // Convertir la acción en estado_id y estado_nombre
      final Map<String, dynamic> estadoInfo = _getEstadoInfo(action);

      // Crear el cuerpo de la solicitud según la estructura esperada por el backend
      final Map<String, dynamic> requestBody = {
        'solicitud_id': installation.id,
        'estado_id': estadoInfo['estado_id'],
        'estado_nombre': estadoInfo['estado_nombre'],
      };

      print('Enviando: $requestBody');

      // Realizar la petición PUT a la API (cambiado de POST a PUT)
      final response = await http.put(
        Uri.parse(await ApiHelper.getEndpoint('solicitudes/estado')),
        headers: {
          ...await ApiHelper.getAuthHeaders(),
          'Content-Type': 'application/json'
        },
        body: json.encode(requestBody),
      );

      // Imprimir para depuración
      print('Respuesta: ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      // Manejar la respuesta
      if (response.statusCode == 200) {
        // Éxito
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Estado actualizado a: ${estadoInfo['estado_nombre']}'),
            backgroundColor: Colors.green,
          ),
        );

        // Notificar que el estado ha cambiado
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!();
        }
      } else {
        // Error en la respuesta
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? 'Error al actualizar el estado';
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}';
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error en la petición
      print('Excepción: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// Método para convertir una acción en estado_id y estado_nombre
  Map<String, dynamic> _getEstadoInfo(String action) {
    switch (action) {
      case 'start':
        return {
          'estado_id': 3, // "Iniciado"
          'estado_nombre': 'Iniciado'
        };
      case 'finish':
        return {
          'estado_id': 4, // "finalizado"
          'estado_nombre': 'Finalizado'
        };
      case 'cancel':
        return {
          'estado_id': 6, // "cancelado"
          'estado_nombre': 'Cancelado'
        };
      default:
        return {
          'estado_id': 3, // Por defecto "Iniciado"
          'estado_nombre': 'Iniciado'
        };
    }
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
    return Stack(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
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
        ),
        // Overlay de carga cuando se está haciendo la petición
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  // El resto de los métodos (buildHeader, buildBody, etc.) quedan igual que en tu código original
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E4C90).withValues(alpha: 0.05),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // Aquí iría la implementación del mapa
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
