import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:safeentry/constants/app_colors.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  // Lista de visitantes - ADICIONE ESTA VARIÁVEL
  List<Map<String, dynamic>> visitors = [
    {'name': 'Visitante 1', 'status': 'Pendente', 'time': '10:30 AM'},
    {'name': 'Visitante 2', 'status': 'Pendente', 'time': '11:45 AM'},
    {'name': 'Visitante 3', 'status': 'Pendente', 'time': '02:15 PM'},
  ];

  // Variáveis para controle do QR Code
  String? generatedQRCode;
  String currentVisitorName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Morador'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _registerNewVisitor(context),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Cadastrar', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (generatedQRCode != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'QR Code para:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentVisitorName,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: generatedQRCode!,
                        version: QrVersions.auto,
                        size: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mostre este código na portaria',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Visitantes Cadastrados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  visitors.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum visitante cadastrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: visitors.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
                              ),
                              title: Text(visitors[index]['name']),
                              subtitle: Text(
                                'Status: ${visitors[index]['status']}',
                              ),
                              trailing: Chip(
                                label: Text(visitors[index]['status']),
                                backgroundColor:
                                    visitors[index]['status'] == 'Pendente'
                                        ? Colors.orange.shade100
                                        : Colors.green.shade100,
                              ),
                              onTap: () => _viewVisitorDetails(index),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Visitante',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      visitors.add({
                        'name': nameController.text,
                        'status': 'Pendente',
                        'time': DateTime.now().toString(),
                      });

                      generatedQRCode =
                          'VISITANTE:${nameController.text}:${DateTime.now().millisecondsSinceEpoch}';
                      currentVisitorName = nameController.text;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Gerar QR Code'),
              ),
            ],
          ),
    );
  }

  void _viewVisitorDetails(int index) {
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
                  title: Text(visitors[index]['name']),
                  subtitle: Text('Horário: ${visitors[index]['time']}'),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    visitors[index]['status'] == 'Pendente'
                        ? Icons.pending_actions
                        : Icons.verified,
                    color:
                        visitors[index]['status'] == 'Pendente'
                            ? Colors.orange
                            : Colors.green,
                  ),
                  title: Text('Status: ${visitors[index]['status']}'),
                ),
                const SizedBox(height: 16),
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
}
