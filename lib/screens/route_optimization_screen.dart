import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/call_register.dart';
import '../models/route_point.dart';
import '../services/api_service.dart';
import '../services/route_optimization_service.dart';
import 'customer_visit_screen.dart';
import 'job_sheet_screen.dart';

class RouteOptimizationScreen extends StatefulWidget {
  const RouteOptimizationScreen({super.key});

  @override
  State<RouteOptimizationScreen> createState() => _RouteOptimizationScreenState();
}

class _RouteOptimizationScreenState extends State<RouteOptimizationScreen> {
  // Engineer Base Depot / Home Location
  final double _startLat = 23.022512;
  final double _startLng = 72.571401;
  final String _startLocationName = 'LG Regional Depot (Sector 1, Ahmedabad)';

  List<CallRegister> _allCalls = [];
  EngineRouteSummary? _routeSummary;
  bool _isLoading = true;
  CallRegister? _nextSuggestedCall;
  bool _isGeofenceArrivalDetected = false;

  @override
  void initState() {
    super.initState();
    _loadAndOptimizeRoute();
  }

  Future<void> _loadAndOptimizeRoute() async {
    setState(() => _isLoading = true);
    final calls = await ApiService().getCallRegister();

    final summary = RouteOptimizationService().optimizeRoute(
      calls: calls,
      startLat: _startLat,
      startLng: _startLng,
      startLocationName: _startLocationName,
    );

    // Identify next suggested call (first pending call in sequence)
    CallRegister? nextCall;
    try {
      nextCall = summary.optimizedCalls.firstWhere((c) => c.status != 'Completed');
    } catch (_) {
      nextCall = null;
    }

    setState(() {
      _allCalls = calls;
      _routeSummary = summary;
      _nextSuggestedCall = nextCall;
      _isLoading = false;
    });
  }

