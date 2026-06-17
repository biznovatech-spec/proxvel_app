import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Premium profile header with avatar (initials), name, and email.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ── Avatar ──
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Name ──
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textOnDark,
              ),
            ),

            const SizedBox(height: 4),

            // ── Email ──
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textOnDark.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'V';
  }
}
