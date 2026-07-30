import 'package:flutter/material.dart';
import '../models/call_register.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/custom_search_bar.dart';
import 'customer_visit_screen.dart';
import 'route_optimization_screen.dart';

class CallRegisterScreen extends StatefulWidget {
  const CallRegisterScreen({super.key});

  @override
  State<CallRegisterScreen> createState() => _CallRegisterScreenState();
}

class _CallRegisterScreenState extends State<CallRegisterScreen> {
  List<CallRegister> _allCalls = [];
  List<CallRegister> _filteredCalls = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _loadCalls() async {
    final calls = await ApiService().getCallRegister();
    setState(() {
      _allCalls = calls;
      _filterCalls();
      _isLoading = false;
    });
  }

  void _filterCalls() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredCalls = List.from(_allCalls);
      } else {
        _filteredCalls = _allCalls.where((c) {
          return c.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.callId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.equipmentModel.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.technicianName.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  void _showNewCallDialog() {
    final formKey = GlobalKey<FormState>();
    String customerName = '';
    String contactNumber = '';
    String address = '';
    String equipmentModel = '';
    String issue = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log New LG Call Register'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Customer / Business Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => customerName = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => contactNumber = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Address'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => address = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'LG Equipment Model'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => equipmentModel = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Issue / Complaint Description'),
                    maxLines: 2,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => issue = val!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4032A)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newCall = CallRegister(
                    callId: 'LG-2026-${100 + _allCalls.length + 1}',
                    customerName: customerName,
                    contactNumber: contactNumber,
                    address: address,
                    equipmentModel: equipmentModel,
                    issueDescription: issue,
                    status: 'Pending',
                    priority: 'High',
                    callDate: DateTime.now(),
                    technicianName: 'Pending Dispatch',
                  );
                  await ApiService().addCallRegister(newCall);
                  Navigator.pop(context);
                  _loadCalls();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Call ${newCall.callId} logged successfully!')),
                  );
                }
              },
              child: const Text('Submit Call', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('LG Call Register'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route),
            tooltip: 'Optimize Route Today',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RouteOptimizationScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewCallDialog,
        backgroundColor: const Color(0xFFC4032A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search Call ID, Customer, Model, or Tech...',
              onChanged: (val) {
                _searchQuery = val;
                _filterCalls();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
                : _filteredCalls.isEmpty
                    ? const Center(child: Text('No call registers found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filteredCalls.length,
                        itemBuilder: (context, index) {
                          final call = _filteredCalls[index];
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
                                        call.callId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFC4032A),
                                        ),
                                      ),
                                      StatusBadge(status: call.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    call.customerName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(call.contactNumber, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.build, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          call.equipmentModel,
                                          style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline, size: 14, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            call.issueDescription,
                                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFFC4032A),
                                          side: const BorderSide(color: Color(0xFFC4032A)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => CustomerVisitScreen(call: call)),
                                          );
                                        },
                                        icon: const Icon(Icons.pin_drop, size: 16),
                                        label: const Text('Duty Visit (Arrival/Departure)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (newStatus) async {
                                          await ApiService().updateCallStatus(call.callId, newStatus);
                                          _loadCalls();
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'Pending', child: Text('Mark Pending')),
                                          const PopupMenuItem(value: 'In-Progress', child: Text('Mark In-Progress')),
                                          const PopupMenuItem(value: 'Completed', child: Text('Mark Completed')),
                                        ],
                                        child: Row(
                                          children: const [
                                            Text('Change Status', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                                            Icon(Icons.arrow_drop_down, color: Colors.blue),
                                          ],
                                        ),
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
