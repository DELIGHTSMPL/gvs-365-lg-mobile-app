import '../models/call_register.dart';
import '../models/customer.dart';
import '../models/amc_report.dart';
import '../models/job_sheet.dart';
import '../models/attendance_checkin.dart';
import '../models/customer_visit.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Demo Mock Data for GVS 365 LG Automation with GPS & Route Metadata
  final List<CallRegister> _calls = [
    CallRegister(
      callId: 'LG-2026-101',
      customerName: 'Delight Electronics Ltd',
      contactNumber: '+91 98765 43210',
      address: '102 Industrial Zone, Sector 4, Ahmedabad',
      equipmentModel: 'LG Inverter V-Multi Commercial VRF',
      issueDescription: 'Cooling insufficient in Zone 2, Error Code CH-05',
      status: 'In-Progress',
      priority: 'High',
      callDate: DateTime.now().subtract(const Duration(hours: 3)),
      technicianName: 'Rajesh Kumar',
      latitude: 23.0400,
      longitude: 72.5300,
      googleMapsUrl: 'https://maps.google.com/?q=23.0400,72.5300',
      serviceType: 'Emergency Complaint',
      timeSlot: '10:00 AM - 11:30 AM',
      liveStatus: 'Travelling',
      distanceKm: 4.2,
      trafficEta: '12 mins',
      priorityScore: 280.0,
    ),
    CallRegister(
      callId: 'LG-2026-102',
      customerName: 'Shree Krishna Hospitals',
      contactNumber: '+91 98250 11223',
      address: 'Near City Circle, SG Highway, Ahmedabad',
      equipmentModel: 'LG Ductable Split Air Conditioner 5.0 TR',
      issueDescription: 'Scheduled quarterly preventive maintenance & filter clean',
      status: 'Pending',
      priority: 'High',
      callDate: DateTime.now().subtract(const Duration(days: 1)),
      technicianName: 'Rajesh Kumar',
      latitude: 23.0650,
      longitude: 72.5180,
      googleMapsUrl: 'https://maps.google.com/?q=23.0650,72.5180',
      serviceType: 'AMC Visit',
      timeSlot: '10:00 AM - 12:00 PM',
      liveStatus: 'Pending',
      distanceKm: 6.8,
      trafficEta: '18 mins',
      priorityScore: 260.0,
    ),
    CallRegister(
      callId: 'LG-2026-103',
      customerName: 'Nexus Tech Park Office 401',
      contactNumber: '+91 99090 88776',
      address: '4th Floor, Nexus Tower, Vastrapur, Ahmedabad',
      equipmentModel: 'LG Dual Inverter Cassette AC 3.0 TR',
      issueDescription: 'Water leakage from indoor unit drain pan',
      status: 'Pending',
      priority: 'Medium',
      callDate: DateTime.now().subtract(const Duration(days: 2)),
      technicianName: 'Rajesh Kumar',
      latitude: 23.0350,
      longitude: 72.5250,
      googleMapsUrl: 'https://maps.google.com/?q=23.0350,72.5250',
      serviceType: 'Installation',
      timeSlot: '02:00 PM - 04:00 PM',
      liveStatus: 'Pending',
      distanceKm: 3.5,
      trafficEta: '10 mins',
      priorityScore: 110.0,
    ),
    CallRegister(
      callId: 'LG-2026-104',
      customerName: 'Apex Healthcare Labs',
      contactNumber: '+91 98980 33445',
      address: 'Plot 45, Science City Road, Ahmedabad',
      equipmentModel: 'LG Precision Air Conditioner 10 TR',
      issueDescription: 'Annual Preventive Maintenance (PM Check)',
      status: 'Pending',
      priority: 'Low',
      callDate: DateTime.now(),
      technicianName: 'Rajesh Kumar',
      latitude: 23.0800,
      longitude: 72.5050,
      googleMapsUrl: 'https://maps.google.com/?q=23.0800,72.5050',
      serviceType: 'Preventive Service',
      timeSlot: 'Flexible',
      liveStatus: 'Pending',
      distanceKm: 9.1,
      trafficEta: '24 mins',
      priorityScore: 40.0,
    ),
  ];

  final List<Customer> _customers = [
    Customer(
      customerId: 'CUST-001',
      name: 'Delight Electronics Ltd',
      phone: '+91 98765 43210',
      email: 'service@delightelectronics.com',
      city: 'Ahmedabad',
      fullAddress: '102 Industrial Zone, Sector 4, Ahmedabad',
      lgEquipmentModel: 'LG Inverter V-Multi Commercial VRF',
      serialNumber: 'LGVRF2025-99881',
      amcStatus: 'Active',
    ),
    Customer(
      customerId: 'CUST-002',
      name: 'Shree Krishna Hospitals',
      phone: '+91 98250 11223',
      email: 'admin@skhospital.org',
      city: 'Ahmedabad',
      fullAddress: 'Near City Circle, SG Highway, Ahmedabad',
      lgEquipmentModel: 'LG Ductable Split AC 5.0 TR',
      serialNumber: 'LGDS2024-55441',
      amcStatus: 'Active',
    ),
    Customer(
      customerId: 'CUST-003',
      name: 'Nexus Tech Park',
      phone: '+91 99090 88776',
      email: 'facilities@nexustech.com',
      city: 'Ahmedabad',
      fullAddress: '4th Floor, Nexus Tower, Vastrapur',
      lgEquipmentModel: 'LG Dual Inverter Cassette AC 3.0 TR',
      serialNumber: 'LGCAS2023-11223',
      amcStatus: 'Expired',
    ),
  ];

  final List<AmcReport> _amcReports = [
    AmcReport(
      amcId: 'AMC-LG-2026-01',
      customerName: 'Delight Electronics Ltd',
      equipmentDetails: 'LG VRF System 16 HP (2 Units)',
      startDate: DateTime(2025, 4, 1),
      endDate: DateTime(2026, 3, 31),
      contractAmount: 145000.0,
      contractStatus: 'Active',
      totalServicesIncluded: 4,
      servicesCompleted: 3,
    ),
    AmcReport(
      amcId: 'AMC-LG-2026-02',
      customerName: 'Shree Krishna Hospitals',
      equipmentDetails: 'LG Ductable System 5.0 TR (4 Units)',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2026, 12, 31),
      contractAmount: 98000.0,
      contractStatus: 'Active',
      totalServicesIncluded: 4,
      servicesCompleted: 2,
    ),
    AmcReport(
      amcId: 'AMC-LG-2025-09',
      customerName: 'Nexus Tech Park',
      equipmentDetails: 'LG Cassette AC 3.0 TR (6 Units)',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2025, 5, 31),
      contractAmount: 75000.0,
      contractStatus: 'Expired',
      totalServicesIncluded: 4,
      servicesCompleted: 4,
    ),
  ];

  final List<JobSheet> _jobSheets = [];
  final List<CustomerVisit> _customerVisits = [];
  AttendanceCheckIn? _latestCheckIn;

  // Attendance Check-In Services
  Future<AttendanceCheckIn?> getLatestCheckIn() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _latestCheckIn;
  }

  Future<bool> saveAttendanceCheckIn(AttendanceCheckIn checkIn) async {
    _latestCheckIn = checkIn;
    return true;
  }

  // Customer Visit Tracking Services
  Future<List<CustomerVisit>> getCustomerVisits() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _customerVisits;
  }

  Future<bool> saveCustomerVisit(CustomerVisit visit) async {
    _customerVisits.insert(0, visit);
    await updateCallStatus(visit.callId, 'In-Progress');
    await updateCallLiveStatus(visit.callId, 'Working');
    return true;
  }

  Future<bool> updateCustomerVisitDeparture(String visitId, DateTime departureTime, double depLat, double depLng) async {
    final index = _customerVisits.indexWhere((v) => v.visitId == visitId);
    if (index != -1) {
      final old = _customerVisits[index];
      final duration = departureTime.difference(old.arrivalTime).inMinutes;
      _customerVisits[index] = CustomerVisit(
        visitId: old.visitId,
        callId: old.callId,
        customerName: old.customerName,
        customerAddress: old.customerAddress,
        customerGpsLat: old.customerGpsLat,
        customerGpsLng: old.customerGpsLng,
        engineerArrivalLat: old.engineerArrivalLat,
        engineerArrivalLng: old.engineerArrivalLng,
        engineerDepartureLat: depLat,
        engineerDepartureLng: depLng,
        arrivalTime: old.arrivalTime,
        departureTime: departureTime,
        visitDurationMinutes: duration > 0 ? duration : 1,
        status: 'Departed',
        routeWaypoints: old.routeWaypoints,
      );
      await updateCallLiveStatus(old.callId, 'Completed');
      return true;
    }
    return false;
  }

  // API Call Handlers
  Future<List<CallRegister>> getCallRegister() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _calls;
  }

  Future<bool> addCallRegister(CallRegister newCall) async {
    _calls.insert(0, newCall);
    return true;
  }

  Future<bool> updateCallStatus(String callId, String status) async {
    final index = _calls.indexWhere((c) => c.callId == callId);
    if (index != -1) {
      final old = _calls[index];
      _calls[index] = old.copyWith(status: status);
      return true;
    }
    return false;
  }

  Future<bool> updateCallLiveStatus(String callId, String liveStatus) async {
    final index = _calls.indexWhere((c) => c.callId == callId);
    if (index != -1) {
      final old = _calls[index];
      String status = old.status;
      if (liveStatus == 'Completed') {
        status = 'Completed';
      } else if (liveStatus == 'Working' || liveStatus == 'Reached' || liveStatus == 'Travelling') {
        status = 'In-Progress';
      }
      _calls[index] = old.copyWith(
        liveStatus: liveStatus,
        status: status,
      );
      return true;
    }
    return false;
  }

  Future<CallRegister?> autoAssignEmergencyCall() async {
    final emergencyCall = CallRegister(
      callId: 'LG-2026-999',
      customerName: 'Emergency: Sterling Hospital ICU Ward',
      contactNumber: '+91 99887 11223',
      address: 'Drive-In Road, Memnagar, Ahmedabad',
      equipmentModel: 'LG Modular Chiller System 50 TR',
      issueDescription: 'CRITICAL: Chiller high pressure trip in Operation Theatre AC',
      status: 'Pending',
      priority: 'High',
      callDate: DateTime.now(),
      technicianName: 'Rajesh Kumar',
      latitude: 23.0480,
      longitude: 72.5280,
      googleMapsUrl: 'https://maps.google.com/?q=23.0480,72.5280',
      serviceType: 'Emergency Complaint',
      timeSlot: 'IMMEDIATE',
      liveStatus: 'Pending',
      distanceKm: 2.1,
      trafficEta: '6 mins',
      priorityScore: 350.0,
    );

    // Add at index 0 if not already assigned
    if (!_calls.any((c) => c.callId == emergencyCall.callId)) {
      _calls.insert(0, emergencyCall);
      return emergencyCall;
    }
    return null;
  }

  Future<List<Customer>> getCustomers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _customers;
  }

  Future<List<AmcReport>> getAmcReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _amcReports;
  }

  Future<List<JobSheet>> getJobSheets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _jobSheets;
  }

  Future<bool> saveJobSheet(JobSheet sheet) async {
    _jobSheets.insert(0, sheet);
    // Automatically mark associated call as completed
    await updateCallStatus(sheet.callId, 'Completed');
    await updateCallLiveStatus(sheet.callId, 'Completed');
    return true;
  }
}
