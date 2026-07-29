class Customer {
  final String customerId;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String fullAddress;
  final String lgEquipmentModel;
  final String serialNumber;
  final String amcStatus; // Active, Expired, None

  Customer({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.fullAddress,
    required this.lgEquipmentModel,
    required this.serialNumber,
    required this.amcStatus,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      city: json['city'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      lgEquipmentModel: json['lgEquipmentModel'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      amcStatus: json['amcStatus'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'phone': phone,
      'email': email,
      'city': city,
      'fullAddress': fullAddress,
      'lgEquipmentModel': lgEquipmentModel,
      'serialNumber': serialNumber,
      'amcStatus': amcStatus,
    };
  }
}
