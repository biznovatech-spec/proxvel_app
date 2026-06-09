import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExpandableDescriptionText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableDescriptionText({
    super.key,
    required this.text,
    this.maxLines = 4,
  });

  @override
  State<ExpandableDescriptionText> createState() =>
      _ExpandableDescriptionTextState();
}

class _ExpandableDescriptionTextState extends State<ExpandableDescriptionText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            maxLines: _isExpanded ? null : widget.maxLines,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'Ver menos' : 'Ver más',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
