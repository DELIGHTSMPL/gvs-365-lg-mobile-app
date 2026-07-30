import 'dart:math';
import '../models/call_register.dart';
import '../models/route_point.dart';

class RouteOptimizationService {
  static final RouteOptimizationService _instance = RouteOptimizationService._internal();
  factory RouteOptimizationService() => _instance;
  RouteOptimizationService._internal();

  // Fuel & Expense Constants
  static const double fuelMileageKmPerLiter = 15.0;
  static const double fuelRatePerLiterInr = 96.50;

  /// Calculates Haversine distance in KM between two (Lat, Lng) points
  double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Calculates Priority Score for a Call based on rules:
  /// - Emergency Complaint = +100
  /// - AMC Visit = +80
  /// - Installation = +60
  /// - Demo = +40
  /// - Preventive Service = +20
  /// - Preferred 10 AM Time Slot = +200 (Highest Priority boost)
  /// - Distance factor penalty offset
  double calculatePriorityScore(CallRegister call, double currentLat, double currentLng) {
    double score = 0.0;

    // 1. Service Type Priority
    final type = call.serviceType.trim().toLowerCase();
    if (type.contains('emergency')) {
      score += 100.0;
    } else if (type.contains('amc')) {
      score += 80.0;
    } else if (type.contains('installation')) {
      score += 60.0;
    } else if (type.contains('demo')) {
      score += 40.0;
    } else if (type.contains('preventive')) {
      score += 20.0;
    } else {
      score += 30.0;
    }

    // 2. Strict Customer Time Slot Preference
    final slot = call.timeSlot.trim().toLowerCase();
    if (slot.contains('10:00 am') || slot.contains('10 am')) {
      score += 200.0; // Ensures 10 AM slot customer is visited first!
    } else if (slot.contains('11:00 am') || slot.contains('11 am')) {
      score += 120.0;
    } else if (slot.contains('12:00 pm') || slot.contains('12 pm')) {
      score += 90.0;
    }

    // 3. Distance Penalty Offset (Closer calls get slight score advantage)
    final distanceKm = calculateHaversineDistance(currentLat, currentLng, call.latitude, call.longitude);
    score -= (distanceKm * 2.0);

    return score;
  }

  /// Optimizes a list of calls using Priority Score + Traveling Salesperson Heuristic
  EngineRouteSummary optimizeRoute({
    required List<CallRegister> calls,
    required double startLat,
    required double startLng,
    String startLocationName = 'LG Regional Depot (Ahmedabad Hub)',
  }) {
    List<CallRegister> remaining = List.from(calls.where((c) => c.status != 'Completed'));
    List<CallRegister> completed = List.from(calls.where((c) => c.status == 'Completed'));
    List<CallRegister> orderedRoute = [];

    double currLat = startLat;
    double currLng = startLng;
    double totalDistanceKm = 0.0;
    int totalTravelMinutes = 0;

    while (remaining.isNotEmpty) {
      // Rank all remaining calls by Priority Score from current position
      remaining.sort((a, b) {
        final scoreA = calculatePriorityScore(a, currLat, currLng);
        final scoreB = calculatePriorityScore(b, currLat, currLng);
        return scoreB.compareTo(scoreA); // Highest score first
      });

      final nextCall = remaining.removeAt(0);

      // Distance & Traffic calculation
      final distKm = double.parse(
          calculateHaversineDistance(currLat, currLng, nextCall.latitude, nextCall.longitude)
              .toStringAsFixed(1));
      
      // Simulate traffic ETA (2.5 mins per KM + 3 min buffer for signal/traffic)
      final trafficMins = (distKm * 2.5 + 3).round();
      final trafficEtaText = '$trafficMins mins (${distKm > 5 ? 'Moderate Traffic' : 'Clear Route'})';

      final score = calculatePriorityScore(nextCall, currLat, currLng);

      final updatedCall = nextCall.copyWith(
        distanceKm: distKm,
        trafficEta: trafficEtaText,
        priorityScore: double.parse(score.toStringAsFixed(1)),
      );

      orderedRoute.add(updatedCall);
      totalDistanceKm += distKm;
      totalTravelMinutes += trafficMins;

      currLat = nextCall.latitude;
      currLng = nextCall.longitude;
    }

    // Append completed calls at end of list
    orderedRoute.addAll(completed);

    // Fuel expense estimation
    final fuelLiters = double.parse((totalDistanceKm / fuelMileageKmPerLiter).toStringAsFixed(2));
    final fuelCostInr = double.parse((fuelLiters * fuelRatePerLiterInr).toStringAsFixed(2));

    return EngineRouteSummary(
      startLocationName: startLocationName,
      startLat: startLat,
      startLng: startLng,
      optimizedCalls: orderedRoute,
      totalDistanceKm: double.parse(totalDistanceKm.toStringAsFixed(1)),
      totalEstimatedMinutes: totalTravelMinutes,
      estimatedFuelLiters: fuelLiters,
      estimatedFuelCostInr: fuelCostInr,
      routeGeneratedTime: DateTime.now(),
    );
  }
}
