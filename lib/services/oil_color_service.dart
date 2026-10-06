import 'dart:io';
import 'package:image/image.dart' as img;

enum OilAppearance { light, amber, dark, inconclusive }

class OilColorResult {
  const OilColorResult(this.appearance, this.red, this.green, this.blue);
  final OilAppearance appearance; final int red, green, blue;
  String get title => switch (appearance) { OilAppearance.light => 'Aspecto claro', OilAppearance.amber => 'Ámbar', OilAppearance.dark => 'Aspecto oscuro', OilAppearance.inconclusive => 'Sin lectura confiable' };
  String get guidance => switch (appearance) { OilAppearance.light => 'El color luce claro. Verifica también nivel y kilometraje.', OilAppearance.amber => 'Color habitual de aceite en uso. Revisa el intervalo registrado.', OilAppearance.dark => 'El color luce oscuro. Considera revisar el cambio con un taller.', OilAppearance.inconclusive => 'Mejora la iluminación y enfoca solo la zona húmeda de la varilla.' };
}

class OilColorService {
  Future<OilColorResult> analyze(String path) async {
    final image = img.decodeImage(await File(path).readAsBytes());
    if (image == null) return const OilColorResult(OilAppearance.inconclusive, 0, 0, 0);
    final left = image.width * 35 ~/ 100, right = image.width * 65 ~/ 100, top = image.height * 35 ~/ 100, bottom = image.height * 65 ~/ 100;
    var r=0,g=0,b=0,count=0;
    for (var y=top; y<bottom; y+=6) { for (var x=left; x<right; x+=6) { final p=image.getPixel(x,y); final brightness=(p.r+p.g+p.b)/3; if(brightness>20 && brightness<235){r+=p.r.toInt();g+=p.g.toInt();b+=p.b.toInt();count++;} } }
    if(count<20)return const OilColorResult(OilAppearance.inconclusive,0,0,0);
    r~/=count;g~/=count;b~/=count;
    final appearance = r < 72 && g < 67 && b < 58 ? OilAppearance.dark : r > b * 1.35 && r > g * 1.08 ? OilAppearance.amber : OilAppearance.light;
    return OilColorResult(appearance,r,g,b);
  }
}
