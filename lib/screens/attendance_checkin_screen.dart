import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_checkin.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';

class AttendanceCheckInScreen extends StatefulWidget {
  const AttendanceCheckInScreen({super.key});

  @override
  State<AttendanceCheckInScreen> createState() => _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  final String _engineerName = 'Rajesh Kumar (LG Tech ID: 4402)';
  final String _vehicleNumber = 'GJ-01-LG-3652 (Service Van)';
  final String _deviceId = 'IMEI-863901048821094';
  final double _latitude = 23.022512;
  final double _longitude = 72.571401;
  final int _batteryLevel = 88;
  final DateTime _now = DateTime.now();

  bool _isPhotoCaptured = false;
  bool _isAnalyzingOcr = false;
  bool _allowManualEdit = false;
  OcrResult? _ocrResult;
  final _kmController = TextEditingController();

  void _triggerCameraCapture() async {
    setState(() {
      _isAnalyzingOcr = true;
      _isPhotoCaptured = false;
      _allowManualEdit = false;
    });

    // Capture original raw photo & run AI OCR Engine
    const rawPhotoPath = 'raw_meter_photo_checkin_original_exif.jpg';
    final ocr = await OcrService().processSpeedometerImage(rawPhotoPath, isEvening: false);

    if (mounted) {
      setState(() {
        _isPhotoCaptured = true;
        _isAnalyzingOcr = false;
        _ocrResult = ocr;
        _kmController.text = ocr.detectedKm.toString(); // Auto-fill! No manual typing needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade800,
          content: Text('🤖 AI Speedometer Scan Complete! Auto-detected: ${ocr.detectedKm} KM (${ocr.confidenceScore}% Confidence). Original photo saved.'),
        ),
      );
    }
  }

  void _submitCheckIn() async {
    if (!_isPhotoCaptured || _ocrResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('⚠️ Mandatory: Please take Vehicle Speedometer photo using Camera first!'),
        ),
      );
      return;
    }

    final reading = int.tryParse(_kmController.text) ?? _ocrResult!.detectedKm;

    final checkIn = AttendanceCheckIn(
      checkInId: 'CHK-${DateTime.now().millisecondsSinceEpoch}',
      engineerName: _engineerName,
      vehicleNumber: _vehicleNumber,
      meterPhotoPath: _ocrResult!.originalPhotoPath, // Preservation of original photo
      meterReadingKm: reading,
      latitude: _latitude,
      longitude: _longitude,
      checkInTime: DateTime.now(),
      deviceId: _deviceId,
      batteryLevel: _batteryLevel,
      status: 'Checked In',
    );

    await ApiService().saveAttendanceCheckIn(checkIn);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade800,
          content: Text('✅ Check-In Logged! Morning Reading: $reading KM (Original Photo Archived).'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Engineer Check-In'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFFFF1F2),
                        child: Icon(Icons.person, color: Color(0xFFC4032A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_engineerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Vehicle: $_vehicleNumber', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(_now), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text('Battery: $_batteryLevel%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('GPS: $_latitude, $_longitude | Device: $_deviceId', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              '📷 Take Speedometer Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'AI auto-detects kilometer reading. Manual typing not required.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Camera Photo Container
            InkWell(
              onTap: _isAnalyzingOcr ? null : _triggerCameraCapture,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isPhotoCaptured ? Colors.grey.shade900 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPhotoCaptured ? Colors.green : const Color(0xFFC4032A),
                    width: 2,
                  ),
                ),
                child: _isAnalyzingOcr
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFFC4032A)),
                          SizedBox(height: 12),
                          Text('🤖 AI OCR Scanning Speedometer Photo...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : _isPhotoCaptured
                        ? Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.speed, size: 48, color: Colors.amber),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Auto-Detected: ${_ocrResult?.detectedKm} KM',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade800,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '🤖 AI Confidence: ${_ocrResult?.confidenceScore}% (Original Photo Saved)',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('ORIGINAL ARCHIVED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF1F2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Color(0xFFC4032A), size: 36),
                              ),
                              const SizedBox(height: 10),
                              const Text('Tap Camera to Take Speedometer Photo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC4032A))),
                              const SizedBox(height: 4),
                              const Text('Gallery disabled | Direct Camera only', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
              ),
            ),

            if (_isPhotoCaptured && _ocrResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                            SizedBox(width: 6),
                            Text('AI Speedometer Reading', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _allowManualEdit = !_allowManualEdit;
                            });
                          },
                          icon: Icon(_allowManualEdit ? Icons.lock : Icons.edit, size: 14),
                          label: Text(_allowManualEdit ? 'Lock Field' : 'Manual Correction', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _kmController,
                      enabled: _allowManualEdit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Kilometer Reading (Auto-Detected)',
                        suffixText: 'KM',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.speed, color: Colors.green),
                        fillColor: _allowManualEdit ? Colors.white : Colors.grey.shade100,
                        filled: true,
                        helperText: _allowManualEdit
                            ? 'Manual correction mode active.'
                            : 'Auto-filled by AI. Tap "Manual Correction" if incorrect.',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPhotoCaptured ? const Color(0xFFC4032A) : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitCheckIn,
                icon: const Icon(Icons.how_to_reg, color: Colors.white),
                label: const Text(
                  'CONFIRM & CHECK-IN NOW',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
