import 'package:flutter/material.dart';
import 'package:safeentry/screens/concierge/qr_scanner_screen.dart';
import 'package:safeentry/services/auth_service.dart';
import 'package:safeentry/screens/concierge/concierge_entries_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:safeentry/dto/visit_service_agendamento_response.dart';

class ConciergeHomeScreen extends StatefulWidget {
  const ConciergeHomeScreen({super.key});

  @override
  State<ConciergeHomeScreen> createState() => _ConciergeHomeScreenState();
}

class _ConciergeHomeScreenState extends State<ConciergeHomeScreen> {
  final AuthService _authService = AuthService();
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    _currentUserName = await _authService.getUserName();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Porteiro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(_currentUserName),
            const SizedBox(height: 24),

            _buildFeatureCard(
              icon: Icons.qr_code_scanner,
              title: 'Escanear QR Code',
              color: Theme.of(context).colorScheme.primary,
              onTap: () async {
                final scannedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );

                if (scannedData != null && mounted) {
                  if (scannedData is VisitServiceAgendamentoResponse) {
                    _showConfirmationDialog(context, scannedData);
                  }
                }
              },
            ),
            const SizedBox(height: 10),
            _buildFeatureCard(
              icon: Icons.list_alt,
              title: 'Entradas Cadastradas',
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConciergeEntriesListScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Versão 3.2.3/4/195',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildWelcomeCard(String? userName) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              'Bem-vindo, ${userName ?? 'Porteiro'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, VisitServiceAgendamentoResponse appointment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Visitante Autorizado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nome', appointment.visitante.nome),
                _buildDetailRow('Documento', appointment.visitante.documento),
                _buildDetailRow('Veículo', appointment.visitante.veiculo),
                _buildDetailRow('Data da Visita', DateFormat('dd/MM/yyyy HH:mm').format(appointment.dataHoraVisita)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}