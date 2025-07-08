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

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id:
          map['id'] ??
          map['visitorId'] ??
          '',
      name: map['name'] ?? 'Visitante não identificado',
      residentId: map['residentId'] ?? '',
      residentName: map['residentName'] ?? 'Morador não identificado',
      status: map['status'] ?? 'Pendente',
      entryTime:
          map['entryTime'] != null
              ? DateTime.parse(map['entryTime'])
              : DateTime.now(),
      unit: map['unit'],
    );
  }

  String get formattedEntryTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(entryTime);
  }

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
