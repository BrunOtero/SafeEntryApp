import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:safeentry/constants/app_colors.dart';
import 'package:safeentry/services/visit_service.dart';
import 'package:safeentry/services/auth_service.dart';
import 'package:safeentry/dto/agendamento_response.dart';
import 'package:safeentry/dto/agendamento_status.dart';
import 'package:intl/intl.dart';
import 'package:safeentry/screens/resident/appointments_list_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  late Future<List<AgendamentoResponse>> _pendingAppointmentsFuture;
  late StreamSubscription<QuerySnapshot> _notificationSubscription;
  String? _currentUserName;
  String? _currentUserId;

  final VisitService _visitService = VisitService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserInfoAndInitializeData();
  }

  Future<void> _loadUserInfoAndInitializeData() async {
    _currentUserName = await _authService.getUserName();
    _currentUserId = await _authService.getUserId();

    if (mounted) {
      setState(() {
        _pendingAppointmentsFuture = _fetchAndFilterPendingAppointments();
      });
    }

    if (_currentUserId != null) {
      _setupNotificationListener(_currentUserId!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID do usuário não disponível. Por favor, faça login novamente.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<List<AgendamentoResponse>> _fetchAndFilterPendingAppointments() async {
    try {
      final allAppointments = await _visitService.getMyAppointments();
      final filteredAppointments = allAppointments
          .where((app) => app.status == AgendamentoStatus.pendente)
          .toList();
      filteredAppointments.sort((a, b) => b.dataHoraVisita.compareTo(a.dataHoraVisita));
      return filteredAppointments;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos pendentes: $e')),
        );
      }
      return [];
    }
  }

  Future<void> _refreshPendingAppointments() async {
    setState(() {
      _pendingAppointmentsFuture = _fetchAndFilterPendingAppointments();
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  void _setupNotificationListener(String residentId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('residentId', isEqualTo: residentId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final message = doc['message'];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        });
      }
    });
  }

  Future<void> _registerVisitor(String visitorName, String visitorDocument, String? visitorVehicle, DateTime visitTime) async {
    try {
      await _visitService.createAppointment(
        visitorName: visitorName,
        visitorDocument: visitorDocument,
        visitorVehicle: visitorVehicle,
        visitTime: visitTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento criado com sucesso!')),
        );
        _refreshPendingAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar agendamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Morador'),
        centerTitle: true,
        elevation: 0,
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
      body: RefreshIndicator(
        onRefresh: _refreshPendingAppointments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeCard(_currentUserName),
              const Divider(height: 32),
              _buildFeatureCard(
                icon: Icons.person_add,
                title: 'Cadastrar Visitante',
                color: Theme.of(context).colorScheme.primary,
                onTap: () => _registerNewVisitorDialog(context),
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                icon: Icons.event_note,
                title: 'Agendamentos Cadastrados',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsListScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<AgendamentoResponse>>(
                future: _pendingAppointmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_2_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum QR Code pendente no momento.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    final pendingAppointments = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seus QR Codes Pendentes:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...pendingAppointments.map(_buildQRCodeCard).toList(),
                      ],
                    );
                  }
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

  Widget _buildQRCodeCard(AgendamentoResponse appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('QR Code para: ${appointment.visitante.nome}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Visita em: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dataHoraVisita)}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            Center(
              child: QrImageView(
                data: appointment.qrToken,
                version: QrVersions.auto,
                size: 140,
              ),
            ),
            const SizedBox(height: 8),
            Text('Unidade: Apto 101', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: appointment.qrToken));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR copiado!')),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => _viewAppointmentDetails(appointment),
                  child: const Text('Detalhes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _registerNewVisitorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final documentController = TextEditingController();
    final vehicleController = TextEditingController();
    final dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar Novo Visitante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Visitante',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: documentController,
                decoration: const InputDecoration(
                  labelText: 'Documento do Visitante',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Veículo (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora da Visita',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      final now = DateTime.now();
                      final combinedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      if (combinedDateTime.isBefore(now.subtract(const Duration(seconds: 1))) ||
                          (combinedDateTime.isAtSameMomentAs(now) && combinedDateTime.second <= now.second)) {
                        selectedDate = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          now.second,
                          now.millisecond,
                        ).add(const Duration(seconds: 1));
                      } else {
                        selectedDate = combinedDateTime;
                      }

                      dateController.text =
                          DateFormat('dd/MM/yyyy HH:mm').format(selectedDate!);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  documentController.text.isNotEmpty &&
                  selectedDate != null) {
                _registerVisitor(
                  nameController.text,
                  documentController.text,
                  vehicleController.text.isEmpty ? null : vehicleController.text,
                  selectedDate!,
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, preencha todos os campos obrigatórios.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Gerar QR Code'),
          ),
        ],
      ),
    );
  }

  void _viewAppointmentDetails(AgendamentoResponse appointment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primary),
              title: Text(appointment.visitante.nome),
              subtitle: Text('Documento: ${appointment.visitante.documento}'),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.grey),
              title: Text('Visita: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dataHoraVisita.toLocal())}'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                appointment.status == AgendamentoStatus.pendente
                    ? Icons.pending_actions
                    : Icons.verified,
                color: appointment.status == AgendamentoStatus.pendente
                    ? Colors.orange
                    : Colors.green,
              ),
              title: Text('Status: ${appointment.status.name}'),
            ),
            if (appointment.visitante.veiculo != null && appointment.visitante.veiculo!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.car_rental, color: AppColors.primary),
                title: Text('Veículo: ${appointment.visitante.veiculo}'),
              ),
            const SizedBox(height: 16),
            if (appointment.status == AgendamentoStatus.pendente)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar Agendamento'),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
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
            const Icon(Icons.home, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              'Bem-vindo, ${userName ?? 'Morador'}!',
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
}