import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../theme/app_theme.dart';

Future<void> openCarVision(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CarVisionScreen()));

class CarVisionScreen extends ConsumerStatefulWidget {
  const CarVisionScreen({super.key});
  @override ConsumerState<CarVisionScreen> createState() => _CarVisionScreenState();
}

class _CarVisionScreenState extends ConsumerState<CarVisionScreen> with WidgetsBindingObserver {
  CameraController? _camera;
  String? _error;
  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); _start(); }
  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No encontramos una cámara disponible.');
      final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (mounted) setState(() => _camera = controller);
    } catch (e) { if (mounted) setState(() => _error = 'No fue posible abrir la cámara. Revisa los permisos.'); }
  }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); _camera?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final app = ref.watch(appProvider); final oil = app.oil;
    final oilPending = oil == null || oil.currentMileage >= oil.nextMileage;
    return Scaffold(backgroundColor: Colors.black, body: Stack(fit: StackFit.expand, children: [
      if (_camera?.value.isInitialized == true) Center(child: CameraPreview(_camera!)) else _CameraLoading(error: _error),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x88000000), Colors.transparent, Color(0xAA000000)]))),
      SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [IconButton.filledTonal(onPressed: () => Navigator.pop(context), icon: const Icon(CupertinoIcons.xmark), style: IconButton.styleFrom(backgroundColor: Colors.black45, foregroundColor: Colors.white)), const Spacer(), const _LiveBadge()]),
        const SizedBox(height: 22), const Text('myCar Vision', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)), const Text('Apunta hacia tu vehículo', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const Spacer(),
        _OverlayCard(icon: CupertinoIcons.drop_fill, title: 'Cambio de aceite', value: oilPending ? 'Pendiente' : 'Al día', detail: oilPending ? 'Registra el cambio para actualizar el estado' : 'Faltan ${oil.nextMileage - oil.currentMileage} km', color: oilPending ? Colors.deepOrange : const Color(0xFF1DCB62)),
        const SizedBox(height: 12),
        const _OverlayCard(icon: CupertinoIcons.wrench, title: 'Frenos y pastillas', value: 'Bueno', detail: 'Revisión programada: 15/12/2026', color: Color(0xFF1DCB62)),
        const SizedBox(height: 12),
        _OverallStatus(pending: oilPending),
      ]))),
    ]));
  }
}

class _CameraLoading extends StatelessWidget { const _CameraLoading({this.error}); final String? error; @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [if (error == null) const CircularProgressIndicator(color: AppTheme.teal) else const Icon(CupertinoIcons.camera, color: Colors.white, size: 50), const SizedBox(height: 16), Text(error ?? 'Iniciando cámara...', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)])); }
class _LiveBadge extends StatelessWidget { const _LiveBadge(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xCC003C39), borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(CupertinoIcons.viewfinder, color: Color(0xFF67F0E4), size: 17), SizedBox(width: 6), Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))])); }
class _OverlayCard extends StatelessWidget { const _OverlayCard({required this.icon,required this.title,required this.value,required this.detail,required this.color}); final IconData icon; final String title,value,detail; final Color color; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xE8121E20),border:Border.all(color:color.withValues(alpha:.7)),borderRadius:BorderRadius.circular(22)),child:Row(children:[CircleAvatar(backgroundColor:color.withValues(alpha:.2),child:Icon(icon,color:color)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700,fontSize:16)),Text(detail,style:const TextStyle(color:Colors.white70,fontSize:13))])),Text(value,style:TextStyle(color:color,fontWeight:FontWeight.w800,fontSize:17))])); }
class _OverallStatus extends StatelessWidget { const _OverallStatus({required this.pending}); final bool pending; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:20,vertical:16),decoration:BoxDecoration(color:const Color(0xE8FFFFFF),borderRadius:BorderRadius.circular(24)),child:Row(children:[Icon(pending?CupertinoIcons.exclamationmark_triangle_fill:CupertinoIcons.check_mark_circled_solid,color:pending?Colors.deepOrange:const Color(0xFF15A751)),const SizedBox(width:12),Expanded(child:Text(pending?'Atención de mantenimiento requerida':'Estado general bueno',style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16))),const Icon(CupertinoIcons.chevron_right,color:AppTheme.teal)])); }
