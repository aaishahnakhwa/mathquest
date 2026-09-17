import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// A whole-number addition or subtraction expression that can be represented
/// exactly with base-10 blocks.
class VisualMathExpression {
  final int left;
  final int right;
  final String operatorSymbol;

  const VisualMathExpression({
    required this.left,
    required this.right,
    required this.operatorSymbol,
  });

  int get result => operatorSymbol == '+' ? left + right : left - right;
}

class VisualMathHelper extends StatelessWidget {
  final String questionText;
  final String topic;

  const VisualMathHelper({
    super.key,
    required this.questionText,
    required this.topic,
  });

  /// Returns data only when the complete question is one supported binary
  /// whole-number operation. This deliberately rejects fractions, equations,
  /// negative-number models, and multi-step expressions instead of showing a
  /// plausible-looking but mathematically incorrect diagram.
  @visibleForTesting
  static VisualMathExpression? parseExpression({
    required String questionText,
    required String topic,
  }) {
    if (topic != 'Addition' && topic != 'Subtraction') return null;

    var expression = questionText.trim();
    expression = expression.replaceFirst(
      RegExp(r'^(?:what is|calculate:|solve:)\s*', caseSensitive: false),
      '',
    );
    expression = expression.replaceFirst(RegExp(r'\?\s*$'), '').trim();

    final match = RegExp(r'^(\d+)\s*([+-])\s*(\d+)$').firstMatch(expression);
    if (match == null) return null;

    final left = int.parse(match.group(1)!);
    final operatorSymbol = match.group(2)!;
    final right = int.parse(match.group(3)!);

    // The compact place-value model is designed for the values used by the
    // game. A hidden/truncated model would be less useful than no model.
    if (left > 999 || right > 999) return null;
    if (operatorSymbol == '-' && right > left) return null;

    return VisualMathExpression(
      left: left,
      right: right,
      operatorSymbol: operatorSymbol,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expression = parseExpression(
      questionText: questionText,
      topic: topic,
    );
    if (expression == null) return const SizedBox.shrink();

    return Container(
      key: const Key('visual-math-helper'),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0xFF94A3B8), offset: Offset(0, 3)),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 14,
                color: GameColors.navyTextMuted,
              ),
              SizedBox(width: 4),
              Text(
                'EXACT PLACE-VALUE MODEL',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyTextMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${expression.left} ${expression.operatorSymbol} '
            '${expression.right} = ${expression.result}',
            key: const Key('visual-math-equation'),
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GameColors.navyText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _PlaceValueGroup(
                  value: expression.left,
                  color: const Color(0xFF2563EB),
                  lightColor: const Color(0xFFBFDBFE),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text(
                  expression.operatorSymbol,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: GameColors.navyText,
                  ),
                ),
              ),
              Expanded(
                child: _PlaceValueGroup(
                  value: expression.right,
                  color: const Color(0xFF16A34A),
                  lightColor: const Color(0xFFBBF7D0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaceValueGroup extends StatelessWidget {
  final int value;
  final Color color;
  final Color lightColor;

  const _PlaceValueGroup({
    required this.value,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    final hundreds = value ~/ 100;
    final tens = (value ~/ 10) % 10;
    final ones = value % 10;

    return Container(
      constraints: const BoxConstraints(minHeight: 91),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: lightColor.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          if (value == 0)
            Text(
              '0',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 5,
              runSpacing: 4,
              children: [
                if (hundreds > 0)
                  _PlaceUnit(
                    label: '100s',
                    count: hundreds,
                    color: color,
                    lightColor: lightColor,
                    shape: _PlaceShape.hundred,
                  ),
                if (tens > 0)
                  _PlaceUnit(
                    label: '10s',
                    count: tens,
                    color: color,
                    lightColor: lightColor,
                    shape: _PlaceShape.ten,
                  ),
                if (ones > 0)
                  _PlaceUnit(
                    label: '1s',
                    count: ones,
                    color: color,
                    lightColor: lightColor,
                    shape: _PlaceShape.one,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

enum _PlaceShape { hundred, ten, one }

class _PlaceUnit extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color lightColor;
  final _PlaceShape shape;

  const _PlaceUnit({
    required this.label,
    required this.count,
    required this.color,
    required this.lightColor,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              count,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: _buildBlock(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count $label',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBlock() {
    final (width, height) = switch (shape) {
      _PlaceShape.hundred => (25.0, 25.0),
      _PlaceShape.ten => (6.0, 28.0),
      _PlaceShape.one => (9.0, 9.0),
    };

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(shape == _PlaceShape.ten ? 2 : 3),
        border: Border.all(color: lightColor, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
