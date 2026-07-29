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
    };
  }
}
