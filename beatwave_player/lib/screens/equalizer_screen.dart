import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/equalizer_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/eq_band_slider.dart';
import '../core/constants.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize equalizer with audio session
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final audioProvider = context.read<AudioProvider>();
      final eqProvider = context.read<EqualizerProvider>();
      if (!eqProvider.isInitialized) {
        final sessionId = await audioProvider.playerService.getAudioSessionId();
        if (sessionId != null) {
          await eqProvider.init(sessionId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Consumer<EqualizerProvider>(
            builder: (context, eq, _) {
              return Column(
                children: [
                  // ─── Top Bar ──────────────────────────────
                  _buildTopBar(theme, eq),
                  const SizedBox(height: 16),
                  // ─── Enable Toggle ────────────────────────
                  _buildEnableToggle(theme, eq),
                  const SizedBox(height: 20),
                  // ─── Preset Selector ──────────────────────
                  _buildPresetSelector(theme, eq),
                  const SizedBox(height: 24),
                  // ─── EQ Bands ─────────────────────────────
                  Expanded(child: _buildEqBands(theme, eq)),
                  // ─── Bass & Virtualizer ───────────────────
                  _buildEffectSliders(theme, eq),
                  const SizedBox(height: 16),
                  // ─── Actions ──────────────────────────────
                  _buildActions(theme, eq),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, EqualizerProvider eq) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 22),
            color: Colors.white70,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'EQUALIZER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // balance
        ],
      ),
    );
  }

  Widget _buildEnableToggle(ThemeData theme, EqualizerProvider eq) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: eq.isEnabled
                ? AppColors.accent.withValues(alpha: 0.3)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.graphic_eq_rounded,
              color: eq.isEnabled ? AppColors.accent : Colors.white38,
            ),
            const SizedBox(width: 12),
            Text(
              'Equalizer',
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
            const Spacer(),
            Switch(
              value: eq.isEnabled,
              onChanged: (v) {
                HapticFeedback.lightImpact();
                eq.setEnabled(v);
              },
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector(ThemeData theme, EqualizerProvider eq) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: eq.allPresetNames.length,
        itemBuilder: (context, index) {
          final name = eq.allPresetNames[index];
          final isSelected = name == eq.currentPresetName;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                eq.applyPreset(name);
              },
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: Colors.white10),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEqBands(ThemeData theme, EqualizerProvider eq) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: List.generate(AppConstants.eqBandCount, (index) {
            return Expanded(
              child: EqBandSlider(
                label: AppConstants.eqBandLabels[index],
                value: eq.bandGains.length > index ? eq.bandGains[index] : 0,
                onChanged: (value) {
                  eq.setBandGain(index, value);
                },
                activeColor: _bandColor(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _bandColor(int index) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF8B83FF),
      Color(0xFF00E5FF),
      Color(0xFF00BCD4),
      Color(0xFFFF6584),
    ];
    return colors[index % colors.length];
  }

  Widget _buildEffectSliders(ThemeData theme, EqualizerProvider eq) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Bass Boost
          _buildEffectRow(
            theme,
            icon: Icons.speaker_rounded,
            label: 'Bass Boost',
            value: eq.bassBoost,
            max: AppConstants.bassBoostMax,
            color: const Color(0xFF6C63FF),
            onChanged: (v) => eq.setBassBoost(v),
          ),
          const SizedBox(height: 8),
          // Virtualizer
          _buildEffectRow(
            theme,
            icon: Icons.surround_sound_rounded,
            label: 'Surround',
            value: eq.virtualizer,
            max: AppConstants.virtualizerMax,
            color: AppColors.accent,
            onChanged: (v) => eq.setVirtualizer(v),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required double value,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(value: value, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value / max * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, EqualizerProvider eq) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Reset
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
              onPressed: () {
                HapticFeedback.mediumImpact();
                eq.reset();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save Preset
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Preset'),
              onPressed: () => _showSavePresetDialog(context, eq),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSavePresetDialog(BuildContext context, EqualizerProvider eq) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Custom Preset'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Preset name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                eq.saveCustomPreset(controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preset "${controller.text.trim()}" saved!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
