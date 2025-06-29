import 'package:intl/intl.dart';

class Visitor {
  final String id;
  final String name;
  final String residentId;
  final String residentName;
  final String status;
  final DateTime entryTime;
  final String? unit;

  Visitor({
    required this.id,
    required this.name,
    required this.residentId,
    required this.residentName,
    this.status = 'Pendente',
    required this.entryTime,
    this.unit,
  });

  // Método para converter para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'residentId': residentId,
      'residentName': residentName,
      'status': status,
      'entryTime': entryTime.toIso8601String(),
      'unit': unit,
    };
  }

  // Factory method para criar a partir de Map (Firestore/JSON)
  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id:
          map['id'] ??
          map['visitorId'] ??
          '', // Compatibilidade com campos alternativos
      name: map['name'] ?? 'Visitante não identificado',
      residentId: map['residentId'] ?? '',
      residentName: map['residentName'] ?? 'Morador não identificado',
      status: map['status'] ?? 'Pendente',
      entryTime:
          map['entryTime'] != null
              ? DateTime.parse(map['entryTime'])
              : DateTime.now(), // Fallback para data atual
      unit: map['unit'],
    );
  }

  // Método para formatar a data de entrada
  String get formattedEntryTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(entryTime);
  }

  // Método para criar cópia com status alterado
  Visitor copyWith({String? status}) {
    return Visitor(
      id: id,
      name: name,
      residentId: residentId,
      residentName: residentName,
      status: status ?? this.status,
      entryTime: entryTime,
      unit: unit,
    );
  }
}
