/// 舊版 `.doc`（OLE2／CFB 複合文件）的 SummaryInformation 解析。
///
/// 為什麼值得做：`.doc` 的 SummaryInformation 串流裡含有與 `.docx` 完全
/// 相同的那組欄位——總編輯時間、修訂次數、建立與最後儲存時間、產生軟體。
/// 也就是說，只要能讀出這個串流，舊版 doc 就能和 docx 一樣提供來源證據。
///
/// 格式概要（Microsoft Compound File Binary，MS-CFB）：
///   1. 512 位元組表頭，記錄磁區大小、FAT 位置、目錄起點、mini 串流參數
///   2. FAT 是磁區鏈結表；跟著鏈走才能把一個串流的所有磁區串起來
///   3. 目錄項（每筆 128 位元組）記錄名稱、型別、起始磁區、大小
///   4. **小於 4096 位元組的串流放在 mini 串流裡**，需另外走 mini-FAT。
///      SummaryInformation 幾乎一定落在這條路徑，因此 mini-FAT 不可省略。
///   5. 串流內容是 MS-OLEPS 屬性集：區段標頭 + (屬性ID, 位移) 對照表 + 值
///
/// 本解析器只讀取需要的欄位，並對所有位移做邊界檢查——輸入是使用者提供的
/// 二進位檔，任何欄位都可能是惡意或損毀的值，因此**絕不丟出例外**，
/// 無法解析時一律回傳 null。
library;

import 'dart:convert';
import 'dart:typed_data';

class OleSummaryInformation {
  /// 總編輯時間。注意：此欄位型別雖標記為 FILETIME，實際存的是**期間**
  /// 而非絕對時間——這是 OLEPS 的經典陷阱，當成時間戳解會得到 1601 年附近的值。
  final Duration? totalEditTime;

  /// 修訂（存檔）次數。原始型別是**字串**而非整數，同樣是常見誤解。
  final int? revisionNumber;

  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? application;
  final int? wordCount;

  const OleSummaryInformation({
    this.totalEditTime,
    this.revisionNumber,
    this.createdAt,
    this.modifiedAt,
    this.application,
    this.wordCount,
  });

  bool get isEmpty =>
      totalEditTime == null &&
      revisionNumber == null &&
      createdAt == null &&
      modifiedAt == null &&
      application == null;

  // ── MS-CFB 常數 ────────────────────────────────────────────────────
  static const List<int> _signature = [
    0xD0,
    0xCF,
    0x11,
    0xE0,
    0xA1,
    0xB1,
    0x1A,
    0xE1,
  ];
  static const int _endOfChain = 0xFFFFFFFE;

  /// 串流小於此大小就放在 mini 串流（表頭可覆寫，此為預設值）
  static const int _defaultMiniCutoff = 4096;

  /// 防禦性上限：損毀或惡意的檔案可能宣稱天文數字的磁區數
  static const int _maxSectors = 1 << 20;

  /// SummaryInformation 的串流名稱，首字元是控制碼 0x05
  static const String _summaryName = 'SummaryInformation';

  // ── OLEPS 屬性 ID ─────────────────────────────────────────────────
  static const int _pidRevNumber = 0x09;
  static const int _pidEditTime = 0x0A;
  static const int _pidCreated = 0x0C;
  static const int _pidLastSaved = 0x0D;
  static const int _pidWordCount = 0x0F;
  static const int _pidAppName = 0x12;

  // ── 變體型別 ──────────────────────────────────────────────────────
  static const int _vtI4 = 3;
  static const int _vtLpstr = 30;
  static const int _vtFiletime = 64;

