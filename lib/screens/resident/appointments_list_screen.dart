import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safeentry/constants/app_colors.dart';
import 'package:safeentry/services/visit_service.dart';
import 'package:safeentry/dto/agendamento_response.dart';
import 'package:safeentry/dto/agendamento_status.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  late Future<List<AgendamentoResponse>> _appointmentsFuture;
  final VisitService _visitService = VisitService();

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _visitService.getMyAppointments();
  }

  Future<void> _refreshAppointments() async {
    setState(() {
      _appointmentsFuture = _visitService.getMyAppointments();
    });
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await _visitService.cancelAppointment(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento cancelado com sucesso!')),
        );
        _refreshAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar agendamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AgendamentoResponse>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar agendamentos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum agendamento encontrado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final appointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshAppointments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
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
                            'Visitante: ${appointment.visitante.nome}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          _buildDetailRow('Documento', appointment.visitante.documento),
                          if (appointment.visitante.veiculo != null && appointment.visitante.veiculo!.isNotEmpty)
                            _buildDetailRow('Veículo', appointment.visitante.veiculo!),
                          _buildDetailRow('Data da Visita', DateFormat('dd/MM/yyyy HH:mm').format(appointment.dataHoraVisita.toLocal())),
                          _buildDetailRow('Status', appointment.status.name),
                          const SizedBox(height: 10),
                          if (appointment.status == AgendamentoStatus.pendente)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.cancel, color: Colors.white),
                                label: const Text('Cancelar Agendamento', style: TextStyle(color: Colors.white)),
                                onPressed: () => _confirmCancelDialog(context, appointment.id, appointment.visitante.nome),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
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

  void _confirmCancelDialog(BuildContext context, String appointmentId, String visitorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelamento'),
        content: Text('Tem certeza que deseja cancelar o agendamento de $visitorName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              _cancelAppointment(appointmentId);
              Navigator.pop(context);
            },
            child: const Text('Sim', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}