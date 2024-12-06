// lib/pages/installation/installation_detail_page.dart
import 'package:flutter/material.dart';
import '../../models/installation.dart';
import '../../widgets/installation/installation_card.dart';

class InstallationDetailPage extends StatelessWidget {
 final Installation installation;
 
 const InstallationDetailPage({super.key, required this.installation});

 @override 
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('Solicitud #${installation.numeroSolicitud}'),
       backgroundColor: Colors.white,
     ),
     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: InstallationCard(installation: installation),
       ),
     ),
   );
 }
}