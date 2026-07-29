import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_checkin.dart';
import '../services/api_service.dart';
import '../widgets/kpi_card.dart';
import 'attendance_checkin_screen.dart';
import 'attendance_checkout_screen.dart';
import 'call_register_screen.dart';
import 'customer_search_screen.dart';
import 'amc_report_screen.dart';
import 'job_sheet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalCalls = 0;
  int _pendingCalls = 0;
  int _activeAmc = 0;
  int _jobSheetsCount = 0;
  AttendanceCheckIn? _checkInStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardMetrics();
  }

  Future<void> _loadDashboardMetrics() async {
    final calls = await ApiService().getCallRegister();
    final amcs = await ApiService().getAmcReports();
    final sheets = await ApiService().getJobSheets();
    final checkIn = await ApiService().getLatestCheckIn();

    setState(() {
      _totalCalls = calls.length;
      _pendingCalls = calls.where((c) => c.status == 'Pending' || c.status == 'In-Progress').length;
      _activeAmc = amcs.where((a) => a.contractStatus == 'Active').length;
      _jobSheetsCount = sheets.length;
      _checkInStatus = checkIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build_circle, color: Color(0xFFC4032A), size: 24),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GVS 365 LG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Automation Hub', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.how_to_reg),
            tooltip: 'Attendance Status',
            onPressed: () async {
              if (_checkInStatus == null) {
                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceCheckInScreen()));
                if (res == true) _loadDashboardMetrics();
              } else if (_checkInStatus!.status == 'Checked In') {
                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceCheckOutScreen(checkIn: _checkInStatus!)));
                if (res == true) _loadDashboardMetrics();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDashboardMetrics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
          : RefreshIndicator(
              onRefresh: _loadDashboardMetrics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Attendance Check-In / Check-Out Banner Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _checkInStatus == null
                            ? const Color(0xFFFFF1F2)
                            : _checkInStatus!.status == 'Checked In'
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _checkInStatus == null
                              ? const Color(0xFFC4032A)
                              : _checkInStatus!.status == 'Checked In'
                                  ? Colors.green
                                  : const Color(0xFF1E293B),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _checkInStatus == null
                                  ? const Color(0xFFC4032A)
                                  : _checkInStatus!.status == 'Checked In'
                                      ? Colors.green
                                      : const Color(0xFF1E293B),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _checkInStatus == null
                                  ? Icons.camera_alt
                                  : _checkInStatus!.status == 'Checked In'
                                      ? Icons.check_circle
                                      : Icons.done_all,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _checkInStatus == null
                                      ? 'ATTENDANCE CHECK-IN PENDING'
                                      : _checkInStatus!.status == 'Checked In'
                                          ? 'CHECKED IN & ON DUTY'
                                          : 'DUTY COMPLETED TODAY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _checkInStatus == null
                                        ? const Color(0xFFC4032A)
                                        : _checkInStatus!.status == 'Checked In'
                                            ? Colors.green.shade900
                                            : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _checkInStatus == null
                                      ? 'Take Vehicle Meter Photo & Geotag GPS to Check In.'
                                      : _checkInStatus!.status == 'Checked In'
                                          ? 'Checked In at ${timeFormat.format(_checkInStatus!.checkInTime)} | Start: ${_checkInStatus!.meterReadingKm} KM'
                                          : 'Checked Out at ${timeFormat.format(_checkInStatus!.checkInTime)} | End: ${_checkInStatus!.meterReadingKm} KM',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _checkInStatus == null
                                  ? const Color(0xFFC4032A)
                                  : _checkInStatus!.status == 'Checked In'
                                      ? const Color(0xFF1E293B)
                                      : Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () async {
                              if (_checkInStatus == null) {
                                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceCheckInScreen()));
                                if (res == true) _loadDashboardMetrics();
                              } else if (_checkInStatus!.status == 'Checked In') {
                                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceCheckOutScreen(checkIn: _checkInStatus!)));
                                if (res == true) _loadDashboardMetrics();
                              }
                            },
                            child: Text(
                              _checkInStatus == null
                                  ? 'Check In'
                                  : _checkInStatus!.status == 'Checked In'
                                      ? 'Check Out'
                                      : 'Done',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Welcome Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF334155)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'LG Service Automation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Manage active calls, LG AMC contracts, customer history, and digital job sheets.',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.air, color: Colors.white54, size: 48),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Overview & Operational KPIs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    // Grid of KPI Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        KpiCard(
                          title: 'Active Calls',
                          value: _pendingCalls.toString(),
                          icon: Icons.assignment_late,
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CallRegisterScreen()),
                          ),
                        ),
                        KpiCard(
                          title: 'Total Logged',
                          value: _totalCalls.toString(),
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CallRegisterScreen()),
                          ),
                        ),
                        KpiCard(
                          title: 'Active AMCs',
                          value: _activeAmc.toString(),
                          icon: Icons.verified_user,
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AmcReportScreen()),
                          ),
                        ),
                        KpiCard(
                          title: 'Job Sheets',
                          value: _jobSheetsCount.toString(),
                          icon: Icons.description,
                          color: const Color(0xFFC4032A),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JobSheetScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons List
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.white,
                      leading: CircleAvatar(
                        backgroundColor: _checkInStatus == null ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5),
                        child: Icon(
                          _checkInStatus == null ? Icons.camera_alt : Icons.logout,
                          color: _checkInStatus == null ? const Color(0xFFC4032A) : const Color(0xFF1E293B),
                        ),
                      ),
                      title: Text(
                        _checkInStatus == null ? 'Engineer Check-In' : 'End Duty / Check-Out',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _checkInStatus == null
                            ? 'Capture meter photo, geotag GPS, log attendance'
                            : 'Log evening meter photo, day total KM, and end shift',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        if (_checkInStatus == null) {
                          final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceCheckInScreen()));
                          if (res == true) _loadDashboardMetrics();
                        } else if (_checkInStatus!.status == 'Checked In') {
                          final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceCheckOutScreen(checkIn: _checkInStatus!)));
                          if (res == true) _loadDashboardMetrics();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.white,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF1F2),
                        child: Icon(Icons.add_call, color: Color(0xFFC4032A)),
                      ),
                      title: const Text('Log New Call Register', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Register new customer complaint or service request'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CallRegisterScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
