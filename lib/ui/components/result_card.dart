import 'package:flutter/material.dart';

import '../../domain/presentation_labels.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.title,
    required this.result,
    required this.effects,
    this.causes = const <String>[],
  });

  final String? title;
  final String? result;
  final List<String> effects;
  final List<String> causes;

  @override
  Widget build(BuildContext context) {
    if (title == null || result == null) return const SizedBox.shrink();
    final visibleEffects = sanitizePlayerFacingLines(effects);
    final visibleCauses = sanitizePlayerFacingLines(causes);
    return Container(
      key: const Key('latest-result'),
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff6e58b0)),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xff1b3b6e), Color(0xff0e1d39)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '本次结果',
            style: TextStyle(color: Color(0xffb69aff), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            title!,
            style: const TextStyle(
              color: Color(0xfffff0ca),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result!,
            style: const TextStyle(color: Color(0xffeaf1ff), height: 1.4),
          ),
          if (visibleEffects.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 5,
              children: visibleEffects
                  .map(
                    (effect) => Text(
                      effect,
                      style: const TextStyle(
                        color: Color(0xffa9b8d7),
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (visibleCauses.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            const Text(
              '为什么会这样',
              style: TextStyle(color: Color(0xff74d7ff), fontSize: 12),
            ),
            ...visibleCauses.map(
              (cause) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '· $cause',
                  style: const TextStyle(
                    color: Color(0xffa9b8d7),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
