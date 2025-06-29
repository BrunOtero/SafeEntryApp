import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:safeentry/models/visitor.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = status == PermissionStatus.granted;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permissão necessária')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Permissão da câmera negada',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkCameraPermission,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

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
                cutOutSize: 300,
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
      if (!hasScanned && mounted) {
        hasScanned = true;
        controller.pauseCamera();
        _processQRCode(scanData.code);
      }
    });
  }

  Future<void> _processQRCode(String? qrCode) async {
    if (qrCode == null || !mounted) return;

    try {
      final data = jsonDecode(qrCode) as Map<String, dynamic>;
      final visitor = Visitor.fromMap(data);

      // Atualiza o status no Firestore
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitor.id)
          .update({'status': 'Confirmado'});

      // Notifica o morador
      await _notifyResident(visitor.residentId, visitor.name);

      // Mostra os detalhes do visitante
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Visitante Autorizado'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome: ${visitor.name}'),
                    Text('Morador: ${visitor.residentName}'),
                    Text('Unidade: ${visitor.unit}'),
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(visitor.entryTime)}',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Fecha o dialog
                      Navigator.pop(context); // Volta para tela anterior
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        ).then((_) {
          controller?.resumeCamera();
          hasScanned = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR Code inválido!')));
        controller?.resumeCamera();
        hasScanned = false;
      }
    }
  }

  Future<void> _notifyResident(String residentId, String visitorName) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'residentId': residentId,
      'message': '$visitorName foi autorizado a entrar.',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
