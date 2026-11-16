class Vehicle {
  const Vehicle({required this.brand, required this.model, required this.year, required this.mileage, required this.plateDigit, required this.transmission, this.version = ''});
  final String brand, model, version, transmission;
  final int year, mileage, plateDigit;
  String get label => '$brand $model $year';
  Map<String, dynamic> toJson() => {'brand': brand, 'model': model, 'version': version, 'year': year, 'mileage': mileage, 'plateDigit': plateDigit, 'transmission': transmission};
  factory Vehicle.fromJson(Map map) => Vehicle(brand: map['brand'], model: map['model'], version: map['version'] ?? '', year: map['year'], mileage: map['mileage'], plateDigit: map['plateDigit'], transmission: map['transmission']);
}

class VehicleSpecification {
  const VehicleSpecification({required this.engine, required this.fuel, required this.cylinders, required this.transmission});
  final String engine, fuel, cylinders, transmission;
  static VehicleSpecification? localFor(Vehicle v) => v.brand.toLowerCase() == 'toyota' && v.model.toLowerCase() == 'corolla' && v.year == 2022
      ? const VehicleSpecification(engine: '1.8 L', fuel: 'Gasolina', cylinders: '4', transmission: 'Automática') : null;
}

class OilChange {
  const OilChange({required this.currentMileage, required this.lastMileage, required this.interval, required this.date});
  final int currentMileage, lastMileage, interval;
  final DateTime date;
  int get nextMileage => lastMileage + interval;
  Map<String, dynamic> toJson() => {'current': currentMileage, 'last': lastMileage, 'interval': interval, 'date': date.toIso8601String()};
  factory OilChange.fromJson(Map map) => OilChange(currentMileage: map['current'], lastMileage: map['last'], interval: map['interval'], date: DateTime.parse(map['date']));
}

class BrakePadChange { const BrakePadChange({required this.date, required this.mileage, required this.review, this.notes = ''}); final DateTime date, review; final int mileage; final String notes; Map<String,dynamic> toJson()=>{'date':date.toIso8601String(),'mileage':mileage,'review':review.toIso8601String(),'notes':notes}; factory BrakePadChange.fromJson(Map map)=>BrakePadChange(date:DateTime.parse(map['date']),mileage:map['mileage'],review:DateTime.parse(map['review']),notes:map['notes']??''); }
class BrakeFluidChange { const BrakeFluidChange({required this.date, required this.review, this.mileage = 0, this.notes = ''}); final DateTime date, review; final int mileage; final String notes; Map<String,dynamic> toJson()=>{'date':date.toIso8601String(),'review':review.toIso8601String(),'mileage':mileage,'notes':notes}; factory BrakeFluidChange.fromJson(Map map)=>BrakeFluidChange(date:DateTime.parse(map['date']),review:DateTime.parse(map['review']),mileage:map['mileage']??0,notes:map['notes']??''); }
class MaintenanceRecord { const MaintenanceRecord({required this.title, required this.date, required this.mileage, this.notes = '', required this.type}); final String title, notes, type; final DateTime date; final int mileage; }
class InspectionRecord { const InspectionRecord({required this.zone, required this.date, required this.notes}); final String zone, notes; final DateTime date; Map<String, dynamic> toJson() => {'zone': zone, 'date': date.toIso8601String(), 'notes': notes}; factory InspectionRecord.fromJson(Map map) => InspectionRecord(zone: map['zone'], date: DateTime.parse(map['date']), notes: map['notes'] ?? ''); }
class PlateRestriction { const PlateRestriction({required this.digit, required this.day}); final int digit; final String day; Map<String, dynamic> toJson() => {'digit': digit, 'day': day}; factory PlateRestriction.fromJson(Map map) => PlateRestriction(digit: map['digit'], day: map['day']); }
class ConsumptionProfile { const ConsumptionProfile({required this.brand, required this.model, required this.kmPerLiter}); final String brand, model; final double kmPerLiter; Map<String, dynamic> toJson() => {'brand': brand, 'model': model, 'kmPerLiter': kmPerLiter}; factory ConsumptionProfile.fromJson(Map map) => ConsumptionProfile(brand: map['brand'], model: map['model'], kmPerLiter: (map['kmPerLiter'] as num).toDouble()); }
class FuelLog { const FuelLog({required this.date, required this.odometer, required this.liters, required this.route, this.totalCost}); final DateTime date; final int odometer; final double liters; final String route; final double? totalCost; Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'odometer': odometer, 'liters': liters, 'route': route, 'totalCost': totalCost}; factory FuelLog.fromJson(Map map) => FuelLog(date: DateTime.parse(map['date']), odometer: map['odometer'], liters: (map['liters'] as num).toDouble(), route: map['route'] ?? 'Mixto', totalCost: (map['totalCost'] as num?)?.toDouble()); }
