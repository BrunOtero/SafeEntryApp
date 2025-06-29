import 'package:flutter/material.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registros de Acesso')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text('Visitante ${index + 1}'),
            subtitle: const Text('Entrada: 10/05/2023 14:30'),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}
