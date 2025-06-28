import 'package:flutter/material.dart';
import 'package:safeentry/widgets/custom_button.dart';
import 'package:safeentry/screens/concierge/qr_scanner_screen.dart'; // ✅ Importação adicionada

class ConciergeHomeScreen extends StatelessWidget {
  const ConciergeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel do Porteiro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo, Porteiro!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Ler QR Code',
              onPressed: () async {
                final qrCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );

                if (qrCode != null) {
                  // Aqui você pode processar o QR Code lido
                  debugPrint('QR Code lido: $qrCode');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
