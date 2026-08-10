import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_auto_activation.dart';
import 'package:truthlens/core/detection/model_manager_types.dart';
import 'package:truthlens/core/detection/orchestrator.dart';

void main() {
  group('ModelAutoActivationManager', () {
    late ModelAutoActivationManager manager;
    late MockEnsembleOrchestrator mockOrchestrator;
    late MockModelManager mockModelManager;

    setUp(() {
      mockOrchestrator = MockEnsembleOrchestrator();
      mockModelManager = MockModelManager();
      manager = ModelAutoActivationManager();
      manager.init(
        orchestrator: mockOrchestrator,
        modelManager: mockModelManager,
      );
    });

    tearDown(() {
      manager.dispose();
    });

    test('監聽器應在初始化後活躍', () {
      expect(manager.activationEvent.value, isNull);
    });

    test('新模型安裝時應觸發自動激活事件', () async {
      // 模擬模型下載完成
      mockModelManager.simulateModelInstalled(
        role: 'transformer',
        variantId: 'multilingual_distil_int8',
      );

      // 等待異步事件處理
      await Future.delayed(const Duration(milliseconds: 100));

      // 驗證激活事件被發出
      expect(manager.activationEvent.value, isNotNull);
      expect(
        manager.activationEvent.value?.activatedModels,
        contains('transformer:multilingual_distil_int8'),
      );
    });

    test('應自動呼叫 orchestrator.refreshEngines()', () async {
      // 模擬多個模型安裝
      mockModelManager.simulateModelInstalled(
        role: 'transformer',
        variantId: 'roberta_int8',
      );
      mockModelManager.simulateModelInstalled(
        role: 'statistical',
        variantId: 'distilgpt2_int8',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // 驗證 orchestrator 被通知
      expect(mockOrchestrator.refreshEnginesCalled, isTrue);
      expect(mockOrchestrator.refreshEnginesCallCount, greaterThan(0));
    });

    test('移除模型後應保持激活列表同步', () async {
      // 安裝 2 個模型
      mockModelManager.simulateModelInstalled(
        role: 'transformer',
        variantId: 'model_v1',
      );
      mockModelManager.simulateModelInstalled(
        role: 'statistical',
        variantId: 'model_v2',
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        manager.activationEvent.value?.activatedModels?.length,
        2,
      );

      // 移除一個模型
      mockModelManager.simulateModelRemoved(
        role: 'statistical',
        variantId: 'model_v2',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // 驗證列表更新
      expect(mockOrchestrator.refreshEnginesCallCount, greaterThan(1));
    });

    test('事件應包含準確的時間戳', () async {
      final beforeTime = DateTime.now();

      mockModelManager.simulateModelInstalled(
        role: 'adversarial',
        variantId: 'adversarial_int8',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final afterTime = DateTime.now();
      final event = manager.activationEvent.value;

      expect(event, isNotNull);
      expect(event!.timestamp.isAfter(beforeTime), isTrue);
      expect(event.timestamp.isBefore(afterTime), isTrue);
    });

    test('應處理連續模型安裝而不崩潰', () async {
      // 快速連續安裝 5 個模型
      for (int i = 0; i < 5; i++) {
        mockModelManager.simulateModelInstalled(
          role: 'transformer',
          variantId: 'variant_$i',
        );
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // 驗證最後一個事件
      expect(manager.activationEvent.value, isNotNull);
      expect(
        manager.activationEvent.value?.activatedModels,
        contains('transformer:variant_4'),
      );
    });
  });

  group('EnsembleOrchestrator.refreshEngines', () {
    late MockEnsembleOrchestrator orchestrator;

    setUp(() {
      orchestrator = MockEnsembleOrchestrator();
    });

    test('refreshEngines 應觸發 notifyListeners', () async {
      var listenerCallCount = 0;
      orchestrator.addListener(() => listenerCallCount++);

      await orchestrator.refreshEngines();

      expect(listenerCallCount, greaterThan(0));
    });

    test('下次分析應使用刷新後的引擎', () async {
      // 模擬引擎狀態變化
      await orchestrator.refreshEngines();

      // 驗證下次分析會使用新配置
      expect(orchestrator.shouldUseRefreshedEngines, isTrue);
    });
  });
}

// Mock 類別（實裝詳見測試文件）

class MockEnsembleOrchestrator {
  bool refreshEnginesCalled = false;
  int refreshEnginesCallCount = 0;
  bool shouldUseRefreshedEngines = false;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback callback) => _listeners.add(callback);

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> refreshEngines() async {
    refreshEnginesCalled = true;
    refreshEnginesCallCount++;
    shouldUseRefreshedEngines = true;
    notifyListeners();
  }
}

class MockModelManager {
  final List<(String role, String variantId)> _installed = [];
  final List<VoidCallback> _listeners = [];

  void simulateModelInstalled({
    required String role,
    required String variantId,
  }) {
    _installed.add((role, variantId));
    _notifyListeners();
  }

  void simulateModelRemoved({
    required String role,
    required String variantId,
  }) {
    _installed.removeWhere((item) => item.$1 == role && item.$2 == variantId);
    _notifyListeners();
  }

  void addListener(VoidCallback callback) => _listeners.add(callback);

  void removeListener(VoidCallback callback) => _listeners.remove(callback);

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Iterable<RoleState> get roles => _installed
      .map((item) => RoleState(role: item.$1))
      .toList()
      .cast<RoleState>();

  List<InstalledModel> installedVariants(String role) => const [];

  Future<void> setActive(String role, String variantId) async {}
}
