// SafeEntry/App/lib/screens/concierge/home_concierge.dart
import 'package:flutter/material.dart';
import 'package:safeentry/screens/concierge/qr_scanner_screen.dart';
import 'package:safeentry/services/auth_service.dart';
import 'package:safeentry/screens/concierge/concierge_entries_list_screen.dart'; // Importar nova tela
import 'package:intl/intl.dart';
import 'package:safeentry/dto/visit_service_agendamento_response.dart'; // Mantido para o dialog de QR scanner

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
      setState(() {}); // Forçar a reconstrução para exibir o nome
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
        padding: const EdgeInsets.all(16.0), // Mantém o padding geral da tela
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Novo posicionamento do card de boas-vindas
            _buildWelcomeCard(_currentUserName), // Passa o nome para o card
            const SizedBox(height: 24), // Espaçamento após o card de boas-vindas

            // Cartões de funcionalidades
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
            const SizedBox(height: 32), // Espaçamento antes da versão
            const Center(
              child: Text(
                'Versão 3.2.3/4/195', // Manter a versão
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para construir os cartões de recursos
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

  // Método _buildWelcomeCard atualizado para receber e exibir o nome
  Widget _buildWelcomeCard(String? userName) {
    return Card(
      margin: EdgeInsets.zero, // Remove todas as margens
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Opcional: remova bordas arredondadas se quiser
      ),
      elevation: 4,
      child: Container(
        width: double.infinity, // Ocupa toda a largura disponível
        padding: const EdgeInsets.all(16), // Mantém o padding interno
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

  // Mantido o _showConfirmationDialog, que é chamado após o escaneamento/registro
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

  // Método auxiliar para o dialog de confirmação
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