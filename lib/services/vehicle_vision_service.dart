import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class VehicleVisionResult {
  const VehicleVisionResult({required this.labels});
  final List<String> labels;
  bool get hasVehicleCue => labels.any((label) => ['car', 'vehicle', 'wheel', 'tire', 'engine', 'automobile'].any((cue) => label.toLowerCase().contains(cue)));
}

class VehicleVisionService {
  Future<VehicleVisionResult> analyze(String imagePath) async {
    final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: .55));
    try {
      final result = await labeler.processImage(InputImage.fromFilePath(imagePath));
      return VehicleVisionResult(labels: result.take(4).map((item) => item.label).toList());
    } finally {
      await labeler.close();
    }
  }
}
