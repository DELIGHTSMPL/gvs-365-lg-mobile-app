import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_sheet.dart';
import '../services/api_service.dart';

class JobSheetScreen extends StatefulWidget {
  const JobSheetScreen({super.key});

  @override
  State<JobSheetScreen> createState() => _JobSheetScreenState();
}

class _JobSheetScreenState extends State<JobSheetScreen> {
  List<JobSheet> _sheets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobSheets();
  }

  Future<void> _loadJobSheets() async {
    final list = await ApiService().getJobSheets();
    setState(() {
      _sheets = list;
      _isLoading = false;
    });
  }

  void _showNewJobSheetDialog() {
    final formKey = GlobalKey<FormState>();
    String callId = 'LG-2026-101';
    String customerName = 'Delight Electronics Ltd';
    String customerPhone = '+91 98765 43210';
    String equipmentModel = 'LG Inverter V-Multi Commercial VRF';
    String serialNumber = 'LGVRF2025-99881';
    String workDone = '';
    String partsReplacedStr = '';
    double totalCharges = 0.0;
    String techSig = 'Signed Digital';
    String customerSig = 'Signed Digital';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Digital Job Sheet'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: callId,
                    decoration: const InputDecoration(labelText: 'Call ID Reference'),
                    onSaved: (val) => callId = val!,
                  ),
                  TextFormField(
                    initialValue: customerName,
                    decoration: const InputDecoration(labelText: 'Customer Name'),
                    onSaved: (val) => customerName = val!,
                  ),
                  TextFormField(
                    initialValue: equipmentModel,
                    decoration: const InputDecoration(labelText: 'LG Model'),
                    onSaved: (val) => equipmentModel = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Work Done / Repairs Executed'),
                    maxLines: 2,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => workDone = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Replaced Parts (comma separated)'),
                    onSaved: (val) => partsReplacedStr = val ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Total Charges (₹)'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => totalCharges = double.tryParse(val ?? '0') ?? 0.0,
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
                  final newSheet = JobSheet(
                    jobSheetId: 'JS-2026-${_sheets.length + 101}',
                    callId: callId,
                    customerName: customerName,
                    customerPhone: customerPhone,
                    equipmentModel: equipmentModel,
                    serialNumber: serialNumber,
                    workDoneDetails: workDone,
                    replacedParts: partsReplacedStr.split(',').where((s) => s.trim().isNotEmpty).toList(),
                    totalCharges: totalCharges,
                    technicianSignature: techSig,
                    customerSignature: customerSig,
                    completionDate: DateTime.now(),
                  );
                  await ApiService().saveJobSheet(newSheet);
                  Navigator.pop(context);
                  _loadJobSheets();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job Sheet ${newSheet.jobSheetId} generated successfully!')),
                  );
                }
              },
              child: const Text('Generate Sheet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Digital Job Sheets'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewJobSheetDialog,
        backgroundColor: const Color(0xFFC4032A),
        icon: const Icon(Icons.note_add, color: Colors.white),
        label: const Text('Create Job Sheet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4032A)))
          : _sheets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No digital job sheets generated yet.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4032A)),
                        onPressed: _showNewJobSheetDialog,
                        child: const Text('Create First Job Sheet', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _sheets.length,
                  itemBuilder: (context, index) {
                    final sheet = _sheets[index];
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
                                  sheet.jobSheetId,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC4032A)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Text('Signed & Verified', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(sheet.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Equipment: ${sheet.equipmentModel}', style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                            const SizedBox(height: 8),
                            Text('Work Executed:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                            Text(sheet.workDoneDetails, style: const TextStyle(fontSize: 13)),
                            if (sheet.replacedParts.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('Parts Replaced: ${sheet.replacedParts.join(', ')}', style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
                            ],
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Amount:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                                Text(currencyFormatter.format(sheet.totalCharges), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