  /// 解析 `.doc` 位元組。非 CFB、找不到串流、或任何欄位越界時回傳 null。
  static OleSummaryInformation? parse(List<int> input) {
    try {
      final bytes = Uint8List.fromList(input);
      if (bytes.length < 512) return null;
      for (var i = 0; i < _signature.length; i++) {
        if (bytes[i] != _signature[i]) return null;
      }
      final data = ByteData.sublistView(bytes);

      final sectorSize = 1 << data.getUint16(30, Endian.little);
      final miniSectorSize = 1 << data.getUint16(32, Endian.little);
      if (sectorSize < 128 || sectorSize > 1 << 16) return null;
      if (miniSectorSize < 16 || miniSectorSize > sectorSize) return null;

      final fatSectorCount = data.getUint32(44, Endian.little);
      final firstDirSector = data.getUint32(48, Endian.little);
      final miniCutoff = data.getUint32(56, Endian.little);
      final firstMiniFatSector = data.getUint32(60, Endian.little);
      final firstDifatSector = data.getUint32(68, Endian.little);

      // 磁區 N 的資料位移。表頭會補齊到一個磁區大小，故 (N+1)*sectorSize 通用。
      int offsetOf(int sector) => (sector + 1) * sectorSize;
      bool inRange(int sector) =>
          sector >= 0 &&
          sector < _maxSectors &&
          offsetOf(sector) + sectorSize <= bytes.length;

      // ── 組出 FAT ──────────────────────────────────────────────────
      final difat = <int>[];
      for (var i = 0; i < 109 && i < fatSectorCount; i++) {
        difat.add(data.getUint32(76 + i * 4, Endian.little));
      }
      // 超過 109 個 FAT 磁區時要走 DIFAT 鏈
      var difatSector = firstDifatSector;
      var difatGuard = 0;
      while (difat.length < fatSectorCount &&
          inRange(difatSector) &&
          difatGuard++ < _maxSectors) {
        final base = offsetOf(difatSector);
        final entries = sectorSize ~/ 4 - 1;
        for (var i = 0; i < entries && difat.length < fatSectorCount; i++) {
          difat.add(data.getUint32(base + i * 4, Endian.little));
        }
        difatSector = data.getUint32(base + entries * 4, Endian.little);
      }

      final fat = <int>[];
      for (final sector in difat) {
        if (!inRange(sector)) return null;
        final base = offsetOf(sector);
        for (var i = 0; i < sectorSize ~/ 4; i++) {
          fat.add(data.getUint32(base + i * 4, Endian.little));
        }
      }
      if (fat.isEmpty) return null;

      /// 沿 FAT 走出一條磁區鏈，含循環偵測
      List<int> chain(int start, List<int> table) {
        final out = <int>[];
        final seen = <int>{};
        var sector = start;
        while (sector < table.length && sector != _endOfChain) {
          if (!seen.add(sector)) break; // 鏈結成環，止損
          if (out.length >= _maxSectors) break;
          out.add(sector);
          sector = table[sector];
        }
        return out;
      }

      Uint8List readChain(int start, List<int> table, int size, int unit) {
        final out = BytesBuilder();
        for (final sector in chain(start, table)) {
          if (unit == sectorSize) {
            if (!inRange(sector)) break;
            out.add(bytes.sublist(offsetOf(sector), offsetOf(sector) + unit));
          }
        }
        final all = out.toBytes();
        return size > 0 && size <= all.length ? all.sublist(0, size) : all;
      }

      // ── 讀目錄，找出 Root Entry 與 SummaryInformation ──────────────
      final dirSectors = chain(firstDirSector, fat);
      int? summaryStart;
      var summarySize = 0;
      var rootStart = 0;
      var rootSize = 0;

      for (final sector in dirSectors) {
        if (!inRange(sector)) return null;
        final base = offsetOf(sector);
        for (var e = 0; e + 128 <= sectorSize; e += 128) {
          final entry = base + e;
          final nameLength = data.getUint16(entry + 64, Endian.little);
          final type = bytes[entry + 66];
          if (type != 2 && type != 5) continue; // 只看串流與 Root

          final chars = <int>[];
          // nameLength 含結尾的 null，故 -2
          for (var i = 0; i + 1 < nameLength - 2 && i < 64; i += 2) {
            chars.add(data.getUint16(entry + i, Endian.little));
          }
          final name = String.fromCharCodes(chars);
          final start = data.getUint32(entry + 116, Endian.little);
          // v3 的大小是 64 位元，但低 32 位足以涵蓋本用途
          final size = data.getUint32(entry + 120, Endian.little);

          if (type == 5) {
            rootStart = start;
            rootSize = size;
          } else if (name == _summaryName) {
            summaryStart = start;
            summarySize = size;
          }
        }
      }
      if (summaryStart == null || summarySize <= 0) return null;

      // ── 取出串流內容（小串流要走 mini-FAT）────────────────────────
      final cutoff = miniCutoff == 0 ? _defaultMiniCutoff : miniCutoff;
      Uint8List stream;
      if (summarySize >= cutoff) {
        stream = readChain(summaryStart, fat, summarySize, sectorSize);
      } else {
        // mini 串流本體存放在一般磁區中，由 Root Entry 指出
        final miniStream = readChain(rootStart, fat, rootSize, sectorSize);
        final miniFatRaw = readChain(firstMiniFatSector, fat, 0, sectorSize);
        final miniFat = <int>[];
        final miniFatData = ByteData.sublistView(miniFatRaw);
        for (var i = 0; i + 4 <= miniFatRaw.length; i += 4) {
          miniFat.add(miniFatData.getUint32(i, Endian.little));
        }

        final out = BytesBuilder();
        for (final mini in chain(summaryStart, miniFat)) {
          final from = mini * miniSectorSize;
          if (from + miniSectorSize > miniStream.length) break;
          out.add(miniStream.sublist(from, from + miniSectorSize));
        }
        final all = out.toBytes();
        stream = summarySize <= all.length ? all.sublist(0, summarySize) : all;
      }

      return _parsePropertySet(stream);
    } catch (_) {
      // 輸入是使用者提供的二進位檔，任何欄位都可能損毀；
      // 解析失敗只代表「沒有來源證據」，不該讓整個匯入流程中斷。
      return null;
    }
  }

