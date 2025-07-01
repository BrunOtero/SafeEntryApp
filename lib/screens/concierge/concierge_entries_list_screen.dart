// SafeEntry/App/lib/screens/concierge/concierge_entries_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safeentry/constants/app_colors.dart';
import 'package:safeentry/services/gate_service.dart';
import 'package:safeentry/dto/entrada_response.dart';

class ConciergeEntriesListScreen extends StatefulWidget {
  const ConciergeEntriesListScreen({super.key});

  @override
  State<ConciergeEntriesListScreen> createState() => _ConciergeEntriesListScreenState();
}

class _ConciergeEntriesListScreenState extends State<ConciergeEntriesListScreen> {
  late Future<List<EntradaResponse>> _entriesFuture;
  final GateService _gateService = GateService();

  @override
  void initState() {
    super.initState();
    _entriesFuture = _gateService.getMyEntries();
  }

  Future<void> _refreshEntries() async {
    setState(() {
      _entriesFuture = _gateService.getMyEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Entradas Registradas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<EntradaResponse>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar entradas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.door_front_door, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma entrada registrada por você.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final entries = snapshot.data!;
            return RefreshIndicator( // Permite "puxar para atualizar"
              onRefresh: _refreshEntries,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agendamento ID: ${entry.agendamentoId.substring(0, 8)}...', // Mostrar parte do ID
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          _buildDetailRow('Data/Hora Entrada', DateFormat('dd/MM/yyyy HH:mm').format(entry.dataHoraEntrada.toLocal())),
                          if (entry.observacoes != null && entry.observacoes!.isNotEmpty)
                            _buildDetailRow('Observações', entry.observacoes!),
                          // Você pode adicionar mais detalhes do agendamento se for buscar do Visits Service
                          // (ex: nome do visitante, data agendada)
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}