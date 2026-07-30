import 'call_register.dart';

class EngineRouteSummary {
  final String startLocationName;
  final double startLat;
  final double startLng;
  final List<CallRegister> optimizedCalls;
  final double totalDistanceKm;
  final int totalEstimatedMinutes;
  final double estimatedFuelLiters;
  final double estimatedFuelCostInr;
  final DateTime routeGeneratedTime;
  final bool isOfflineCachedMode;

  EngineRouteSummary({
    required this.startLocationName,
    required this.startLat,
    required this.startLng,
    required this.optimizedCalls,
    required this.totalDistanceKm,
    required this.totalEstimatedMinutes,
    required this.estimatedFuelLiters,
    required this.estimatedFuelCostInr,
    required this.routeGeneratedTime,
    this.isOfflineCachedMode = false,
  });
}
