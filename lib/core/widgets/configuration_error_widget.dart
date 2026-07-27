import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfigurationErrorWidget extends StatelessWidget {
  final String error;

  const ConfigurationErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings_suggest_rounded,
                color: AppColors.errorRed,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Error de Configuración',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Text(
                  error,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'SpaceMono',
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Parece que estás usando claves de Supabase de ejemplo. Para que la app funcione, debes configurar tus propias claves en lib/core/constants/api_constants.dart o mediante --dart-define.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
