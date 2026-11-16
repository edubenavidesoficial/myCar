import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'oil_check_screen.dart';
import 'consumption_screen.dart';

class RedesignedDashboard extends ConsumerWidget {
  const RedesignedDashboard({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider), vehicle = app.vehicle;
    if (vehicle == null) return Center(child: FilledButton(onPressed: () => showVehicleForm(context), child: const Text('Registrar vehículo')));
    final pending = app.oil == null || app.oil!.currentMileage >= app.oil!.nextMileage;
    final consumption = _matchConsumption(vehicle, app.consumptionProfiles);
    return CustomScrollView(slivers: [SliverToBoxAdapter(child: _Hero(vehicle: vehicle, consumption: consumption, onNotifications: () => _showNotifications(context, app), onSettings: () => onNavigate(3))), SliverPadding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 118), sliver: SliverList(delegate: SliverChildListDelegate([
      const SizedBox(height: 10),
      Row(children: [const Expanded(child: _Health()), const SizedBox(width: 10), Expanded(child: _PriorityAction(pending: pending))]),
      const _SectionTitle('Acciones rápidas'), const _ActionGrid(),
      if (consumption != null) ...[
        const SizedBox(height: 14),
        _ConsumptionOverview(profile: consumption, logs: app.fuelLogs),
      ],
    ]))) ]);
  }
  ConsumptionProfile? _matchConsumption(Vehicle vehicle, List<ConsumptionProfile> custom) { final all = [...custom, ...ConsumptionScreen.catalog]; for (final p in all) { if (p.brand.toLowerCase() == vehicle.brand.toLowerCase() && p.model.toLowerCase() == vehicle.model.toLowerCase()) return p; } return null; }
  void _showNotifications(BuildContext context, AppController app) { final items = <_ActivityItem>[...app.inspections.map((i) => _ActivityItem('Inspección: ${i.zone}', 'Revisión visual guardada', i.date, CupertinoIcons.viewfinder)), ...app.oils.map((o) => _ActivityItem('Cambio de aceite', 'Registro actualizado', o.date, CupertinoIcons.drop_fill)), ...app.pads.map((p) => _ActivityItem('Pastillas de freno', 'Mantenimiento registrado', p.date, CupertinoIcons.wrench)), ...app.fluid.map((f) => _ActivityItem('Líquido de frenos', 'Mantenimiento registrado', f.date, CupertinoIcons.drop))]..sort((a, b) => b.date.compareTo(a.date)); showModalBottomSheet(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => _NotificationsSheet(items: items.take(8).toList())); }
}
class _Hero extends StatelessWidget { const _Hero({required this.vehicle, required this.consumption, required this.onNotifications, required this.onSettings}); final Vehicle vehicle; final ConsumptionProfile? consumption; final VoidCallback onNotifications, onSettings; @override Widget build(BuildContext context) => SizedBox(height: 285, child: Stack(children: [Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF14666D), Color(0xFF061A20)])))), Positioned(right: -28, bottom: -30, child: Icon(CupertinoIcons.car_detailed, size: 220, color: AppTheme.teal.withValues(alpha: .16))), Positioned(left: 20, right: 20, top: 20, child: Row(children: [const Text('myCar', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)), const Spacer(), _Round(icon: CupertinoIcons.bell, badge: true, onTap: onNotifications), const SizedBox(width: 8), _Round(icon: CupertinoIcons.gear_alt_fill, onTap: onSettings)])), Positioned(left: 22, top: 92, right: 22, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(vehicle.brand.toUpperCase(), style: TextStyle(color: AppTheme.teal.withValues(alpha: .9), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.8)), const SizedBox(height: 4), Text(vehicle.label, style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w500, letterSpacing: -.5)), const SizedBox(height: 8), Text('${vehicle.transmission} · ${_km(vehicle.mileage)} km', style: const TextStyle(color: Colors.white70, fontSize: 14))])), Positioned(left: 22, right: 22, bottom: 20, child: Row(children: [_Odometer(value: vehicle.mileage), if (consumption != null) ...[const SizedBox(width: 10), _AnimatedGauge(icon: CupertinoIcons.leaf_arrow_circlepath, value: consumption!.kmPerLiter, max: 20, suffix: 'km/L', decimals: 1)] ]))])); }
class _Health extends StatelessWidget { const _Health(); @override Widget build(BuildContext context) => _StatusCard(icon: CupertinoIcons.checkmark_circle_fill, color: const Color(0xFF42E18A), title: 'Estado', detail: 'Bajo control'); }
class _PriorityAction extends StatelessWidget { const _PriorityAction({required this.pending}); final bool pending; @override Widget build(BuildContext context) => _StatusCard(icon: pending ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.checkmark_circle_fill, color: pending ? Colors.orangeAccent : const Color(0xFF42E18A), title: pending ? 'Pendiente' : 'Sin pendientes', detail: pending ? 'Revisar aceite' : 'Todo al día'); }
class _StatusCard extends StatelessWidget { const _StatusCard({required this.icon, required this.color, required this.title, required this.detail}); final IconData icon; final Color color; final String title, detail; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(17), border: Border.all(color: color.withValues(alpha: .42))), child: Row(children: [Icon(icon, color: color, size: 22), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 2), Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color.withValues(alpha: .88), fontSize: 11, fontWeight: FontWeight.w600))]))])); }
class _SectionTitle extends StatelessWidget { const _SectionTitle(this.text); final String text; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 9), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))); }
class _ActionGrid extends StatelessWidget { const _ActionGrid(); @override Widget build(BuildContext context) => GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: 1.65, children: [_ActionCard(icon: CupertinoIcons.drop_fill, title: 'Aceite', subtitle: 'Analizar con cámara', onTap: () => openOilCheck(context)), _ActionCard(icon: CupertinoIcons.speedometer, title: 'Consumo', subtitle: 'Estimación por modelo', onTap: () => openConsumption(context))]); }
class _ActionCard extends StatelessWidget { const _ActionCard({required this.icon, required this.title, required this.subtitle, this.onTap}); final IconData icon; final String title, subtitle; final VoidCallback? onTap; @override Widget build(BuildContext context) => _Glass(onTap: onTap, child: Row(children: [Icon(icon, color: onTap == null ? Colors.white38 : AppTheme.teal, size: 22), const SizedBox(width: 9), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: onTap == null ? Colors.white54 : Colors.white, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 3), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF91A9AC), fontSize: 10))]))])); }
class _Glass extends StatelessWidget { const _Glass({required this.child, this.onTap}); final Widget child; final VoidCallback? onTap; @override Widget build(BuildContext context) { final box = ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFF123138).withValues(alpha: .78), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .09))), child: child))); return onTap == null ? box : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: box); } }
class _AnimatedGauge extends StatelessWidget {
  const _AnimatedGauge({required this.icon, required this.value, required this.max, required this.suffix, required this.decimals});
  final IconData icon;
  final double value, max;
  final String suffix;
  final int decimals;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: const Duration(milliseconds: 1100),
    curve: Curves.easeOutCubic,
    builder: (context, current, _) {
      final progress = (current / max).clamp(0.0, 1.0);
      final displayed = decimals == 0 ? _km(current.round()) : current.toStringAsFixed(decimals);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(color: const Color(0x553C7375), borderRadius: BorderRadius.circular(17), border: Border.all(color: AppTheme.teal.withValues(alpha: .8))),
        child: Row(children: [
          SizedBox(width: 29, height: 29, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress, strokeWidth: 3, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(AppTheme.teal)), Icon(icon, color: AppTheme.teal, size: 13)])),
          const SizedBox(width: 8),
          Text('$displayed $suffix', style: TextStyle(color: Colors.white, fontSize: decimals == 0 ? 16 : 14, fontWeight: FontWeight.w800)),
        ]),
      );
    },
  );
}
class _Odometer extends StatelessWidget { const _Odometer({required this.value}); final int value; @override Widget build(BuildContext context) => TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: value.toDouble()), duration: const Duration(milliseconds: 1100), curve: Curves.easeOutCubic, builder: (context, current, _) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: const Color(0x553C7375), borderRadius: BorderRadius.circular(17), border: Border.all(color: AppTheme.teal.withValues(alpha: .8))), child: Row(children: [const Icon(CupertinoIcons.speedometer, color: AppTheme.teal, size: 21), const SizedBox(width: 8), Text('${_km(current.round())} km', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))]))); }
class _ConsumptionOverview extends StatelessWidget {
  const _ConsumptionOverview({required this.profile, required this.logs});
  final ConsumptionProfile profile;
  final List<FuelLog> logs;
  @override
  Widget build(BuildContext context) {
    final ordered = [...logs]..sort((a, b) => a.odometer.compareTo(b.odometer));
    final real = <double>[];
    for (var i = 1; i < ordered.length; i++) { final distance = ordered[i].odometer - ordered[i - 1].odometer; if (distance > 0) real.add(distance / ordered[i].liters); }
    final actual = real.isEmpty ? profile.kmPerLiter : real.reduce((a, b) => a + b) / real.length;
    final values = [actual * .82, actual, actual * 1.12];
    final max = values.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      decoration: BoxDecoration(color: const Color(0xFF123138).withValues(alpha: .78), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .09))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(CupertinoIcons.chart_bar_fill, color: AppTheme.teal, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Rango estimado por tipo de recorrido', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
          Text(real.isEmpty ? '${actual.toStringAsFixed(1)} km/L estimado' : '${actual.toStringAsFixed(1)} km/L real', style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w800, fontSize: 12)),
        ]),
        const SizedBox(height: 15),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(3, (i) => Expanded(child: Padding(
          padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
          child: Column(children: [
            SizedBox(height: 92 * (values[i] / max), child: Container(decoration: BoxDecoration(color: i == 1 ? AppTheme.teal : AppTheme.teal.withValues(alpha: .45), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))))),
            const SizedBox(height: 6),
            Text(['Ciudad', 'Mixto', 'Carretera'][i], style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(values[i].toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          ]),
        )))),
        const SizedBox(height: 7),
        Text(real.isEmpty ? 'Estimación orientativa; registra cargas para obtener datos reales.' : 'Basado en ${real.length} mediciones reales.', style: const TextStyle(color: Color(0xFF91A9AC), fontSize: 11)),
      ]),
    );
  }
}
class _Round extends StatelessWidget { const _Round({required this.icon, this.badge = false, this.onTap}); final IconData icon; final bool badge; final VoidCallback? onTap; @override Widget build(BuildContext context) { final child=Stack(clipBehavior: Clip.none, children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .12))), child: Icon(icon, color: Colors.white, size: 18)), if (badge) const Positioned(right: 0, top: 0, child: CircleAvatar(radius: 4, backgroundColor: AppTheme.teal))]); return InkWell(onTap: onTap, customBorder: const CircleBorder(), child: child); } }
class _ActivityItem { const _ActivityItem(this.title, this.detail, this.date, this.icon); final String title, detail; final DateTime date; final IconData icon; }
class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({required this.items});
  final List<_ActivityItem> items;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Actividad reciente', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Tus registros y revisiones más recientes'),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Todavía no hay actividad registrada.')))
        else
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppTheme.teal.withValues(alpha: .15), child: Icon(item.icon, color: AppTheme.teal, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)), Text(item.detail, style: Theme.of(context).textTheme.bodySmall)])),
              Text('${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.labelSmall),
            ]),
          )),
      ]),
    ),
  );
}
String _km(int value) => value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (m) => '.');
