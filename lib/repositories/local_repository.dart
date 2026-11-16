import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_models.dart';

class LocalRepository {
  LocalRepository(this._box);
  final Box _box;
  Vehicle? get vehicle => _box.get('vehicle') == null ? null : Vehicle.fromJson(Map<String, dynamic>.from(_box.get('vehicle')));
  OilChange? get oil => _box.get('oil') == null ? null : OilChange.fromJson(Map<String, dynamic>.from(_box.get('oil')));
  PlateRestriction? get restriction => _box.get('restriction') == null ? null : PlateRestriction.fromJson(Map<String, dynamic>.from(_box.get('restriction')));
  List<BrakePadChange> get pads => _list('pads').map((e) => BrakePadChange.fromJson(Map<String,dynamic>.from(e))).toList();
  List<BrakeFluidChange> get fluid => _list('fluid').map((e) => BrakeFluidChange.fromJson(Map<String,dynamic>.from(e))).toList();
  List<OilChange> get oils {
    final saved = _list('oils').map((e) => OilChange.fromJson(Map<String,dynamic>.from(e))).toList();
    if (saved.isNotEmpty) return saved;
    final current = oil;
    return current == null ? [] : [current];
  }
  List<InspectionRecord> get inspections => _list('inspections').map((e) => InspectionRecord.fromJson(Map<String, dynamic>.from(e))).toList();
  List<ConsumptionProfile> get consumptionProfiles => _list('consumptionProfiles').map((e) => ConsumptionProfile.fromJson(Map<String, dynamic>.from(e))).toList();
  List<FuelLog> get fuelLogs => _list('fuelLogs').map((e) => FuelLog.fromJson(Map<String, dynamic>.from(e))).toList();
  List _list(String key) => List.from(_box.get(key, defaultValue: const []));
  Future<void> saveVehicle(Vehicle value) => _box.put('vehicle', value.toJson());
  Future<void> saveOil(OilChange value) => _box.put('oil', value.toJson());
  Future<void> saveOils(List<OilChange> value) => _box.put('oils', value.map((e)=>e.toJson()).toList());
  Future<void> saveRestriction(PlateRestriction value) => _box.put('restriction', value.toJson());
  Future<void> savePads(List<BrakePadChange> value) => _box.put('pads', value.map((e)=>e.toJson()).toList());
  Future<void> saveFluid(List<BrakeFluidChange> value) => _box.put('fluid', value.map((e)=>e.toJson()).toList());
  Future<void> saveInspections(List<InspectionRecord> value) => _box.put('inspections', value.map((e) => e.toJson()).toList());
  Future<void> saveConsumptionProfiles(List<ConsumptionProfile> value) => _box.put('consumptionProfiles', value.map((e) => e.toJson()).toList());
  Future<void> saveFuelLogs(List<FuelLog> value) => _box.put('fuelLogs', value.map((e) => e.toJson()).toList());
}
