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
    if (v == null) return _NewCar(onStart: () => showVehicleForm(context));
    final oil = app.oil;
    final pending = oil == null || oil.currentMileage >= oil.nextMileage;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Hero(vehicle: v)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 112),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Transform.translate(offset: const Offset(0, -18), child: _VehicleStatus()),
            const SizedBox(height: 4),
            GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 22, crossAxisSpacing: 22, childAspectRatio: .84, children: [
              _Metric(icon: CupertinoIcons.calendar, label: 'PICO Y PLACA', value: app.restriction?.day ?? 'Configurar'),
              _Metric(icon: CupertinoIcons.speedometer, label: 'KILOMETRAJE', value: _kilometers(v.mileage)),
              _Metric(icon: CupertinoIcons.drop_fill, label: 'ACEITE', value: pending ? 'Pendiente' : 'Al día', subtitle: pending ? 'Próximo: —' : 'Próximo: ${oil.nextMileage} km', warning: pending),
              const _Metric(icon: CupertinoIcons.wrench, label: 'FRENOS', value: 'Revisión:', subtitle: '15/12/2026'),
            ]),
            const SizedBox(height: 24),
            _NextMaintenance(pending: pending),
          ])),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.vehicle}); final Vehicle vehicle;
  @override Widget build(BuildContext context) => SizedBox(height: 680, child: Stack(clipBehavior: Clip.none, children: [
    Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(.7, -.5), radius: 1.25, colors: [Color(0xFF177D80), Color(0xFF033238), Color(0xFF001A20)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(110))),),
    Positioned.fill(child: Opacity(opacity: .27, child: DecoratedBox(decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(110)), border: Border.all(color: const Color(0xFF73F2EA), width: .7))))),
    Positioned(left: 30, top: 30, child: Text('my', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -3))),
    Positioned(left: 138, top: 30, child: Text('Car', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF42E5D7), fontWeight: FontWeight.w800, letterSpacing: -3))),
    Positioned(right: 34, top: 42, child: Icon(CupertinoIcons.gear_alt_fill, color: Colors.white.withValues(alpha: .9), size: 37)),
    Positioned(left: 32, top: 145, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(vehicle.label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('${vehicle.transmission} · Motor por definir', style: const TextStyle(color: Color(0xFFD7E3E5), fontSize: 19)), const SizedBox(height: 24), Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: const Color(0x332C6971), border: Border.all(color: const Color(0x5577BFC3)), borderRadius: BorderRadius.circular(30)), child: Text('◌  ${_kilometers(vehicle.mileage)}', style: const TextStyle(color: Colors.white, fontSize: 18)))])),
    Positioned(right: -18, top: 100, width: 530, height: 590, child: Image.asset('assets/images/futuristic_engine.png', fit: BoxFit.contain, alignment: Alignment.bottomCenter)),
    Positioned(left: 32, top: 360, child: Container(width: 305, padding: const EdgeInsets.fromLTRB(36, 27, 20, 26), decoration: BoxDecoration(color: const Color(0xAA073C42), border: Border.all(color: const Color(0x9951D6CC)), borderRadius: BorderRadius.circular(36)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tu motor,', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)), Text('siempre listo', style: TextStyle(color: Color(0xFF6FF5EA), fontSize: 28, fontWeight: FontWeight.w700)), SizedBox(height: 18), SizedBox(width: 90, child: Divider(color: Color(0xFF56E5D9), thickness: 8))]))),
  ]));
}

class _VehicleStatus extends StatelessWidget { @override Widget build(BuildContext context) => Container(height: 118, padding: const EdgeInsets.symmetric(horizontal: 24), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(34), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 24)]), child: Row(children: [const CircleAvatar(radius: 29, backgroundColor: Color(0xFFE0F9F6), child: Icon(CupertinoIcons.waveform_path_ecg, color: Color(0xFF008D86), size: 29)), const SizedBox(width: 18), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Estado del vehículo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)), SizedBox(height: 5), Text('Todo en orden por ahora', style: TextStyle(color: Color(0xFF64727B), fontSize: 16))])), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: const Color(0xFFE1F9F4), borderRadius: BorderRadius.circular(24)), child: const Row(children: [Icon(CupertinoIcons.circle_fill, color: Color(0xFF19B941), size: 17), SizedBox(width: 8), Text('Bueno', style: TextStyle(color: Color(0xFF008D86), fontWeight: FontWeight.w700, fontSize: 17))])), const SizedBox(width: 14), const Icon(CupertinoIcons.chevron_right)])); }
class _Metric extends StatelessWidget { const _Metric({required this.icon,required this.label,required this.value,this.subtitle,this.warning=false}); final IconData icon; final String label,value; final String? subtitle; final bool warning; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(34)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[CircleAvatar(backgroundColor:const Color(0xFFE4F9F6),child:Icon(icon,color:warning?Colors.deepOrange:AppTheme.teal)),const Spacer(),const Icon(CupertinoIcons.chevron_right)]),const Spacer(),Text(label),const SizedBox(height:7),Text(value,style:TextStyle(fontSize:25,fontWeight:FontWeight.w800,color:warning?Colors.deepOrange:null)),if(subtitle!=null) Text(subtitle!,style:const TextStyle(color:Color(0xFF61717C),fontSize:16))])); }
class _NextMaintenance extends StatelessWidget { const _NextMaintenance({required this.pending}); final bool pending; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(34)),child:Column(children:[const Row(children:[CircleAvatar(backgroundColor:Color(0xFFE4F9F6),child:Icon(CupertinoIcons.clock,color:AppTheme.teal)),SizedBox(width:14),Expanded(child:Text('Próximo mantenimiento',style:TextStyle(fontWeight:FontWeight.w800,fontSize:20))),Text('Ver todo',style:TextStyle(color:AppTheme.teal)),Icon(CupertinoIcons.chevron_right,color:AppTheme.teal)]),const SizedBox(height:18),_service(CupertinoIcons.drop_fill,'Cambio de aceite',pending?'Vencido':'Próximamente',pending),const SizedBox(height:12),_service(CupertinoIcons.wrench,'Pastillas de freno','Revisión el 15/12/2026',false)])); Widget _service(IconData i,String t,String s,bool bad)=>ListTile(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)),tileColor:bad?const Color(0xFFFFF0EB):const Color(0xFFF0FBF9),leading:Icon(i,color:bad?Colors.deepOrange:AppTheme.teal),title:Text(t,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(s,style:TextStyle(color:bad?Colors.deepOrange:null)),trailing:const Icon(CupertinoIcons.chevron_right)); }
class _NewCar extends StatelessWidget { const _NewCar({required this.onStart}); final VoidCallback onStart; @override Widget build(BuildContext context)=>Center(child:FilledButton(onPressed:onStart,child:const Text('Registra tu vehículo'))); }
String _kilometers(int value)=>'${value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'),(m)=>'.')} km';
