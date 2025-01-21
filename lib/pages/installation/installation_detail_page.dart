import 'package:flutter/material.dart';
import '../../models/installation.dart';
import '../../widgets/installation/installation_card.dart';

class InstallationDetailPage extends StatelessWidget {
  final Installation installation;
 
  const InstallationDetailPage({super.key, required this.installation});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Solicitud #${installation.numeroSolicitud}',
          style: const TextStyle(
            color: Color(0xFF1E4C90),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implementar compartir
            },
            color: const Color(0xFF1E4C90),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: InstallationCard(installation: installation),
        ),
      ),
    );
  }
}