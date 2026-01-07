enum TicketStatus {
  pending,
  paid,
  used,
  cancelled,
}

class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final String qrCode;
  final TicketStatus status;
  final double price;
  final String? paymentMethod;
  final DateTime purchaseDate;
  final DateTime? usedDate;

  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.qrCode,
    required this.status,
    required this.price,
    this.paymentMethod,
    required this.purchaseDate,
    this.usedDate,
  });

  bool get isValid => status == TicketStatus.paid && usedDate == null;
  bool get isPaid => status == TicketStatus.paid;
  bool get isUsed => status == TicketStatus.used;

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      qrCode: json['qrCode'],
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.pending,
      ),
      price: json['price'].toDouble(),
      paymentMethod: json['paymentMethod'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      usedDate: json['usedDate'] != null ? DateTime.parse(json['usedDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'qrCode': qrCode,
      'status': status.name,
      'price': price,
      'paymentMethod': paymentMethod,
      'purchaseDate': purchaseDate.toIso8601String(),
      'usedDate': usedDate?.toIso8601String(),
    };
  }
}
