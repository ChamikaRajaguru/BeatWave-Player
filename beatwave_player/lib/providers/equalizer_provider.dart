import 'package:flutter/material.dart';
import '../models/eq_preset_model.dart';
import '../services/equalizer_service.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class EqualizerProvider extends ChangeNotifier {
  final EqualizerService _eqService;
  final StorageService _storageService;

  bool _isEnabled = false;
  String _currentPresetName = 'Normal';
  List<double> _bandGains = List.filled(5, 0.0);
  double _bassBoost = 0;
  double _virtualizer = 0;
  List<EqPreset> _customPresets = [];
  bool _isInitialized = false;

  EqualizerProvider(this._eqService, this._storageService) {
    _customPresets = _storageService.customEqPresets;
    final lastPreset = _storageService.lastEqPreset;
    if (lastPreset != null) {
      _currentPresetName = lastPreset;
    }
  }

  // ─── Getters ──────────────────────────────────────────────────
  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;
  String get currentPresetName => _currentPresetName;
  List<double> get bandGains => _bandGains;
  double get bassBoost => _bassBoost;
  double get virtualizer => _virtualizer;
  List<EqPreset> get customPresets => _customPresets;

  List<String> get allPresetNames => [
    ...EqPresets.builtIn.keys,
    ..._customPresets.map((p) => p.name),
  ];

  // ─── Initialize with audio session ───────────────────────────
  Future<void> init(int audioSessionId) async {
    await _eqService.init(audioSessionId);
    _isInitialized = true;
    _isEnabled = _eqService.isEnabled;

    // Apply last used preset
    if (EqPresets.builtIn.containsKey(_currentPresetName)) {
      await applyPreset(_currentPresetName);
    }

    notifyListeners();
  }

  // ─── Enable / Disable ────────────────────────────────────────
  Future<void> setEnabled(bool enabled) async {
    await _eqService.setEnabled(enabled);
    _isEnabled = enabled;
    notifyListeners();
  }

  // ─── Band Control ────────────────────────────────────────────
  Future<void> setBandGain(int bandIndex, double gain) async {
    _bandGains[bandIndex] = gain;
    _currentPresetName = 'Custom';
    await _eqService.setBandGain(bandIndex, gain);
    notifyListeners();
  }

  // ─── Bass Boost ──────────────────────────────────────────────
  Future<void> setBassBoost(double value) async {
    _bassBoost = value;
    await _eqService.setBassBoost(value);
    notifyListeners();
  }

  // ─── Virtualizer ─────────────────────────────────────────────
  Future<void> setVirtualizer(double value) async {
    _virtualizer = value;
    await _eqService.setVirtualizer(value);
    notifyListeners();
  }

  // ─── Presets ──────────────────────────────────────────────────
  Future<void> applyPreset(String name) async {
    _currentPresetName = name;
    await _storageService.setLastEqPreset(name);

    // Check built-in first
    if (EqPresets.builtIn.containsKey(name)) {
      final gains = EqPresets.builtIn[name]!;
      _bandGains = List.from(gains);
      _bassBoost = 0;
      _virtualizer = 0;
      await _eqService.applyPreset(
        EqPreset(name: name, bandGains: gains, isBuiltIn: true),
      );
    } else {
      // Check custom presets
      try {
        final preset = _customPresets.firstWhere((p) => p.name == name);
        _bandGains = List.from(preset.bandGains);
        _bassBoost = preset.bassBoost;
        _virtualizer = preset.virtualizer;
        await _eqService.applyPreset(preset);
      } catch (_) {}
    }

    notifyListeners();
  }

  // ─── Save Custom Preset ──────────────────────────────────────
  Future<void> saveCustomPreset(String name) async {
    final preset = EqPreset(
      name: name,
      bandGains: List.from(_bandGains),
      bassBoost: _bassBoost,
      virtualizer: _virtualizer,
    );

    // Replace if exists
    _customPresets.removeWhere((p) => p.name == name);
    _customPresets.add(preset);
    _currentPresetName = name;

    await _storageService.saveCustomEqPresets(_customPresets);
    await _storageService.setLastEqPreset(name);
    notifyListeners();
  }

  // ─── Delete Custom Preset ────────────────────────────────────
  Future<void> deleteCustomPreset(String name) async {
    _customPresets.removeWhere((p) => p.name == name);
    await _storageService.saveCustomEqPresets(_customPresets);
    if (_currentPresetName == name) {
      await applyPreset('Normal');
    }
    notifyListeners();
  }

  // ─── Reset ────────────────────────────────────────────────────
  Future<void> reset() async {
    await _eqService.reset();
    _bandGains = List.filled(5, 0.0);
    _bassBoost = 0;
    _virtualizer = 0;
    _currentPresetName = 'Flat';
    notifyListeners();
  }
}