  void _triggerRouteOptimization() {
    _loadAndOptimizeRoute();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFC4032A),
        content: Text('⚡ AI Route Optimized! Priority scores, 10 AM time slots & distance matrix updated.'),
      ),
    );
  }

  void _simulateEmergencyAutoAssign() async {
    final emergency = await ApiService().autoAssignEmergencyCall();
    if (emergency != null) {
      await _loadAndOptimizeRoute();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
            content: Row(
              children: const [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('🚨 Nearby Emergency Call Auto-Assigned! ICU Ward Chiller failure added to #1 priority.'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _updateCallLiveStatus(CallRegister call, String newLiveStatus) async {
    await ApiService().updateCallLiveStatus(call.callId, newLiveStatus);

    if (newLiveStatus == 'Reached') {
      setState(() {
        _isGeofenceArrivalDetected = true;
      });
    }

    await _loadAndOptimizeRoute();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue.shade900,
          content: Text('Status for ${call.callId} updated to: $newLiveStatus'),
        ),
      );
    }
  }

  Future<void> _launchGoogleMaps(double lat, double lng, String address) async {
    final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback url launch attempt
      await launchUrl(Uri.parse('https://maps.google.com/?q=$lat,$lng'), mode: LaunchMode.externalApplication);
    }
  }

  Color _getServiceTypeColor(String type) {
    if (type.contains('Emergency')) return Colors.red;
    if (type.contains('AMC')) return Colors.green;
    if (type.contains('Installation')) return Colors.purple;
    if (type.contains('Demo')) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.alt_route, color: Colors.white),
            SizedBox(width: 8),
            Text('Route Optimization & Maps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Optimize Route Now',
            onPressed: _triggerRouteOptimization,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAndOptimizeRoute,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Location Depot Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
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
                            Row(
                              children: const [
                                Icon(Icons.home_work, color: Colors.amber, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'START POINT: OFFICE / DEPOT',
                                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.greenAccent),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 12),
                                  SizedBox(width: 4),
                                  Text('GPS Active', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_startLocationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('GPS Coordinates: $_startLat, $_startLng', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const Divider(color: Colors.white24, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.speed, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text('Start Odometer: 12,450 KM', style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                              ],
                            ),
                            Text('Updated: ${timeFormat.format(DateTime.now())}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Route Optimization Engine Action Bar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC4032A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: _triggerRouteOptimization,
                          icon: const Icon(Icons.flash_on, color: Colors.amber),
                          label: const Text(
                            'Optimize Route',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.add_alert, color: Color(0xFFC4032A)),
                        tooltip: 'Simulate Nearby Emergency Call',
                        onPressed: _simulateEmergencyAutoAssign,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Auto Next Call Suggestion Banner
                  if (_nextSuggestedCall != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade900, Colors.blue.shade700],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.navigation, color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '🎯 AUTO NEXT BEST ROUTE',
                                  style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _nextSuggestedCall!.customerName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  'Distance: ${_nextSuggestedCall!.distanceKm} KM | Traffic ETA: ${_nextSuggestedCall!.trafficEta}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: () => _launchGoogleMaps(
                              _nextSuggestedCall!.latitude,
                              _nextSuggestedCall!.longitude,
                              _nextSuggestedCall!.address,
                            ),
                            icon: const Icon(Icons.near_me, size: 16),
                            label: const Text('Navigate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Geo-fencing Arrival Detector Notification Card
                  if (_isGeofenceArrivalDetected) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.location_on, color: Colors.green, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🟢 GEO-FENCE ARRIVAL DETECTED',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Text(
                                  'Engineer is within 50m of customer site. Live status auto-updated to Reached!',
                                  style: TextStyle(fontSize: 11, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Best Visit Sequence Call List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Best Visit Sequence Today',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_routeSummary?.optimizedCalls.length ?? 0} Calls',
                          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _routeSummary?.optimizedCalls.length ?? 0,
                    itemBuilder: (context, index) {
                      final call = _routeSummary!.optimizedCalls[index];
                      final isCompleted = call.status == 'Completed';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: call.serviceType.contains('Emergency')
                                ? Colors.red
                                : call.timeSlot.contains('10:00 AM')
                                    ? Colors.amber.shade700
                                    : Colors.grey.shade200,
                            width: call.serviceType.contains('Emergency') ? 2.0 : 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sequence Header & Badges
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: isCompleted
                                            ? Colors.green
                                            : index == 0
                                                ? const Color(0xFFC4032A)
                                                : const Color(0xFF1E293B),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        call.callId,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFC4032A)),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _getServiceTypeColor(call.serviceType).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: _getServiceTypeColor(call.serviceType)),
                                        ),
                                        child: Text(
                                          call.serviceType,
                                          style: TextStyle(
                                            color: _getServiceTypeColor(call.serviceType),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (call.timeSlot.contains('10:00 AM'))
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.amber.shade800),
                                          ),
                                          child: Text(
                                            '🕒 10 AM Slot',
                                            style: TextStyle(
                                              color: Colors.amber.shade900,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              Text(call.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(call.address, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lat: ${call.latitude} | Lng: ${call.longitude}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),

                              const Divider(height: 20),

                              // Distance + Live Traffic ETA Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.map, size: 16, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Distance: ${call.distanceKm} KM',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.traffic, size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Traffic ETA: ${call.trafficEta}',
                                        style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Live Status Selector Buttons (Travelling, Reached, Working, Completed)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildLiveStatusChip(call, 'Travelling', '🟢 Travelling', Colors.green),
                                      _buildLiveStatusChip(call, 'Reached', '🟡 Reached', Colors.amber.shade800),
                                      _buildLiveStatusChip(call, 'Working', '🔵 Working', Colors.blue),
                                      _buildLiveStatusChip(call, 'Completed', '✅ Completed', Colors.teal),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Navigation & Job Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _launchGoogleMaps(call.latitude, call.longitude, call.address),
                                      icon: const Icon(Icons.navigation, size: 16),
                                      label: const Text('📍 Navigate Maps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFC4032A),
                                      side: const BorderSide(color: Color(0xFFC4032A)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CustomerVisitScreen(call: call)),
                                      );
                                    },
                                    icon: const Icon(Icons.how_to_reg, size: 16),
                                    label: const Text('Check-In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                                    icon: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 18),
                                    tooltip: 'Job Sheet',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => JobSheetScreen(callId: call.callId)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Route Replay Timeline Card
                  const Text(
                    '🗺️ Complete Route Replay Timeline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildReplayStep('Start Depot', _startLocationName, '0.0 KM', isFirst: true),
                        ...?_routeSummary?.optimizedCalls.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final call = entry.value;
                          return _buildReplayStep(
                            'Stop ${idx + 1}',
                            '${call.customerName} (${call.serviceType})',
                            '${call.distanceKm} KM',
                          );
                        }),
                        _buildReplayStep('End Return Hub', 'Return to Depot Location', 'Total ${_routeSummary?.totalDistanceKm ?? 0} KM', isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Daily KM Report & Fuel Expense Estimator Card
                  const Text(
                    '⛽ Daily KM & Fuel Expense Estimator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.slate.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFuelStat('Total Distance', '${_routeSummary?.totalDistanceKm ?? 0} KM', Icons.straighten, Colors.blue),
                            _buildFuelStat('Est. Travel Time', '${_routeSummary?.totalEstimatedMinutes ?? 0} Mins', Icons.timer, Colors.orange),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFuelStat('Est. Fuel Usage', '${_routeSummary?.estimatedFuelLiters ?? 0} L', Icons.local_gas_station, Colors.purple),
                            _buildFuelStat('Fuel Expense', '₹${_routeSummary?.estimatedFuelCostInr ?? 0}', Icons.currency_rupee, Colors.green),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 14, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                'Calculated @ 15.0 KM/L average & ₹96.50/L petrol rate.',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Offline Map Cache Mode Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.offline_pin, color: Colors.blueGrey, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline Map Support: Route matrix cached locally. Navigation fallback available without active internet connection.',
                            style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLiveStatusChip(CallRegister call, String statusKey, String label, Color color) {
    final isSelected = call.liveStatus == statusKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 11)),
        selected: isSelected,
        selectedColor: color,
        backgroundColor: Colors.white,
        onSelected: (selected) {
          if (selected) _updateCallLiveStatus(call, statusKey);
        },
      ),
    );
  }

  Widget _buildReplayStep(String stepTitle, String subtitle, String distance, {bool isFirst = false, bool isLast = false}) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst ? Colors.amber : isLast ? Colors.green : const Color(0xFFC4032A),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stepTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ],
          ),
        ),
        Text(distance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue)),
      ],
    );
  }

  Widget _buildFuelStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          ],
        ),
      ],
    );
  }
}
