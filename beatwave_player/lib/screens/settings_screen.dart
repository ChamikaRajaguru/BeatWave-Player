import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../core/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'SETTINGS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    // App section header
                    _sectionHeader(theme, 'Appearance'),
                    const SizedBox(height: 8),
                    // Theme toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return _settingsCard(
                          theme,
                          icon: themeProvider.isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          iconColor: themeProvider.isDarkMode
                              ? AppColors.accent
                              : Colors.amber,
                          title: 'Dark Mode',
                          subtitle: themeProvider.isDarkMode
                              ? 'Dark theme is active'
                              : 'Light theme is active',
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (_) {
                              HapticFeedback.lightImpact();
                              themeProvider.toggleTheme();
                            },
                            activeThumbColor: AppColors.accent,
                            activeTrackColor: AppColors.accent.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(theme, 'Audio'),
                    const SizedBox(height: 8),
                    _settingsCard(
                      theme,
                      icon: Icons.equalizer_rounded,
                      iconColor: AppColors.primaryDark,
                      title: 'Equalizer',
                      subtitle: 'Adjust audio frequencies',
                      onTap: () {
                        Navigator.pushNamed(context, '/equalizer');
                      },
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(theme, 'About'),
                    const SizedBox(height: 8),
                    _settingsCard(
                      theme,
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.accent,
                      title: AppConstants.appName,
                      subtitle: 'Version ${AppConstants.appVersion}',
                    ),
                    const SizedBox(height: 8),
                    _settingsCard(
                      theme,
                      icon: Icons.code_rounded,
                      iconColor: Colors.orangeAccent,
                      title: 'Built with Flutter',
                      subtitle: 'Powered by just_audio & audio_service',
                    ),
                    const SizedBox(height: 40),
                    // Branding
                    Center(
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                            child: const Icon(
                              Icons.equalizer_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'BeatWave',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Feel the rhythm',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _settingsCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.cardTheme.color?.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null && trailing == null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.iconTheme.color?.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
