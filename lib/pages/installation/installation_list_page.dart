import 'package:cyc/widgets/installation/installation_card.dart';
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

  @override
  void initState() {
    super.initState();
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instalaciones'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInstallations,
              child: ListView.builder(
                itemCount: installations.length,
                itemBuilder: (context, index) {
                  final installation = installations[index];
                  return InstallationCard(installation: installation);
                },
              ),
            ),
    );
  }
}
