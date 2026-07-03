import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_catalog.dart';
import 'package:truthlens/core/detection/model_provisioner.dart';

ModelVariant _v(String id, int minRamMb, {String? url}) => ModelVariant(
      id: id,
      name: id,
      backend: 'transformer',
      languages: const ['en'],
      quant: 'int8',
      sizeBytes: 100,
      minRamMb: minRamMb,
      tier: PerformanceTier.mid,
      version: '1',
      source: 's',
      license: 'l',
      url: url,
    );

void main() {
  final variants = [
    _v('big', 8192, url: 'https://x/big.onnx'),
    _v('small', 2048, url: 'https://x/small.onnx'),
  ];

  ProvisionPlan plan({
    required int ram,
    ModelVariant? recommended,
    bool installed = false,
  }) =>
      ProvisionPlan(
        role: 'transformer',
        roleName: '偵測器',
        variants: variants,
        recommended: recommended ?? variants[1],
        alreadyInstalled: installed,
        deviceRamMb: ram,
      );

  test('fitsDevice 依 RAM 判斷', () {
    final p = plan(ram: 4096);
    expect(p.fitsDevice(variants[0]), isFalse); // 需 8GB
    expect(p.fitsDevice(variants[1]), isTrue); // 需 2GB
  });

  test('isRecommended 標示推薦變體', () {
    final p = plan(ram: 4096, recommended: variants[1]);
    expect(p.isRecommended(variants[1]), isTrue);
    expect(p.isRecommended(variants[0]), isFalse);
  });

  test('needsDownload：未安裝且有可下載推薦', () {
    expect(plan(ram: 4096).needsDownload, isTrue);
    expect(plan(ram: 4096, installed: true).needsDownload, isFalse);
  });

  test('列出全部變體供使用者選擇', () {
    expect(plan(ram: 4096).variants.map((v) => v.id), ['big', 'small']);
  });
}
