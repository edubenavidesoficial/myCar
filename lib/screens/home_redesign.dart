import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class RedesignedDashboard extends ConsumerWidget {
  const RedesignedDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final v = app.vehicle;
    if (v == null) return Center(child: FilledButton(onPressed: () => showVehicleForm(context), child: const Text('Registrar vehículo')));
    final pending = app.oil == null || app.oil!.currentMileage >= app.oil!.nextMileage;
    return CustomScrollView(slivers: [SliverToBoxAdapter(child: _Hero(vehicle: v)), SliverPadding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 110), sliver: SliverList(delegate: SliverChildListDelegate([const SizedBox(height: 14), const _Health(), const _Title('Accesos rápidos'), _Grid(pending: pending)])))]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.vehicle}); final Vehicle vehicle;
  @override
  Widget build(BuildContext context) => SizedBox(height: 405, child: Stack(children: [
    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(38)), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF123C43), Color(0xFF061A20), Color(0xFF031116)])))),
    Positioned(right: -35, bottom: -12, child: Icon(CupertinoIcons.car_detailed, size: 285, color: AppTheme.teal.withValues(alpha: .16))),
    Positioned(left: 20, right: 20, top: 22, child: Row(children: [RichText(text: const TextSpan(style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1.5), children: [TextSpan(text: 'my', style: TextStyle(color: Colors.white)), TextSpan(text: 'Car', style: TextStyle(color: AppTheme.teal))])), const Spacer(), const _Round(icon: CupertinoIcons.bell, badge: true), const SizedBox(width: 10), const _Round(icon: CupertinoIcons.gear_alt_fill)])),
    Positioned(left: 22, top: 100, right: 22, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(vehicle.brand.toUpperCase(), style: TextStyle(color: AppTheme.teal.withValues(alpha: .9), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)), const SizedBox(height: 5), Text(vehicle.label, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 10), Row(children: [const _Pill(icon: CupertinoIcons.settings, text: 'Manual'), const SizedBox(width: 8), const _Pill(icon: CupertinoIcons.speedometer, text: 'Motor por definir')])])),
    Positioned(left: 22, bottom: 25, child: _Mileage(value: vehicle.mileage)),
  ]));
}
class _Mileage extends StatelessWidget { const _Mileage({required this.value}); final int value; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11), decoration: BoxDecoration(color: const Color(0x553C7375), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.teal.withValues(alpha: .7))), child: Row(children: [const Icon(CupertinoIcons.speedometer, color: AppTheme.teal, size: 25), const SizedBox(width: 10), Text('${_km(value)} km', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(width: 12), const Icon(CupertinoIcons.chevron_right, color: AppTheme.teal)])); }
class _Round extends StatelessWidget { const _Round({required this.icon, this.badge = false}); final IconData icon; final bool badge; @override Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .12))), child: Icon(icon, color: Colors.white, size: 20)), if (badge) const Positioned(right: 1, top: 1, child: CircleAvatar(radius: 4, backgroundColor: AppTheme.teal))]); }
class _Pill extends StatelessWidget { const _Pill({required this.icon, required this.text}); final IconData icon; final String text; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .09), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: Colors.white70, size: 15), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))])); }
class _Health extends StatelessWidget { const _Health(); @override Widget build(BuildContext context) => _Glass(child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0x2522D873), borderRadius: BorderRadius.circular(15)), child: const Icon(CupertinoIcons.checkmark_shield_fill, color: Color(0xFF42E18A), size: 24)), const SizedBox(width: 13), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Estado del vehículo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Todo en orden por ahora', style: TextStyle(color: Color(0xFF9DB4B7), fontSize: 13))])), const Icon(CupertinoIcons.chevron_right, color: Colors.white54)])); }
class _Title extends StatelessWidget { const _Title(this.text); final String text; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800))); }
class _Grid extends StatelessWidget { const _Grid({required this.pending}); final bool pending; @override Widget build(BuildContext context) => GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.45, children: [const _Card(icon: CupertinoIcons.car_detailed, title: 'Mi vehículo', subtitle: 'Detalles y documentos'), _Card(icon: CupertinoIcons.wrench, title: 'Mantenimiento', subtitle: pending ? 'Servicio pendiente' : 'Todo al día', accent: pending ? Colors.orange : AppTheme.teal), const _Card(icon: CupertinoIcons.chart_bar_alt_fill, title: 'Historial', subtitle: 'Revisiones y gastos'), const _Card(icon: CupertinoIcons.speedometer, title: 'Consumo', subtitle: 'Rendimiento y costos')]); }
}
class _Card extends StatelessWidget { const _Card({required this.icon, required this.title, required this.subtitle, this.accent = AppTheme.teal}); final IconData icon; final String title, subtitle; final Color accent; @override Widget build(BuildContext context) => _Glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: accent, size: 25), const Spacer(), const Icon(CupertinoIcons.arrow_up_right, color: Colors.white54, size: 17)]), const Spacer(), Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF91A9AC), fontSize: 11))])); }
class _Glass extends StatelessWidget { const _Glass({required this.child}); final Widget child; @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(22), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF123138).withValues(alpha: .72), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: child))); }
String _km(int value) => value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (m) => '.');
