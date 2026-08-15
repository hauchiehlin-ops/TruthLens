import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'model_catalog.dart';

import 'services/huggingface_hub_explorer.dart';

/// 載入模型 catalog。優先抓遠端「目前最新」清單（GitHub raw / CDN，無需後端），
/// 失敗時回退至隨 App 打包的 assets/model_catalog.json。
class ModelCatalogService {
  /// 遠端 catalog URL。指向專案發佈頁的 raw 檔；改版時只更新此檔即可推新模型，
  /// 不必更新 App（對應 plan 第八節的無伺服器更新機制）。
  static const remoteUrl =
      'https://raw.githubusercontent.com/hauchiehlin-ops/TruthLens/main/assets/model_catalog.json';

  static const _asset = 'assets/model_catalog.json';

  final http.Client _client;
  final HuggingFaceHubExplorer _explorer;

  ModelCatalogService({http.Client? client, HuggingFaceHubExplorer? explorer})
    : _client = client ?? http.Client(),
      _explorer = explorer ?? HuggingFaceHubExplorer(client: client);

  ModelCatalog? _cached;

  /// 取得 catalog（快取）。[preferRemote] 為 false 時只讀本地資產。
  /// [discoverCommunity] 為 true 時自動併入 HuggingFace 探尋發現之模型。
  Future<ModelCatalog> load({
    bool preferRemote = true,
    bool discoverCommunity = false,
  }) async {
    if (_cached != null && !discoverCommunity) return _cached!;
    ModelCatalog catalog;
    if (preferRemote) {
      final remote = await _tryRemote();
      catalog = remote ?? await _bundled();
    } else {
      catalog = await _bundled();
    }

    if (discoverCommunity) {
      final community = await _explorer.discoverCommunityModels();
      catalog = catalog.withCommunityVariants(community);
    }

    _cached = catalog;
    return catalog;
  }

  Future<ModelCatalog?> _tryRemote() async {
    try {
      final resp = await _client
          .get(Uri.parse(remoteUrl))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      return ModelCatalog.fromJson(
        jsonDecode(resp.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null; // 離線 / 尚未 host → 回退本地
    }
  }

  Future<ModelCatalog> _bundled() async {
    final raw = await rootBundle.loadString(_asset);
    return ModelCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
