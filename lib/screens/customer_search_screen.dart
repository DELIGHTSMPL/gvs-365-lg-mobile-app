import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/custom_search_bar.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  List<Customer> _customers = [];
  List<Customer> _filtered = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final list = await ApiService().getCustomers();
    setState(() {
      _customers = list;
      _filtered = list;
      _isLoading = false;
    });
  }

  void _onSearch(String text) {
    setState(() {
      _query = text;
      if (_query.isEmpty) {
        _filtered = _customers;
      } else {
        _filtered = _customers.where((c) {
          final q = _query.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
              c.phone.contains(q) ||
              c.city.toLowerCase().contains(q) ||
              c.serialNumber.toLowerCase().contains(q) ||
              c.lgEquipmentModel.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Customer Directory'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search Customer, Phone, Serial #, or Model...',
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
                : _filtered.isEmpty
                    ? const Center(child: Text('No customers found matching search.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final c = _filtered[index];
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
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      StatusBadge(status: 'AMC: ${c.amcStatus}'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_android, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(c.phone, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.phone, color: Colors.green),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Calling ${c.name} at ${c.phone}...')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Text(
                                    'Installed LG Equipment:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.lgEquipmentModel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('Serial #: ${c.serialNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${c.fullAddress}, ${c.city}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