  /// 解析 MS-OLEPS 屬性集
  static OleSummaryInformation? _parsePropertySet(Uint8List stream) {
    if (stream.length < 48) return null;
    final data = ByteData.sublistView(stream);
    if (data.getUint16(0, Endian.little) != 0xFFFE) return null;

    final setCount = data.getUint32(24, Endian.little);
    if (setCount < 1) return null;

    // 第一個區段的位移緊接在 FMTID(16) 之後
    final sectionOffset = data.getUint32(44, Endian.little);
    if (sectionOffset + 8 > stream.length) return null;

    final propertyCount = data.getUint32(sectionOffset + 4, Endian.little);
    if (propertyCount > 1024) return null; // 損毀檔案的防呆

    Duration? editTime;
    int? revision;
    DateTime? created;
    DateTime? modified;
    String? application;
    int? words;

    for (var i = 0; i < propertyCount; i++) {
      final entry = sectionOffset + 8 + i * 8;
      if (entry + 8 > stream.length) break;
      final id = data.getUint32(entry, Endian.little);
      final valueOffset =
          sectionOffset + data.getUint32(entry + 4, Endian.little);
      if (valueOffset + 4 > stream.length) continue;

      final type = data.getUint32(valueOffset, Endian.little);
      final body = valueOffset + 4;

      switch (id) {
        case _pidEditTime:
          if (type == _vtFiletime && body + 8 <= stream.length) {
            // 此欄位存的是 100 奈秒為單位的**期間**，不是時間戳
            final ticks = data.getUint64(body, Endian.little);
            editTime = Duration(microseconds: ticks ~/ 10);
          }
        case _pidCreated:
          if (type == _vtFiletime && body + 8 <= stream.length) {
            created = _fromFileTime(data.getUint64(body, Endian.little));
          }
        case _pidLastSaved:
          if (type == _vtFiletime && body + 8 <= stream.length) {
            modified = _fromFileTime(data.getUint64(body, Endian.little));
          }
        case _pidRevNumber:
          // 型別是字串，需先取出再轉數字
          final text = _readLpstr(data, stream, type, body);
          if (text != null) revision = int.tryParse(text.trim());
        case _pidAppName:
          application = _readLpstr(data, stream, type, body);
        case _pidWordCount:
          if (type == _vtI4 && body + 4 <= stream.length) {
            words = data.getInt32(body, Endian.little);
          }
      }
    }

    final result = OleSummaryInformation(
      totalEditTime: editTime,
      revisionNumber: revision,
      createdAt: created,
      modifiedAt: modified,
      application: (application == null || application.isEmpty)
          ? null
          : application,
      wordCount: words,
    );
    return result.isEmpty ? null : result;
  }

  static String? _readLpstr(
    ByteData data,
    Uint8List stream,
    int type,
    int body,
  ) {
    if (type != _vtLpstr || body + 4 > stream.length) return null;
    final length = data.getUint32(body, Endian.little);
    if (length == 0 || length > 1 << 16) return null;
    final start = body + 4;
    if (start + length > stream.length) return null;
    // 去掉結尾的 null 位元組
    var end = start + length;
    while (end > start && stream[end - 1] == 0) {
      end--;
    }
    try {
      return utf8.decode(stream.sublist(start, end), allowMalformed: true);
    } catch (_) {
      return null;
    }
  }

  /// FILETIME：自 1601-01-01 UTC 起算的 100 奈秒間隔數
  static DateTime? _fromFileTime(int ticks) {
    if (ticks <= 0) return null;
    const epochDifferenceSeconds = 11644473600; // 1601→1970
    final seconds = ticks ~/ 10000000 - epochDifferenceSeconds;
    if (seconds < 0 || seconds > 4102444800) return null; // 排除 1970–2100 之外
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
}
