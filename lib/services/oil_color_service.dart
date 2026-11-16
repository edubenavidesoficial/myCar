import 'dart:io';
import 'package:image/image.dart' as img;

enum OilAppearance { light, amber, dark, inconclusive }

class OilColorResult {
  const OilColorResult(this.appearance, this.red, this.green, this.blue, this.confidence);
  final OilAppearance appearance;
  final int red, green, blue;
  final double confidence;
  String get title => switch (appearance) {
    OilAppearance.light => 'Color claro detectado',
    OilAppearance.amber => 'Color ámbar detectado',
    OilAppearance.dark => 'Color oscuro detectado',
    OilAppearance.inconclusive => 'No se pudo confirmar el color',
  };
  String get guidance => switch (appearance) {
    OilAppearance.light => 'La muestra presenta tonos claros. Verifica también el nivel y el kilometraje.',
    OilAppearance.amber => 'La muestra presenta tonos ámbar. Revisa el intervalo registrado.',
    OilAppearance.dark => 'La muestra presenta tonos oscuros. Considera revisar el cambio con un taller.',
    OilAppearance.inconclusive => 'La lectura no tiene suficiente contraste. Limpia la varilla, usa luz natural y vuelve a enfocar la zona húmeda.',
  };
  String get confidenceLabel => 'Confianza aproximada: ${(confidence * 100).round()}%';
}

class OilColorService {
  Future<OilColorResult> analyze(String path) async {
    final image = img.decodeImage(await File(path).readAsBytes());
    if (image == null) return const OilColorResult(OilAppearance.inconclusive, 0, 0, 0, 0);
    final left = image.width * 30 ~/ 100, right = image.width * 70 ~/ 100;
    final top = image.height * 30 ~/ 100, bottom = image.height * 70 ~/ 100;
    var r = 0, g = 0, b = 0, count = 0;
    for (var y = top; y < bottom; y += 5) {
      for (var x = left; x < right; x += 5) {
        final p = image.getPixel(x, y);
        final brightness = (p.r + p.g + p.b) / 3;
        if (brightness > 18 && brightness < 245) {
          r += p.r.toInt(); g += p.g.toInt(); b += p.b.toInt(); count++;
        }
      }
    }
    if (count < 20) return const OilColorResult(OilAppearance.inconclusive, 0, 0, 0, 0);
    r ~/= count; g ~/= count; b ~/= count;
    final luminance = r * .2126 + g * .7152 + b * .0722;
    final warmth = (r - g) + (g - b);
    final channels = [r, g, b];
    final spread = channels.reduce((a, c) => a > c ? a : c) - channels.reduce((a, c) => a < c ? a : c);
    final appearance = luminance < 78
        ? OilAppearance.dark
        : warmth > 18 && r > b + 8
            ? OilAppearance.amber
            : spread < 24 && luminance > 210
                ? OilAppearance.inconclusive
                : OilAppearance.light;
    final confidence = appearance == OilAppearance.inconclusive ? .35 : (spread / 100).clamp(.55, .95).toDouble();
    return OilColorResult(appearance, r, g, b, confidence);
  }
}
