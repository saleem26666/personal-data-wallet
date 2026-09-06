import 'package:flutter/material.dart';

class AmanahMark extends StatelessWidget {
  const AmanahMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/icon/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final labels = ['Too short', 'Weak', 'Fair', 'Good', 'Strong'];
    final scheme = Theme.of(context).colorScheme;
    final color = switch (score) {
      0 || 1 => scheme.error,
      2 => scheme.tertiary,
      _ => scheme.primary,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final active = score > index;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active ? color : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          labels[score.clamp(0, 4)],
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
