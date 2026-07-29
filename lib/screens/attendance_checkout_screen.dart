import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_checkin.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';

class AttendanceCheckOutScreen extends StatefulWidget {
  final AttendanceCheckIn checkIn;

  const AttendanceCheckOutScreen({super.key, required this.checkIn});

  @override
  State<AttendanceCheckOutScreen> createState() => _AttendanceCheckOutScreenState();
}

class _AttendanceCheckOutScreenState extends State<AttendanceCheckOutScreen> {
  final double _latitude = 23.022588;
  final double _longitude = 72.571490;
  final int _batteryLevel = 42;

  bool _isPhotoCaptured = false;
  bool _isAnalyzingOcr = false;
  bool _allowManualEdit = false;
  OcrResult? _ocrResult;
  final _kmController = TextEditingController();
  final _remarksController = TextEditingController(text: 'All assigned customer calls serviced. Vehicle in good condition.');

  void _triggerCameraCapture() async {
    setState(() {
      _isAnalyzingOcr = true;
      _isPhotoCaptured = false;
      _allowManualEdit = false;
    });

    const rawPhotoPath = 'raw_meter_photo_checkout_original_exif.jpg';
    final ocr = await OcrService().processSpeedometerImage(rawPhotoPath, isEvening: true);

    if (mounted) {
      setState(() {
        _isPhotoCaptured = true;
        _isAnalyzingOcr = false;
        _ocrResult = ocr;
        _kmController.text = ocr.detectedKm.toString(); // Auto-filled!
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue.shade900,
          content: Text('🤖 AI Evening Scan Complete! Auto-detected: ${ocr.detectedKm} KM. Original photo saved.'),
        ),
      );
    }
  }

  void _submitCheckOut() async {
    if (!_isPhotoCaptured || _ocrResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('⚠️ Mandatory: Please take Evening Speedometer photo using Camera first!'),
        ),
      );
      return;
    }

    final eveningKm = int.tryParse(_kmController.text) ?? _ocrResult!.detectedKm;
    final totalDayKm = eveningKm - widget.checkIn.meterReadingKm;

    final updatedCheckIn = AttendanceCheckIn(
      checkInId: widget.checkIn.checkInId,
      engineerName: widget.checkIn.engineerName,
      vehicleNumber: widget.checkIn.vehicleNumber,
      meterPhotoPath: _ocrResult!.originalPhotoPath, // Original photo archived
      meterReadingKm: eveningKm,
      latitude: _latitude,
      longitude: _longitude,
      checkInTime: widget.checkIn.checkInTime,
      deviceId: widget.checkIn.deviceId,
      batteryLevel: _batteryLevel,
      status: 'Checked Out',
    );

    await ApiService().saveAttendanceCheckIn(updatedCheckIn);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue.shade900,
          content: Text('✅ Check-Out Complete! Total Day Distance: $totalDayKm KM.'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy, hh:mm a');
    final eveningKm = int.tryParse(_kmController.text) ?? (_ocrResult?.detectedKm ?? widget.checkIn.meterReadingKm);
    final totalKmTraveled = eveningKm > widget.checkIn.meterReadingKm ? (eveningKm - widget.checkIn.meterReadingKm) : 0;
    final dutyHours = DateTime.now().difference(widget.checkIn.checkInTime).inHours;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('End Duty / Check-Out'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Morning Start Card
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
                  const Text('Morning Start Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Check-In Time:', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      Text(dateFormat.format(widget.checkIn.checkInTime), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start Odometer Reading:', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      Text('${widget.checkIn.meterReadingKm} KM', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              '📷 Take Evening Speedometer Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'AI auto-detects evening kilometer reading. Manual typing not required.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Camera Container
            InkWell(
              onTap: _isAnalyzingOcr ? null : _triggerCameraCapture,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isPhotoCaptured ? Colors.grey.shade900 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPhotoCaptured ? Colors.green : const Color(0xFF1E293B),
                    width: 2,
                  ),
                ),
                child: _isAnalyzingOcr
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFF1E293B)),
                          SizedBox(height: 12),
                          Text('🤖 AI OCR Scanning Evening Speedometer...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : _isPhotoCaptured
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, size: 48, color: Colors.green),
                              const SizedBox(height: 6),
                              Text('Evening AI Detected: ${_ocrResult?.detectedKm} KM', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('🤖 AI Confidence: ${_ocrResult?.confidenceScore}% (Original Photo Saved)', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, color: Color(0xFF1E293B), size: 36),
                              SizedBox(height: 8),
                              Text('Tap Camera to Take Evening Speedometer Photo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            ],
                          ),
              ),
            ),

            if (_isPhotoCaptured && _ocrResult != null) ...[
              const SizedBox(height: 20),
              // Daily Traveled KM Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Distance Traveled Today:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('$totalKmTraveled KM', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duty Hours Logged:', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        Text('$dutyHours Hours', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Evening Kilometer Reading', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              const SizedBox(height: 4),
              TextFormField(
                controller: _kmController,
                enabled: _allowManualEdit,
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Evening Reading (Auto-Detected)',
                  suffixText: 'KM',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.speed),
                  fillColor: _allowManualEdit ? Colors.white : Colors.grey.shade100,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarksController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Day Work Summary / Remarks',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
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
                  backgroundColor: _isPhotoCaptured ? const Color(0xFF1E293B) : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitCheckOut,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'CONFIRM CHECK-OUT & END DUTY',
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
