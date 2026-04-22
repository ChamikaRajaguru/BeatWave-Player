import 'dart:convert';

class EqPreset {
  final String name;
  final List<double> bandGains; // 5 bands
  final double bassBoost; // 0 - 1000
  final double virtualizer; // 0 - 1000
  final bool isBuiltIn;

  const EqPreset({
    required this.name,
    required this.bandGains,
    this.bassBoost = 0,
    this.virtualizer = 0,
    this.isBuiltIn = false,
  });

  EqPreset copyWith({
    String? name,
    List<double>? bandGains,
    double? bassBoost,
    double? virtualizer,
    bool? isBuiltIn,
  }) {
    return EqPreset(
      name: name ?? this.name,
      bandGains: bandGains ?? List.from(this.bandGains),
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'bandGains': bandGains,
    'bassBoost': bassBoost,
    'virtualizer': virtualizer,
    'isBuiltIn': isBuiltIn,
  };

  factory EqPreset.fromJson(Map<String, dynamic> json) => EqPreset(
    name: json['name'] as String,
    bandGains: (json['bandGains'] as List).cast<double>(),
    bassBoost: (json['bassBoost'] as num).toDouble(),
    virtualizer: (json['virtualizer'] as num).toDouble(),
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
  );

  String encode() => jsonEncode(toJson());

  factory EqPreset.decode(String source) =>
      EqPreset.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
