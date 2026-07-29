import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/amc_report.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/custom_search_bar.dart';

class AmcReportScreen extends StatefulWidget {
  const AmcReportScreen({super.key});

  @override
  State<AmcReportScreen> createState() => _AmcReportScreenState();
}

class _AmcReportScreenState extends State<AmcReportScreen> {
  List<AmcReport> _reports = [];
  List<AmcReport> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAmcReports();
  }

  Future<void> _loadAmcReports() async {
    final list = await ApiService().getAmcReports();
    setState(() {
      _reports = list;
      _filtered = list;
      _isLoading = false;
    });
  }

  void _filter(String text) {
    setState(() {
      _searchQuery = text;
      if (_searchQuery.isEmpty) {
        _filtered = _reports;
      } else {
        _filtered = _reports.where((r) {
          final q = _searchQuery.toLowerCase();
          return r.amcId.toLowerCase().contains(q) ||
              r.customerName.toLowerCase().contains(q) ||
              r.equipmentDetails.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('LG AMC Reports & Status'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search AMC ID, Customer, or Equipment...',
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
                : _filtered.isEmpty
                    ? const Center(child: Text('No AMC reports found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final amc = _filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        amc.amcId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFFC4032A),
                                        ),
                                      ),
                                      StatusBadge(status: amc.contractStatus),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    amc.customerName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    amc.equipmentDetails,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Valid: ${dateFormatter.format(amc.startDate)} - ${dateFormatter.format(amc.endDate)}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                      Text(
                                        currencyFormatter.format(amc.contractAmount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: amc.servicesCompleted / amc.totalServicesIncluded,
                                    backgroundColor: Colors.grey.shade200,
                                    color: const Color(0xFFC4032A),
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Preventive Maintenance Visits:',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      Text(
                                        '${amc.servicesCompleted} of ${amc.totalServicesIncluded} Done',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
