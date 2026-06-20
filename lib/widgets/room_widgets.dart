import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class RoomShell extends StatelessWidget {
  final Widget child;
  final bool center;

  const RoomShell({
    super.key,
    required this.child,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(color: RoomColors.voidBlack),
          ),
          CustomPaint(
            painter: _SubtleGridPainter(),
          ),
          SafeArea(
            child: center ? Center(child: child) : child,
          ),
        ],
      ),
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = RoomColors.border.withOpacity(0.18)
      ..strokeWidth = 1;

    const gap = 80.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          RoomColors.voidBlack.withOpacity(0.74),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoldRule extends StatelessWidget {
  final double width;
  final double opacity;

  const GoldRule({
    super.key,
    this.width = 80,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      color: RoomColors.gold.withOpacity(opacity),
    );
  }
}

class QuietButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool larger;

  const QuietButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.larger = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: GoogleFonts.inter(
          color: enabled ? RoomColors.goldMuted : RoomColors.muted,
          fontSize: larger ? 14 : 11,
          fontWeight: FontWeight.w500,
          letterSpacing: larger ? 1.2 : 1.4,
        ),
        child: Text(text.toUpperCase()),
      ),
    );
  }
}

class SectionMarker extends StatelessWidget {
  final String text;

  const SectionMarker({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GoldRule(width: double.infinity, opacity: 0.4),
        const SizedBox(height: 16),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            color: RoomColors.gold,
            fontSize: 9,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class LineTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool requiredField;
  final bool readOnly;

  const LineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.requiredField = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      readOnly: readOnly,
      style: GoogleFonts.inter(
        color: readOnly ? RoomColors.goldMuted : RoomColors.offWhite,
        fontSize: 15,
        fontWeight: FontWeight.w300,
        height: 1.5,
      ),
      cursorColor: RoomColors.gold,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        hintText: hint,
      ),
    );
  }
}

class ProgressDots extends StatelessWidget {
  final int total;
  final int current;

  const ProgressDots({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final done = index < current;
        final active = index == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 8),
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            color: done || active ? RoomColors.gold : RoomColors.border,
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: RoomColors.gold.withOpacity(0.28),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}


class LineDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool requiredField;

  const LineDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value.trim().isEmpty ? null : value,
      isExpanded: true,
      dropdownColor: RoomColors.obsidian,
      iconEnabledColor: RoomColors.goldMuted,
      style: GoogleFonts.inter(
        color: RoomColors.offWhite,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class LineDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final bool requiredField;

  const LineDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.inter(
        color: RoomColors.offWhite,
        fontSize: 15,
        fontWeight: FontWeight.w300,
        height: 1.5,
      ),
      cursorColor: RoomColors.gold,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: RoomColors.goldMuted,
          size: 18,
        ),
      ),
    );
  }
}
