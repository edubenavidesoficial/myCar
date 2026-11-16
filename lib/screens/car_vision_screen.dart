import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Future<void> openCarVision(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CarVisionScreen()));

class CarVisionScreen extends StatefulWidget {
  const CarVisionScreen({super.key});
  @override State<CarVisionScreen> createState() => _CarVisionScreenState();
}

class _CarVisionScreenState extends State<CarVisionScreen> with WidgetsBindingObserver {
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
    return Scaffold(backgroundColor: Colors.black, body: Stack(fit: StackFit.expand, children: [
      if (_camera?.value.isInitialized == true) Center(child: CameraPreview(_camera!)) else _CameraLoading(error: _error),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x88000000), Colors.transparent, Color(0xAA000000)]))),
      SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [IconButton.filledTonal(onPressed: () => Navigator.pop(context), icon: const Icon(CupertinoIcons.xmark), style: IconButton.styleFrom(backgroundColor: Colors.black45, foregroundColor: Colors.white)), const Spacer(), const _LiveBadge()]),
        const SizedBox(height: 22), const Text('myCar Vision', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)), const Text('Vista en vivo de tu vehículo', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const Spacer(),
        const _VisionHint(),
      ]))),
    ]));
  }
}

class _CameraLoading extends StatelessWidget { const _CameraLoading({this.error}); final String? error; @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [if (error == null) const CircularProgressIndicator(color: AppTheme.teal) else const Icon(CupertinoIcons.camera, color: Colors.white, size: 50), const SizedBox(height: 16), Text(error ?? 'Iniciando cámara...', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)])); }
class _LiveBadge extends StatelessWidget { const _LiveBadge(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xCC003C39), borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(CupertinoIcons.viewfinder, color: Color(0xFF67F0E4), size: 17), SizedBox(width: 6), Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))])); }
class _VisionHint extends StatelessWidget { const _VisionHint(); @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xCC121E20), border: Border.all(color: AppTheme.teal.withValues(alpha: .65)), borderRadius: BorderRadius.circular(22)), child: const Row(children: [Icon(CupertinoIcons.viewfinder, color: AppTheme.teal, size: 28), SizedBox(width: 12), Expanded(child: Text('Mueve la cámara alrededor del vehículo para observarlo en vivo. Para revisar aceite o frenos, usa las herramientas específicas.', style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3)))])); }
