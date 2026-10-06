import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class RedesignedDashboard extends ConsumerWidget {
  const RedesignedDashboard({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final app=ref.watch(appProvider); final vehicle=app.vehicle;
    if(vehicle==null)return Center(child:FilledButton(onPressed:()=>showVehicleForm(context),child:const Text('Registrar vehículo')));
    final oil=app.oil; final pending=oil==null||oil.currentMileage>=oil.nextMileage;
    return CustomScrollView(slivers:[SliverToBoxAdapter(child:_Hero(vehicle:vehicle)),SliverPadding(padding:const EdgeInsets.fromLTRB(20,0,20,110),sliver:SliverList(delegate:SliverChildListDelegate([
      Transform.translate(offset:const Offset(0,-18),child:const _HealthCard()),
      GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:14,crossAxisSpacing:14,childAspectRatio:.94,children:[
        _Metric(icon:CupertinoIcons.calendar,label:'PICO Y PLACA',value:app.restriction?.day??'Configurar'),
        _Metric(icon:CupertinoIcons.speedometer,label:'KILOMETRAJE',value:_km(vehicle.mileage)),
        _Metric(icon:CupertinoIcons.drop_fill,label:'ACEITE',value:pending?'Pendiente':'Al día',detail:pending?'Próximo: —':'Próximo: ${oil.nextMileage} km',warning:pending),
        const _Metric(icon:CupertinoIcons.wrench,label:'FRENOS',value:'Revisión',detail:'15/12/2026'),
      ]),const SizedBox(height:18),_Maintenance(pending:pending),
    ])))]);
  }
}

class _Hero extends StatelessWidget { const _Hero({required this.vehicle}); final Vehicle vehicle;
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,box){final width=box.maxWidth;return SizedBox(height:560,child:Stack(clipBehavior:Clip.hardEdge,children:[
    Container(decoration:const BoxDecoration(gradient:RadialGradient(center:Alignment(.7,-.6),radius:1.3,colors:[Color(0xFF178986),Color(0xFF033B40),Color(0xFF001E24)]),borderRadius:BorderRadius.vertical(bottom:Radius.circular(58)))),
    Positioned(left:24,top:30,child:RichText(text:TextSpan(style:const TextStyle(fontSize:48,fontWeight:FontWeight.w800,letterSpacing:-3),children:[const TextSpan(text:'my',style:TextStyle(color:Colors.white)),TextSpan(text:'Car',style:TextStyle(color:AppTheme.teal))]))),
    const Positioned(right:24,top:38,child:Icon(CupertinoIcons.gear_alt_fill,color:Colors.white,size:34)),
    Positioned(left:24,right:20,top:120,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(vehicle.label,style:const TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w800),maxLines:1,overflow:TextOverflow.ellipsis),const SizedBox(height:6),Text('${vehicle.transmission} · Motor por definir',style:const TextStyle(color:Color(0xFFD6E7E8),fontSize:17)),const SizedBox(height:16),Container(padding:const EdgeInsets.symmetric(horizontal:15,vertical:8),decoration:BoxDecoration(color:const Color(0x44346E71),borderRadius:BorderRadius.circular(22),border:Border.all(color:const Color(0x5568C8C8))),child:Text('◌  ${_km(vehicle.mileage)}',style:const TextStyle(color:Colors.white,fontSize:17)))])),
    Positioned(right:-width*.10,top:170,width:width*1.18,height:390,child:Image.asset('assets/images/futuristic_engine.png',fit:BoxFit.contain,alignment:Alignment.bottomRight)),
    Positioned(left:24,bottom:38,child:Container(width:width*.60,padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xBD073D43),border:Border.all(color:const Color(0xAA54D7CF)),borderRadius:BorderRadius.circular(28)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Tu motor,',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w800)),Text('siempre listo',style:TextStyle(color:Color(0xFF68F0E3),fontSize:25,fontWeight:FontWeight.w800)),SizedBox(height:12),SizedBox(width:82,child:Divider(color:Color(0xFF65EBDD),thickness:7))]))),
  ]));}); }
class _HealthCard extends StatelessWidget { const _HealthCard(); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(30),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.07),blurRadius:20)]),child:const Row(children:[CircleAvatar(radius:25,backgroundColor:Color(0xFFE2F9F6),child:Icon(CupertinoIcons.waveform_path_ecg,color:AppTheme.teal)),SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[Text('Estado del vehículo',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),SizedBox(height:4),Text('Todo en orden por ahora',style:TextStyle(color:Color(0xFF64727B),fontSize:14))])),Icon(CupertinoIcons.check_mark_circled_solid,color:Color(0xFF18B851))])); }
class _Metric extends StatelessWidget { const _Metric({required this.icon,required this.label,required this.value,this.detail,this.warning=false}); final IconData icon;final String label,value;final String? detail;final bool warning;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(30)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[CircleAvatar(backgroundColor:warning?const Color(0xFFFFECE3):const Color(0xFFE2F9F6),child:Icon(icon,color:warning?Colors.deepOrange:AppTheme.teal)),const Spacer(),const Icon(CupertinoIcons.chevron_right,size:20)]),const Spacer(),Text(label,style:const TextStyle(fontSize:13,letterSpacing:.7)),const SizedBox(height:6),Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:warning?Colors.deepOrange:null)),if(detail!=null)...[const SizedBox(height:5),Text(detail!,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:14,color:Color(0xFF64727B)))]]));}
class _Maintenance extends StatelessWidget {
  const _Maintenance({required this.pending}); final bool pending;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30)),
    child: Column(children: [
      const Row(children: [CircleAvatar(backgroundColor: Color(0xFFE2F9F6), child: Icon(CupertinoIcons.clock, color: AppTheme.teal)), SizedBox(width: 12), Expanded(child: Text('Próximo mantenimiento', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19))), Text('Ver todo', style: TextStyle(color: AppTheme.teal)), Icon(CupertinoIcons.chevron_right, color: AppTheme.teal)]),
      const SizedBox(height: 14), _row(CupertinoIcons.drop_fill, 'Cambio de aceite', pending ? 'Vencido' : 'Próximamente', pending), const SizedBox(height: 10), _row(CupertinoIcons.wrench, 'Pastillas de freno', 'Revisión el 15/12/2026', false),
    ]),
  );
  Widget _row(IconData icon, String title, String sub, bool warning) => Container(
    padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: warning ? const Color(0xFFFFF0EB) : const Color(0xFFF0FBF9), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [Icon(icon, color: warning ? Colors.deepOrange : AppTheme.teal), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), Text(sub, style: TextStyle(color: warning ? Colors.deepOrange : const Color(0xFF64727B)))])), const Icon(CupertinoIcons.chevron_right)]),
  );
}
String _km(int value)=>'${value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'),(m)=>'.')} km';
