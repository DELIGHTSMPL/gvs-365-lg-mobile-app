class AmcReport {
  final String amcId;
  final String customerName;
  final String equipmentDetails;
  final DateTime startDate;
  final DateTime endDate;
  final double contractAmount;
  final String contractStatus; // Active, Expiring Soon, Expired
  final int totalServicesIncluded;
  final int servicesCompleted;

  AmcReport({
    required this.amcId,
    required this.customerName,
    required this.equipmentDetails,
    required this.startDate,
    required this.endDate,
    required this.contractAmount,
    required this.contractStatus,
    required this.totalServicesIncluded,
    required this.servicesCompleted,
  });

  factory AmcReport.fromJson(Map<String, dynamic> json) {
    return AmcReport(
      amcId: json['amcId'] ?? '',
      customerName: json['customerName'] ?? '',
      equipmentDetails: json['equipmentDetails'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      contractAmount: (json['contractAmount'] as num?)?.toDouble() ?? 0.0,
      contractStatus: json['contractStatus'] ?? 'Active',
      totalServicesIncluded: json['totalServicesIncluded'] ?? 4,
      servicesCompleted: json['servicesCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amcId': amcId,
      'customerName': customerName,
      'equipmentDetails': equipmentDetails,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'contractAmount': contractAmount,
      'contractStatus': contractStatus,
      'totalServicesIncluded': totalServicesIncluded,
      'servicesCompleted': servicesCompleted,
    };
  }
}
