enum EventStatus {
  upcoming,
  past,
  cancelled,
}

enum TicketType {
  general,
  vip,
  early,
  custom,
}

class Event {
  final String id;
  final String creatorId;
  final String name;
  final DateTime date;
  final String? time;
  final String? location;
  final double? price;
  final int? capacity;
  final String? imageUrl;
  final String? description;
  final EventStatus status;
  final DateTime createdAt;
  final int ticketsSold;
  
  // Campos avanzados
  final String? locationText;
  final String? mapLink;
  final List<TicketTypeOption>? ticketTypes;
  final Map<DateTime, double>? dynamicPricing;
  final List<PaymentMethod>? allowedPaymentMethods;
  final Map<String, dynamic>? advancedConfig;

  Event({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.date,
    this.time,
    this.location,
    this.price,
    this.capacity,
    this.imageUrl,
    this.description,
    this.status = EventStatus.upcoming,
    required this.createdAt,
    this.ticketsSold = 0,
    this.locationText,
    this.mapLink,
    this.ticketTypes,
    this.dynamicPricing,
    this.allowedPaymentMethods,
    this.advancedConfig,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      creatorId: json['creatorId'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      price: json['price']?.toDouble(),
      capacity: json['capacity'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      ticketsSold: json['ticketsSold'] ?? 0,
      locationText: json['locationText'],
      mapLink: json['mapLink'],
      ticketTypes: json['ticketTypes'] != null
          ? (json['ticketTypes'] as List).map((t) => TicketTypeOption.fromJson(t)).toList()
          : null,
      allowedPaymentMethods: json['allowedPaymentMethods'] != null
          ? (json['allowedPaymentMethods'] as List).map((p) => PaymentMethod.fromJson(p)).toList()
          : null,
      advancedConfig: json['advancedConfig'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'name': name,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'price': price,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'ticketsSold': ticketsSold,
      'locationText': locationText,
      'mapLink': mapLink,
      'ticketTypes': ticketTypes?.map((t) => t.toJson()).toList(),
      'allowedPaymentMethods': allowedPaymentMethods?.map((p) => p.toJson()).toList(),
      'advancedConfig': advancedConfig,
    };
  }

  bool get isPopular => ticketsSold > 50 || 
      DateTime.now().difference(createdAt).inDays < 7;
}

class TicketTypeOption {
  final String id;
  final String name;
  final double price;
  final int? quantity;

  TicketTypeOption({
    required this.id,
    required this.name,
    required this.price,
    this.quantity,
  });

  factory TicketTypeOption.fromJson(Map<String, dynamic> json) {
    return TicketTypeOption(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final bool isOnline;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.isOnline,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      isOnline: json['isOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
    };
  }
}
