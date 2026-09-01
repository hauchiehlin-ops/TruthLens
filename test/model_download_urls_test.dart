import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/model_download_urls.dart';

void main() {
  test('HuggingFace downloads stay on direct CORS-enabled origins', () {
    final candidates = modelDownloadCandidateUrls(
      'https://huggingface.co/hauchieh/omnitrace-models/resolve/main/omnitrace_zh_detector_int8.onnx',
      baseUri: Uri.parse('https://omni-trace-roan-three.vercel.app/settings'),
    );

    expect(candidates, [
      'https://huggingface.co/hauchieh/omnitrace-models/resolve/main/omnitrace_zh_detector_int8.onnx',
      'https://hf-mirror.com/hauchieh/omnitrace-models/resolve/main/omnitrace_zh_detector_int8.onnx',
    ]);
    expect(candidates.any((url) => url.contains('/api/proxy')), isFalse);
  });

  test('GitHub downloads keep proxy fallbacks and avoid duplicate URLs', () {
    final candidates = modelDownloadCandidateUrls(
      'https://github.com/hauchiehlin-ops/OmniTrace/releases/download/models-v1/adversarial_int8.onnx',
      baseUri: Uri.parse('https://omni-trace-roan-three.vercel.app/settings'),
    );

    expect(candidates.length, 2);
    expect(candidates.first, contains('/api/proxy?url='));
    expect(candidates.last, startsWith('https://github.com/'));
  });
}
