class AttendanceCheckIn {
  final String checkInId;
  final String engineerName;
  final String vehicleNumber;
  final String? meterPhotoPath;
  final int meterReadingKm;
  final double latitude;
  final double longitude;
  final DateTime checkInTime;
  final String deviceId;
  final int batteryLevel;
  final String status; // Checked In, Checked Out

  AttendanceCheckIn({
    required this.checkInId,
    required this.engineerName,
    required this.vehicleNumber,
    this.meterPhotoPath,
    required this.meterReadingKm,
    required this.latitude,
    required this.longitude,
    required this.checkInTime,
    required this.deviceId,
    required this.batteryLevel,
    this.status = 'Checked In',
  });

  factory AttendanceCheckIn.fromJson(Map<String, dynamic> json) {
    return AttendanceCheckIn(
      checkInId: json['checkInId'] ?? '',
      engineerName: json['engineerName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      meterPhotoPath: json['meterPhotoPath'],
      meterReadingKm: json['meterReadingKm'] ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      checkInTime: DateTime.parse(json['checkInTime'] ?? DateTime.now().toIso8601String()),
      deviceId: json['deviceId'] ?? '',
      batteryLevel: json['batteryLevel'] ?? 100,
      status: json['status'] ?? 'Checked In',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkInId': checkInId,
      'engineerName': engineerName,
      'vehicleNumber': vehicleNumber,
      'meterPhotoPath': meterPhotoPath,
      'meterReadingKm': meterReadingKm,
      'latitude': latitude,
      'longitude': longitude,
      'checkInTime': checkInTime.toIso8601String(),
      'deviceId': deviceId,
      'batteryLevel': batteryLevel,
      'status': status,
    };
  }
}
