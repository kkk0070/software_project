import 'package:flutter/foundation.dart';

/// Possible states for an active ride
enum RideStatus { none, pending, accepted, started, completed, cancelled }

/// Holds the rider's current in-progress ride details so any widget in the
/// tree can show / react to the active ride (e.g. the floating status pill).
class ActiveRideProvider extends ChangeNotifier {
  RideStatus _status = RideStatus.none;
  int? _rideId;
  String _driverName = '';
  String _vehicleModel = '';
  String _vehicleType = '';
  String _licensePlate = '';
  int _etaMinutes = 5;
  String _pickupLocation = '';
  String _dropoffLocation = '';
  double _rating = 0;

  // ── Getters ────────────────────────────────────────────────────────────────
  RideStatus get status => _status;
  int? get rideId => _rideId;
  String get driverName => _driverName;
  String get vehicleModel => _vehicleModel;
  String get vehicleType => _vehicleType;
  String get licensePlate => _licensePlate;
  int get etaMinutes => _etaMinutes;
  String get pickupLocation => _pickupLocation;
  String get dropoffLocation => _dropoffLocation;
  double get rating => _rating;

  bool get hasActiveRide => _status != RideStatus.none;

  // ── Label helpers ──────────────────────────────────────────────────────────
  String get statusLabel {
    switch (_status) {
      case RideStatus.pending:
        return 'Looking for driver…';
      case RideStatus.accepted:
        return 'Driver is $_etaMinutes min away';
      case RideStatus.started:
        return 'Ride in progress';
      case RideStatus.completed:
        return 'Ride completed';
      case RideStatus.cancelled:
        return 'Ride cancelled';
      case RideStatus.none:
        return '';
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────────
  /// Called right after the rider taps "Book Ride" and the API confirms.
  void bookRide({
    required int rideId,
    required String driverName,
    required String vehicleModel,
    String vehicleType = '',
    String licensePlate = '',
    required String pickupLocation,
    required String dropoffLocation,
    double rating = 0,
  }) {
    _rideId = rideId;
    _driverName = driverName;
    _vehicleModel = vehicleModel;
    _vehicleType = vehicleType;
    _licensePlate = licensePlate;
    _pickupLocation = pickupLocation;
    _dropoffLocation = dropoffLocation;
    _rating = rating;
    _status = RideStatus.pending;
    _etaMinutes = 5;
    notifyListeners();
  }

  /// Called when the driver accepts the ride (e.g. via polling / push notification).
  void driverAccepted({int etaMinutes = 5}) {
    if (_status == RideStatus.pending) {
      _status = RideStatus.accepted;
      _etaMinutes = etaMinutes;
      notifyListeners();
    }
  }

  /// Update ETA while driver is on the way.
  void updateEta(int etaMinutes) {
    _etaMinutes = etaMinutes;
    notifyListeners();
  }

  /// Ride has started (driver picked up the rider).
  void rideStarted() {
    _status = RideStatus.started;
    notifyListeners();
  }

  /// Ride finished or cancelled — reset to no active ride.
  void clearRide() {
    _status = RideStatus.none;
    _rideId = null;
    _driverName = '';
    _vehicleModel = '';
    _vehicleType = '';
    _licensePlate = '';
    _pickupLocation = '';
    _dropoffLocation = '';
    _etaMinutes = 5;
    _rating = 0;
    notifyListeners();
  }
}
