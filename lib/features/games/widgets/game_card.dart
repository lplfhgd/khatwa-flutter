import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.imagePath,
    required this.onTap,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: const BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: imagePath != null
                        ? ClipOval(
                            child: Image.asset(
                              imagePath!,
                              width: 112,
                              height: 112,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  icon ?? Icons.extension_rounded,
                                  size: 68,
                                  color: iconColor ?? AppColors.primary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            icon ?? Icons.extension_rounded,
                            size: 68,
                            color: iconColor ?? AppColors.primary,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.mint,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
