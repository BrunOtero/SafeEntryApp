import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safeentry/constants/app_colors.dart';
import 'package:safeentry/models/visitor.dart';
import 'package:safeentry/screens/resident/my_qr_code_screen.dart';
import 'package:safeentry/screens/resident/concierge_screen.dart';
import 'package:safeentry/screens/resident/alerts_screen.dart';
import 'package:safeentry/screens/resident/settings_screen.dart';
import 'package:safeentry/screens/resident/help_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  List<Visitor> visitors = [];
  String? generatedQRCode;
  Visitor? currentVisitor;
  late StreamSubscription<QuerySnapshot> _notificationSubscription;

  final List<Map<String, dynamic>> primaryFeatures = [
    {
      'icon': Icons.qr_code,
      'title': 'Meu QR Code',
      'color': Colors.blue[700]!,
      'screen': const MyQrCodeScreen(),
    },
    {
      'icon': Icons.security,
      'title': 'Portaria',
      'color': Colors.orange[700]!,
      'screen': const ConciergeScreen(),
    },
    {
      'icon': Icons.notifications,
      'title': 'Alertas',
      'color': Colors.red[700]!,
      'screen': const AlertsScreen(),
    },
  ];

  final List<Map<String, dynamic>> secondaryFeatures = [
    {
      'icon': Icons.settings,
      'title': 'Configurações',
      'color': Colors.purple[700]!,
      'screen': const SettingsScreen(),
    },
    {
      'icon': Icons.help,
      'title': 'Ajuda',
      'color': Colors.teal[700]!,
      'screen': const HelpScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
    _loadVisitors();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('residentId', isEqualTo: 'ID_DO_MORADOR')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final message = doc['message'];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
            });
          }
        });
  }

  Future<void> _loadVisitors() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('visitors')
            .where('residentId', isEqualTo: 'ID_DO_MORADOR')
            .get();

    if (mounted) {
      setState(() {
        visitors =
            snapshot.docs.map((doc) => Visitor.fromMap(doc.data())).toList();
      });
    }
  }

  Future<void> _registerVisitor(String visitorName) async {
    final visitorId = DateTime.now().millisecondsSinceEpoch.toString();
    final visitor = Visitor(
      id: visitorId,
      name: visitorName,
      residentId: 'ID_DO_MORADOR',
      residentName: 'Heloisa',
      entryTime: DateTime.now(),
      unit: 'Apto 101',
      status: 'Pendente',
    );

    await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitorId)
        .set(visitor.toMap());

    if (mounted) {
      setState(() {
        visitors.add(visitor);
        generatedQRCode = jsonEncode(visitor.toMap());
        currentVisitor = visitor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Morador'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá, Heloisa.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tenha uma boa estadia!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _registerNewVisitor(context),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'CADASTRAR VISITANTE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (currentVisitor != null) _buildQRCodeCard(currentVisitor!),
            const SizedBox(height: 24),

            const Text(
              'Acesso Rápido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: primaryFeatures.length,
              itemBuilder: (context, index) {
                return _buildSmallFeatureCard(primaryFeatures[index]);
              },
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: secondaryFeatures.length,
              itemBuilder: (context, index) {
                return _buildSmallFeatureCard(secondaryFeatures[index]);
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Visitantes Cadastrados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildVisitorList(),

            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Versão 3.2.3/4/195',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard(Visitor visitor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'QR Code para:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(visitor.name, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            QrImageView(
              data: generatedQRCode!,
              version: QrVersions.auto,
              size: 150,
            ),
            const SizedBox(height: 8),
            Text(
              'Mostre este código na portaria',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Unidade: ${visitor.unit ?? "Não informado"}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallFeatureCard(Map<String, dynamic> feature) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: feature['color'].withOpacity(0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => feature['screen']),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature['icon'], size: 24, color: feature['color']),
              const SizedBox(height: 8),
              Text(
                feature['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: feature['color'],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('visitors')
              .where('residentId', isEqualTo: 'ID_DO_MORADOR')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.people_alt_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Nenhum visitante cadastrado',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        visitors =
            snapshot.data!.docs
                .map(
                  (doc) => Visitor.fromMap(doc.data() as Map<String, dynamic>),
                )
                .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];
            return _buildVisitorCard(visitor);
          },
        );
      },
    );
  }

  Widget _buildVisitorCard(Visitor visitor) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(Icons.person_outline, color: AppColors.primary),
        title: Text(visitor.name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          'Status: ${visitor.status}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                visitor.status == 'Pendente'
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            visitor.status,
            style: TextStyle(
              fontSize: 12,
              color:
                  visitor.status == 'Pendente'
                      ? Colors.orange.shade800
                      : Colors.green.shade800,
            ),
          ),
        ),
        onTap: () => _viewVisitorDetails(visitor),
      ),
    );
  }

  void _registerNewVisitor(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cadastrar Novo Visitante'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Visitante',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    _registerVisitor(nameController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Gerar QR Code'),
              ),
            ],
          ),
    );
  }

  void _viewVisitorDetails(Visitor visitor) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline, color: AppColors.primary),
                  title: Text(visitor.name),
                  subtitle: Text('Entrada: ${visitor.formattedEntryTime}'),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    visitor.status == 'Pendente'
                        ? Icons.pending_actions
                        : Icons.verified,
                    color:
                        visitor.status == 'Pendente'
                            ? Colors.orange
                            : Colors.green,
                  ),
                  title: Text('Status: ${visitor.status}'),
                  subtitle: Text('Unidade: ${visitor.unit ?? "Não informado"}'),
                ),
                const SizedBox(height: 16),
                if (visitor.status == 'Pendente')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _updateVisitorStatus(visitor, 'Aprovado');
                        Navigator.pop(context);
                      },
                      child: const Text('Aprovar Visitante'),
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

  Future<void> _updateVisitorStatus(Visitor visitor, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitor.id)
        .update({'status': newStatus});

    if (mounted) {
      setState(() {
        visitors =
            visitors.map((v) {
              if (v.id == visitor.id) {
                return v.copyWith(status: newStatus);
              }
              return v;
            }).toList();
      });
    }
  }
}
