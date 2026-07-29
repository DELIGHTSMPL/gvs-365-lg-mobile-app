class CustomerVisit {
  final String visitId;
  final String callId;
  final String customerName;
  final String customerAddress;
  final double customerGpsLat;
  final double customerGpsLng;
  final double engineerArrivalLat;
  final double engineerArrivalLng;
  final double? engineerDepartureLat;
  final double? engineerDepartureLng;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final int? visitDurationMinutes;
  final String status; // In Transit, Arrived, Work In Progress, Departed
  final List<String> routeWaypoints;

  CustomerVisit({
    required this.visitId,
    required this.callId,
    required this.customerName,
    required this.customerAddress,
    required this.customerGpsLat,
    required this.customerGpsLng,
    required this.engineerArrivalLat,
    required this.engineerArrivalLng,
    this.engineerDepartureLat,
    this.engineerDepartureLng,
    required this.arrivalTime,
    this.departureTime,
    this.visitDurationMinutes,
    required this.status,
    required this.routeWaypoints,
  });

  factory CustomerVisit.fromJson(Map<String, dynamic> json) {
    return CustomerVisit(
      visitId: json['visitId'] ?? '',
      callId: json['callId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerGpsLat: (json['customerGpsLat'] as num?)?.toDouble() ?? 0.0,
      customerGpsLng: (json['customerGpsLng'] as num?)?.toDouble() ?? 0.0,
      engineerArrivalLat: (json['engineerArrivalLat'] as num?)?.toDouble() ?? 0.0,
      engineerArrivalLng: (json['engineerArrivalLng'] as num?)?.toDouble() ?? 0.0,
      engineerDepartureLat: (json['engineerDepartureLat'] as num?)?.toDouble(),
      engineerDepartureLng: (json['engineerDepartureLng'] as num?)?.toDouble(),
      arrivalTime: DateTime.parse(json['arrivalTime'] ?? DateTime.now().toIso8601String()),
      departureTime: json['departureTime'] != null ? DateTime.parse(json['departureTime']) : null,
      visitDurationMinutes: json['visitDurationMinutes'],
      status: json['status'] ?? 'In Transit',
      routeWaypoints: List<String>.from(json['routeWaypoints'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'callId': callId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerGpsLat': customerGpsLat,
      'customerGpsLng': customerGpsLng,
      'engineerArrivalLat': engineerArrivalLat,
      'engineerArrivalLng': engineerArrivalLng,
      'engineerDepartureLat': engineerDepartureLat,
      'engineerDepartureLng': engineerDepartureLng,
      'arrivalTime': arrivalTime.toIso8601String(),
      'departureTime': departureTime?.toIso8601String(),
      'visitDurationMinutes': visitDurationMinutes,
      'status': status,
      'routeWaypoints': routeWaypoints,
    };
  }
}
