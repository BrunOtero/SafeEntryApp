import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:safeentry/models/visitor.dart';
import 'package:safeentry/screens/concierge/qr_scanner_screen.dart';

class ConciergeHomeScreen extends StatefulWidget {
  const ConciergeHomeScreen({super.key});

  @override
  State<ConciergeHomeScreen> createState() => _ConciergeHomeScreenState();
}

class _ConciergeHomeScreenState extends State<ConciergeHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel do Porteiro'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/concierge-login');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Pendentes'), Tab(text: 'Confirmados')],
          ),
        ),
        body: Column(
          children: [
            _buildWelcomeCard(),
            _buildScannerCard(context),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildVisitorList('Pendente'),
                  _buildVisitorList('Confirmado'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.security, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'Bem-vindo, Porteiro!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildScannerCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verificação de Visitantes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR Code'),
              onPressed: () async {
                final visitor = await Navigator.push<Visitor>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );

                if (visitor != null && mounted) {
                  _showConfirmationDialog(context, visitor);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('visitors')
              .where('status', isEqualTo: status)
              .orderBy('entryTime', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar visitantes.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum visitante encontrado.'));
        }

        final visitors =
            snapshot.data!.docs
                .map(
                  (doc) => Visitor.fromMap(doc.data() as Map<String, dynamic>),
                )
                .toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.person, size: 40),
                title: Text(
                  visitor.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Morador: ${visitor.residentName}'),
                    Text('Unidade: ${visitor.unit ?? "Não informado"}'),
                    Text('Data: ${visitor.formattedEntryTime}'),
                  ],
                ),
                trailing:
                    status == 'Pendente'
                        ? IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () => _confirmVisitor(visitor),
                        )
                        : const Icon(Icons.verified, color: Colors.green),
                onTap: () => _showVisitorDetails(context, visitor),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmVisitor(Visitor visitor) async {
    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitor.id)
          .update({'status': 'Confirmado'});

      await _notifyResident(visitor.residentId, visitor.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${visitor.name} autorizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao confirmar visitante'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _notifyResident(String residentId, String visitorName) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'residentId': residentId,
      'message': '$visitorName foi autorizado a entrar',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showConfirmationDialog(BuildContext context, Visitor visitor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Visitante Autorizado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nome', visitor.name),
                _buildDetailRow('Morador', visitor.residentName),
                _buildDetailRow('Unidade', visitor.unit),
                _buildDetailRow('Data', visitor.formattedEntryTime),
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

  void _showVisitorDetails(BuildContext context, Visitor visitor) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.person, size: 60, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  'Visitante: ${visitor.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildDetailRow('Morador', visitor.residentName),
                _buildDetailRow('Unidade', visitor.unit),
                _buildDetailRow('Status', visitor.status),
                _buildDetailRow('Data', visitor.formattedEntryTime),
                const SizedBox(height: 24),
                if (visitor.status == 'Pendente')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _confirmVisitor(visitor);
                        Navigator.pop(context);
                      },
                      child: const Text('Autorizar Entrada'),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
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
