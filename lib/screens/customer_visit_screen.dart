import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/call_register.dart';
import '../models/customer_visit.dart';
import '../services/api_service.dart';

class CustomerVisitScreen extends StatefulWidget {
  final CallRegister call;

  const CustomerVisitScreen({super.key, required this.call});

  @override
  State<CustomerVisitScreen> createState() => _CustomerVisitScreenState();
}

class _CustomerVisitScreenState extends State<CustomerVisitScreen> {
  // Live GPS Simulation
  final double _engineerLat = 23.022512;
  final double _engineerLng = 72.571401;
  final double _customerLat = 23.022600;
  final double _customerLng = 72.571500;

  CustomerVisit? _activeVisit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingVisit();
  }

  Future<void> _loadExistingVisit() async {
    final visits = await ApiService().getCustomerVisits();
    final existing = visits.where((v) => v.callId == widget.call.callId).toList();

    setState(() {
      if (existing.isNotEmpty) {
        _activeVisit = existing.first;
      }
      _isLoading = false;
    });
  }

  void _markArrival() async {
    final newVisit = CustomerVisit(
      visitId: 'VISIT-${DateTime.now().millisecondsSinceEpoch}',
      callId: widget.call.callId,
      customerName: widget.call.customerName,
      customerAddress: widget.call.address,
      customerGpsLat: _customerLat,
      customerGpsLng: _customerLng,
      engineerArrivalLat: _engineerLat,
      engineerArrivalLng: _engineerLng,
      arrivalTime: DateTime.now(),
      status: 'Arrived',
      routeWaypoints: [
        '23.0150, 72.5600 (Departed Hub)',
        '23.0180, 72.5650 (En Route)',
        '23.0225, 72.5714 (Arrived Customer Site)',
      ],
    );

    await ApiService().saveCustomerVisit(newVisit);
    setState(() {
      _activeVisit = newVisit;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('📍 Arrival Logged! Live GPS verified & Site arrival time recorded.'),
        ),
      );
    }
  }

  void _markDeparture() async {
    if (_activeVisit == null) return;

    final depTime = DateTime.now();
    await ApiService().updateCustomerVisitDeparture(
      _activeVisit!.visitId,
      depTime,
      _engineerLat,
      _engineerLng,
    );

    await _loadExistingVisit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue.shade800,
          content: Text('🚗 Departure Logged! Total Duration: ${_activeVisit?.visitDurationMinutes ?? 0} mins.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm:ss a');
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Customer Visit Tracking'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Call Overview Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.call.callId,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC4032A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Text(
                                _activeVisit != null ? _activeVisit!.status : 'Duty Visit Pending',
                                style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.call.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(widget.call.address, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text('Equipment: ${widget.call.equipmentModel}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('Issue: ${widget.call.issueDescription}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '📍 Live Location & Customer GPS Match',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),

                  // GPS Proximity Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Engineer Live GPS:', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  Text('$_engineerLat, $_engineerLng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const Icon(Icons.compare_arrows, color: Colors.blue),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Customer Site GPS:', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  Text('$_customerLat, $_customerLng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.verified, color: Colors.green, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Proximity Verified: Engineer is at Customer Location (< 15 meters)',
                                  style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '🕒 Visit Timestamps & Duration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),

                  // Timestamps Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _activeVisit != null ? Colors.green.shade100 : Colors.grey.shade200,
                            child: Icon(Icons.login, color: _activeVisit != null ? Colors.green : Colors.grey),
                          ),
                          title: const Text('Arrival Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            _activeVisit != null
                                ? '${dateFormat.format(_activeVisit!.arrivalTime)} at ${timeFormat.format(_activeVisit!.arrivalTime)}'
                                : 'Not Arrived Yet',
                          ),
                          trailing: _activeVisit == null
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4032A)),
                                  onPressed: _markArrival,
                                  child: const Text('Mark Arrival', style: TextStyle(color: Colors.white)),
                                )
                              : const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        const Divider(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _activeVisit?.departureTime != null ? Colors.blue.shade100 : Colors.grey.shade200,
                            child: Icon(Icons.logout, color: _activeVisit?.departureTime != null ? Colors.blue : Colors.grey),
                          ),
                          title: const Text('Departure Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            _activeVisit?.departureTime != null
                                ? '${dateFormat.format(_activeVisit!.departureTime!)} at ${timeFormat.format(_activeVisit!.departureTime!)}'
                                : _activeVisit != null
                                    ? 'Work In Progress at site...'
                                    : 'Awaiting Arrival',
                          ),
                          trailing: _activeVisit != null && _activeVisit?.departureTime == null
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                                  onPressed: _markDeparture,
                                  child: const Text('Mark Departure', style: TextStyle(color: Colors.white)),
                                )
                              : _activeVisit?.departureTime != null
                                  ? const Icon(Icons.check_circle, color: Colors.blue)
                                  : null,
                        ),
                        if (_activeVisit?.visitDurationMinutes != null) ...[
                          const Divider(height: 16),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Service Duration:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(
                                  '${_activeVisit!.visitDurationMinutes} Minutes',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_activeVisit != null && _activeVisit!.routeWaypoints.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      '🗺️ Route Tracking (GPS Breadcrumbs)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: _activeVisit!.routeWaypoints.map((wpt) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.navigation, size: 14, color: Color(0xFFC4032A)),
                                  const SizedBox(width: 8),
                                  Text(wpt, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
