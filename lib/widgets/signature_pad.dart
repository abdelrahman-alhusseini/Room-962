import 'package:flutter/material.dart';

import '../theme.dart';

class SignaturePad extends StatefulWidget {
  final List<Offset?> points;
  final ValueChanged<List<Offset?>> onChanged;

  const SignaturePad({
    super.key,
    required this.points,
    required this.onChanged,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late List<Offset?> _points;

  @override
  void initState() {
    super.initState();
    _points = List<Offset?>.from(widget.points);
  }

  void _addPoint(Offset point) {
    setState(() => _points.add(point));
    widget.onChanged(List<Offset?>.from(_points));
  }

  void _endStroke() {
    setState(() => _points.add(null));
    widget.onChanged(List<Offset?>.from(_points));
  }

  void clear() {
    setState(() => _points.clear());
    widget.onChanged(List<Offset?>.from(_points));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: RoomColors.goldMuted, width: 1),
            ),
          ),
          child: GestureDetector(
            onPanStart: (details) => _addPoint(details.localPosition),
            onPanUpdate: (details) => _addPoint(details.localPosition),
            onPanEnd: (_) => _endStroke(),
            child: CustomPaint(
              painter: _SignaturePainter(_points),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: Text(
                'SIGN ABOVE TO ACKNOWLEDGE THE COVENANT.',
                style: TextStyle(
                  color: RoomColors.muted,
                  fontSize: 9,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            InkWell(
              onTap: clear,
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  color: RoomColors.goldMuted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  const _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RoomColors.offWhite
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];

      if (a != null && b != null) {
        canvas.drawLine(a, b, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
