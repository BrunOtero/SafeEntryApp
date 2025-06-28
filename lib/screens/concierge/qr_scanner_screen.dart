import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ler QR Code'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      _processQRCode(scanData.code);
    });
  }

  void _processQRCode(String? qrCode) {
    if (qrCode == null) return;

    if (qrCode.startsWith('VISITANTE:')) {
      final parts = qrCode.split(':');
      if (parts.length >= 2) {
        final visitorName = parts[1];
        Navigator.pop(context, visitorName); // Retorna o nome
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visitante autorizado: $visitorName'),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }
    }

    // QR Code inválido
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code inválido'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
