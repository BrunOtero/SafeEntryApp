// SafeEntry/App/lib/screens/concierge/qr_scanner_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:safeentry/services/gate_service.dart';
import 'package:safeentry/services/visit_service.dart';
import 'package:safeentry/dto/agendamento_response.dart';

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
  final GateService _gateService = GateService();
  final VisitService _visitService = VisitService();
  final TextEditingController _qrTokenController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

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
      // If permission is denied, show a snackbar. The UI will still render the manual input.
      if (!_hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão da câmera negada. Use a entrada manual.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _qrTokenController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ler QR Code'), centerTitle: true),
      body: Column(
        children: [
          // Conditionally render the QR scanner view
          if (_hasPermission)
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
            )
          else // If no camera permission, allocate more space for manual input
            const Expanded(
              flex: 3, // Adjust flex as needed to give more space
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_photography, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Câmera não disponível. Por favor, use a entrada manual abaixo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          
          // Manual input section (always visible)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _qrTokenController,
                  decoration: const InputDecoration(
                    labelText: 'Inserir QR Token Manualmente',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.text_fields),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _observacoesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações (Opcional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_qrTokenController.text.isNotEmpty) {
                      _processQRCode(
                        _qrTokenController.text,
                        observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, insira um token QR.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Registrar Entrada Manualmente'),
                ),
              ],
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
        _qrTokenController.text = scanData.code ?? ''; // Populate manual input with scanned code
        _processQRCode(scanData.code);
      }
    });
  }

  Future<void> _processQRCode(String? qrCode, {String? observacoes}) async {
    if (qrCode == null || !mounted) return;

    try {
      // 1. Registrar a entrada no Gate Service
      final entradaResponse = await _gateService.registerEntry(qrToken: qrCode, observacoes: observacoes); //

      // 2. Buscar os detalhes completos do agendamento no Visits Service usando o qrCode
      final AgendamentoResponse actualAppointment = await _visitService.getAppointmentByQrToken(qrCode); //

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entrada registrada com sucesso! Visitante: ${actualAppointment.visitante.nome}'),
            backgroundColor: Colors.green,
          ),
        );
        // Retorna o objeto AgendamentoResponse REAL com os dados do visitante
        Navigator.pop(context, actualAppointment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar entrada: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        controller?.resumeCamera();
        hasScanned = false;
      }
    }
  }
}