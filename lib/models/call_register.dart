class CallRegister {
  final String callId;
  final String customerName;
  final String contactNumber;
  final String address;
  final String equipmentModel;
  final String issueDescription;
  final String status; // Pending, In-Progress, Completed, Cancelled
  final String priority; // High, Medium, Low
  final DateTime callDate;
  final String technicianName;
  final double latitude;
  final double longitude;
  final String googleMapsUrl;
  final String serviceType; // Emergency Complaint, AMC Visit, Installation, Demo, Preventive Service
  final String timeSlot; // e.g. 10:00 AM, 02:00 PM, Flexible
  final String liveStatus; // Travelling, Reached, Working, Completed, Pending
  final double distanceKm;
  final String trafficEta;
  final double priorityScore;

  CallRegister({
    required this.callId,
    required this.customerName,
    required this.contactNumber,
    required this.address,
    required this.equipmentModel,
    required this.issueDescription,
    required this.status,
    required this.priority,
    required this.callDate,
    required this.technicianName,
    this.latitude = 23.0225,
    this.longitude = 72.5714,
    this.googleMapsUrl = '',
    this.serviceType = 'Preventive Service',
    this.timeSlot = 'Flexible',
    this.liveStatus = 'Pending',
    this.distanceKm = 0.0,
    this.trafficEta = '0 mins',
    this.priorityScore = 0.0,
  });

  factory CallRegister.fromJson(Map<String, dynamic> json) {
    return CallRegister(
      callId: json['callId'] ?? '',
      customerName: json['customerName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      equipmentModel: json['equipmentModel'] ?? '',
      issueDescription: json['issueDescription'] ?? '',
      status: json['status'] ?? 'Pending',
      priority: json['priority'] ?? 'Medium',
      callDate: DateTime.parse(json['callDate'] ?? DateTime.now().toIso8601String()),
      technicianName: json['technicianName'] ?? 'Unassigned',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 23.0225,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 72.5714,
      googleMapsUrl: json['googleMapsUrl'] ?? '',
      serviceType: json['serviceType'] ?? 'Preventive Service',
      timeSlot: json['timeSlot'] ?? 'Flexible',
      liveStatus: json['liveStatus'] ?? 'Pending',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      trafficEta: json['trafficEta'] ?? '0 mins',
      priorityScore: (json['priorityScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'customerName': customerName,
      'contactNumber': contactNumber,
      'address': address,
      'equipmentModel': equipmentModel,
      'issueDescription': issueDescription,
      'status': status,
      'priority': priority,
      'callDate': callDate.toIso8601String(),
      'technicianName': technicianName,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsUrl': googleMapsUrl,
      'serviceType': serviceType,
      'timeSlot': timeSlot,
      'liveStatus': liveStatus,
      'distanceKm': distanceKm,
      'trafficEta': trafficEta,
      'priorityScore': priorityScore,
    };
  }

  CallRegister copyWith({
    String? status,
    String? liveStatus,
    double? distanceKm,
    String? trafficEta,
    double? priorityScore,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    String? serviceType,
    String? timeSlot,
  }) {
    return CallRegister(
      callId: callId,
      customerName: customerName,
      contactNumber: contactNumber,
      address: address,
      equipmentModel: equipmentModel,
      issueDescription: issueDescription,
      status: status ?? this.status,
      priority: priority,
      callDate: callDate,
      technicianName: technicianName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      serviceType: serviceType ?? this.serviceType,
      timeSlot: timeSlot ?? this.timeSlot,
      liveStatus: liveStatus ?? this.liveStatus,
      distanceKm: distanceKm ?? this.distanceKm,
      trafficEta: trafficEta ?? this.trafficEta,
      priorityScore: priorityScore ?? this.priorityScore,
    );
  }
}
