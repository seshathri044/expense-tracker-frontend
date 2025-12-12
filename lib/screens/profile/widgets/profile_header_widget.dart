// lib/screens/profile/widgets/profile_header_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/user_models.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final User? user;
  final bool isDarkMode;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.isDarkMode,
  });

  String _getInitial() {
    if (user?.name != null && user!.name.isNotEmpty) {
      return user!.name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: isDarkMode ? const Color(0xFF16213E) : Colors.white,
              child: Text(
                _getInitial(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              '✨ Member since ${DateFormat('MMM yyyy').format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}