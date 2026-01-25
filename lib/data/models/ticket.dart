class Ticket {
  late String id;
  late String type; // 'bus' or 'train'
  late String route;
  late DateTime date;
  late String time;
  late String ticketNumber;

  String? qrData;
  String? notes;

  Ticket({
    required this.id,
    required this.type,
    required this.route,
    required this.date,
    required this.time,
    required this.ticketNumber,
    this.qrData,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'route': route,
      'date': date.toIso8601String(),
      'time': time,
      'ticketNumber': ticketNumber,
      'qrData': qrData,
      'notes': notes,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      type: json['type'],
      route: json['route'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      ticketNumber: json['ticketNumber'],
      qrData: json['qrData'],
      notes: json['notes'],
    );
  }
}
