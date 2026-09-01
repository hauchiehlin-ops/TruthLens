import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/device_capabilities.dart';
import 'package:omnitrace/core/detection/model_catalog_service.dart';
import 'package:omnitrace/core/detection/model_manager.dart';
import 'package:omnitrace/core/detection/model_provisioner.dart';

const _mb = 1048576;

DeviceCapabilities _device({
  int ramMb = 16384,
  int processors = 10,
  int? quotaBytes,
  int usageBytes = 0,
  bool persisted = false,
}) => DeviceCapabilities(
  totalRamMb: ramMb,
  processors: processors,
  platform: 'test',
  ramMeasured: true,
  storageQuotaBytes: quotaBytes,
  storageUsageBytes: usageBytes,
  storagePersisted: persisted,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ModelProvisioner provisioner;

  setUp(() {
    provisioner = ModelProvisioner(
      catalogService: ModelCatalogService(),
      modelManager: ModelManager(),
    );
  });

  test('空間充足時建議核心三顆，報告 LLM 因非必要被排除', () async {
    final bundle = await provisioner.recommendBundle(
      _device(quotaBytes: 8000 * _mb),
    );

    expect(bundle.included.map((e) => e.role), [
      'transformer',
      'statistical',
      'adversarial',
    ]);
    expect(bundle.count, 3);
    expect(
      bundle.excluded.any(
        (e) => e.role == 'llm' && e.decision == BundleDecision.skipOptional,
      ),
      isTrue,
      reason: '1.6GB 的報告 LLM 不影響判讀結論，永遠不該進預設套組',
    );
  });

  test('可用空間不足時逐項排除，並說得出是空間問題', () async {
    // 只留 200MB 可用 → 預算 140MB，僅夠核心 transformer 一顆。
    final bundle = await provisioner.recommendBundle(
      _device(quotaBytes: 1000 * _mb, usageBytes: 800 * _mb),
    );

    expect(bundle.count, lessThan(3));
    expect(
      bundle.excluded.any((e) => e.decision == BundleDecision.skipStorage),
      isTrue,
    );
    expect(bundle.totalBytes, lessThanOrEqualTo((200 * _mb * 0.7).round()));
  });

  test('RAM 不足的變體標為 skipRam，不是靜默消失', () async {
    final bundle = await provisioner.recommendBundle(
      _device(ramMb: 1024, processors: 2, quotaBytes: 8000 * _mb),
    );

    expect(
      bundle.entries.any((e) => e.decision == BundleDecision.skipRam),
      isTrue,
    );
  });

  test('中文文件會一併建議中文專用變體', () async {
    final bundle = await provisioner.recommendBundle(
      _device(quotaBytes: 8000 * _mb),
      languageCode: 'zh',
    );

    final transformers = bundle.included.where((e) => e.role == 'transformer');
    expect(transformers.length, 2, reason: '多語通用一顆 + 中文專用一顆');
    // 只補一顆中文專用變體：catalog 依品質排序，取最前面那顆。塞兩顆功能
    // 重疊的中文偵測器只會讓使用者多下載上百 MB。
    expect(
      transformers.any((e) => e.variant.languages.contains('zh')),
      isTrue,
    );
    expect(
      transformers.where((e) => e.variant.languages.contains('zh')).length,
      1,
    );
  });

  test('配額未知時不因此擋下任何模型', () async {
    final bundle = await provisioner.recommendBundle(_device());

    expect(bundle.storageAvailableBytes, isNull);
    expect(bundle.remainingBytes, isNull);
    expect(
      bundle.excluded.any((e) => e.decision == BundleDecision.skipStorage),
      isFalse,
      reason: '未知不等於零，不該用猜測擋住使用者',
    );
  });
}
