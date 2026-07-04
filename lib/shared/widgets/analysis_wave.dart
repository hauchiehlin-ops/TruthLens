import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 分析進行中的波形動畫（取代靜態進度圈）。多條相位錯開的正弦波疊加流動。
class AnalysisWave extends StatefulWidget {
  final double size;
  const AnalysisWave({super.key, this.size = 160});

  @override
  State<AnalysisWave> createState() => _AnalysisWaveState();
}

class _AnalysisWaveState extends State<AnalysisWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _WavePainter(_c.value, color),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t; // 0..1
  final Color color;
  _WavePainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // 外圈脈動
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final r = maxR * (0.5 + 0.5 * phase);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: (1 - phase) * 0.4),
      );
    }

    // 內部波形線
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;
    for (var line = 0; line < 3; line++) {
      final path = Path();
      final amp = maxR * 0.28 * (1 - line * 0.25);
      final phase = t * 2 * math.pi + line * math.pi / 3;
      for (var x = 0; x <= size.width.toInt(); x += 4) {
        final nx = x / size.width; // 0..1
        // 中央強、邊緣弱的包絡
        final envelope = math.sin(nx * math.pi);
        final y = center.dy +
            amp * envelope * math.sin(nx * 4 * math.pi + phase);
        if (x == 0) {
          path.moveTo(x.toDouble(), y);
        } else {
          path.lineTo(x.toDouble(), y);
        }
      }
      canvas.drawPath(
          path, wave..color = color.withValues(alpha: 0.9 - line * 0.25));
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t || old.color != color;
}
