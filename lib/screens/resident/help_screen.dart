import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda e Suporte')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perguntas Frequentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Como cadastrar um visitante?'),
            SizedBox(height: 20),
            Text('Como gerar um QR Code?'),
            SizedBox(height: 20),
            Text('Como entrar em contato com a portaria?'),
            SizedBox(height: 30),
            Text(
              'Contato de Suporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Email: suporte@safeentry.com'),
            Text('Telefone: (11) 1234-5678'),
          ],
        ),
      ),
    );
  }
}
