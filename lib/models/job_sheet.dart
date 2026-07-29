class JobSheet {
  final String jobSheetId;
  final String callId;
  final String customerName;
  final String customerPhone;
  final String equipmentModel;
  final String serialNumber;
  final String workDoneDetails;
  final List<String> replacedParts;
  final double totalCharges;
  final String technicianSignature;
  final String customerSignature;
  final DateTime completionDate;

  JobSheet({
    required this.jobSheetId,
    required this.callId,
    required this.customerName,
    required this.customerPhone,
    required this.equipmentModel,
    required this.serialNumber,
    required this.workDoneDetails,
    required this.replacedParts,
    required this.totalCharges,
    required this.technicianSignature,
    required this.customerSignature,
    required this.completionDate,
  });

  factory JobSheet.fromJson(Map<String, dynamic> json) {
    return JobSheet(
      jobSheetId: json['jobSheetId'] ?? '',
      callId: json['callId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      equipmentModel: json['equipmentModel'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      workDoneDetails: json['workDoneDetails'] ?? '',
      replacedParts: List<String>.from(json['replacedParts'] ?? []),
      totalCharges: (json['totalCharges'] as num?)?.toDouble() ?? 0.0,
      technicianSignature: json['technicianSignature'] ?? '',
      customerSignature: json['customerSignature'] ?? '',
      completionDate: DateTime.parse(json['completionDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobSheetId': jobSheetId,
      'callId': callId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'equipmentModel': equipmentModel,
      'serialNumber': serialNumber,
      'workDoneDetails': workDoneDetails,
      'replacedParts': replacedParts,
      'totalCharges': totalCharges,
      'technicianSignature': technicianSignature,
      'customerSignature': customerSignature,
      'completionDate': completionDate.toIso8601String(),
    };
  }
}
