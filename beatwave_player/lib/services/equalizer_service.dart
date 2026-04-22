import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/eq_preset_model.dart';
import '../core/constants.dart';

/// Platform channel-based equalizer service for Android native
/// Equalizer, BassBoost, and Virtualizer effects.
class EqualizerService {
  static const _channel = MethodChannel('com.beatwave.equalizer');

  bool _isEnabled = false;
  List<double> _bandGains = List.filled(5, 0.0);
  double _bassBoost = 0;
  double _virtualizer = 0;

  bool get isEnabled => _isEnabled;
  List<double> get bandGains => _bandGains;
  double get bassBoost => _bassBoost;
  double get virtualizer => _virtualizer;

  /// Initialize the equalizer with the audio session ID from just_audio
  Future<void> init(int audioSessionId) async {
    try {
      await _channel.invokeMethod('init', {'audioSessionId': audioSessionId});
      _isEnabled = true;
    } on PlatformException catch (e) {
      debugPrint('Equalizer init failed: ${e.message}');
      _isEnabled = false;
    }
  }

  /// Enable/disable the equalizer
  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setEnabled', {'enabled': enabled});
      _isEnabled = enabled;
    } on PlatformException catch (e) {
      debugPrint('Equalizer setEnabled failed: ${e.message}');
    }
  }

  /// Set a specific band gain (-15 to +15 dB)
  Future<void> setBandGain(int bandIndex, double gain) async {
    if (bandIndex < 0 || bandIndex >= AppConstants.eqBandCount) return;
    _bandGains[bandIndex] = gain.clamp(
      AppConstants.eqMinLevel,
      AppConstants.eqMaxLevel,
    );
    try {
      await _channel.invokeMethod('setBandLevel', {
        'band': bandIndex,
        'level': (_bandGains[bandIndex] * 100).round(), // millibels
      });
    } on PlatformException catch (e) {
      debugPrint('EQ setBandGain failed: ${e.message}');
    }
  }

  /// Apply all band gains at once
  Future<void> applyAllBands(List<double> gains) async {
    _bandGains = List.from(gains);
    for (int i = 0; i < gains.length && i < AppConstants.eqBandCount; i++) {
      await setBandGain(i, gains[i]);
    }
  }

  /// Set bass boost strength (0 - 1000)
  Future<void> setBassBoost(double strength) async {
    _bassBoost = strength.clamp(0, AppConstants.bassBoostMax);
    try {
      await _channel.invokeMethod('setBassBoost', {
        'strength': _bassBoost.round(),
      });
    } on PlatformException catch (e) {
      debugPrint('BassBoost failed: ${e.message}');
    }
  }

  /// Set virtualizer strength (0 - 1000)
  Future<void> setVirtualizer(double strength) async {
    _virtualizer = strength.clamp(0, AppConstants.virtualizerMax);
    try {
      await _channel.invokeMethod('setVirtualizer', {
        'strength': _virtualizer.round(),
      });
    } on PlatformException catch (e) {
      debugPrint('Virtualizer failed: ${e.message}');
    }
  }

  /// Apply a preset
  Future<void> applyPreset(EqPreset preset) async {
    await applyAllBands(preset.bandGains);
    await setBassBoost(preset.bassBoost);
    await setVirtualizer(preset.virtualizer);
  }

  /// Reset all effects to defaults
  Future<void> reset() async {
    await applyAllBands(List.filled(5, 0.0));
    await setBassBoost(0);
    await setVirtualizer(0);
  }

  /// Release resources
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('release');
    } on PlatformException catch (e) {
      debugPrint('Equalizer release failed: ${e.message}');
    }
  }
}
