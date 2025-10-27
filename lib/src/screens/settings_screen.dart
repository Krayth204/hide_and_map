import 'package:flutter/material.dart';
import '../../main.dart';
import '../util/app_preferences.dart';
import '../util/geo_math.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _zoneController;
  late LengthSystem _lengthSystem;
  final _formKey = GlobalKey<FormState>();
  String _selectedPreset = 'custom';

  late LengthSystem _originalSystem;
  late double _originalZoneMeters;

  @override
  void initState() {
    super.initState();
    _lengthSystem = prefs.lengthSystem;
    _originalSystem = prefs.lengthSystem;
    _originalZoneMeters = prefs.hidingZoneSize;

    double displayValue = _originalZoneMeters;
    if (_lengthSystem == LengthSystem.imperial) {
      displayValue = GeoMath.metersToMiles(displayValue);
    }

    _zoneController = TextEditingController(text: displayValue.toStringAsFixed(2));
    _selectedPreset = _getMatchingPreset(displayValue);
  }

  String _getMatchingPreset(double value) {
    if (_lengthSystem == LengthSystem.metric) {
      if ((value - 500).abs() < 1) return '500m';
      if ((value - 1000).abs() < 1) return '1000m';
    } else {
      if ((value - 0.25).abs() < 0.01) return '0.25mi';
      if ((value - 0.5).abs() < 0.01) return '0.5mi';
    }
    return 'custom';
  }

  @override
  void dispose() {
    _zoneController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() ?? false) {
      double value = double.tryParse(_zoneController.text) ?? 0;
      double meters = value;

      if (_lengthSystem == LengthSystem.imperial) {
        meters = GeoMath.milesToMeters(value);
      }

      await prefs.setLengthSystem(_lengthSystem);
      await prefs.setHidingZoneSize(meters);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      _originalSystem = _lengthSystem;
      _originalZoneMeters = meters;
    }
  }

  bool _hasUnsavedChanges() {
    double currentMeters = double.tryParse(_zoneController.text) ?? 0;
    if (_lengthSystem == LengthSystem.imperial) {
      currentMeters = GeoMath.milesToMeters(currentMeters);
    }
    return _lengthSystem != _originalSystem ||
        (currentMeters - _originalZoneMeters).abs() > 0.001;
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges()) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Discard'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  String _getUnitSuffix() => _lengthSystem == LengthSystem.metric ? 'm' : 'mi';

  void _onPresetSelected(String preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case '500m':
          _zoneController.text = '500';
          break;
        case '1000m':
          _zoneController.text = '1000';
          break;
        case '0.25mi':
          _zoneController.text = '0.25';
          break;
        case '0.5mi':
          _zoneController.text = '0.5';
          break;
        case 'custom':
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await _confirmDiscardChanges();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings'), centerTitle: true),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.straighten, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Measurement System',
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<LengthSystem>(
                        initialValue: _lengthSystem,
                        items: const [
                          DropdownMenuItem(
                            value: LengthSystem.metric,
                            child: Text('Metric (m, km)'),
                          ),
                          DropdownMenuItem(
                            value: LengthSystem.imperial,
                            child: Text('Imperial (ft, mi)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null && _lengthSystem != value) {
                            setState(() {
                              double currentValue =
                                  double.tryParse(_zoneController.text) ?? 0;

                              double meters = (_lengthSystem == LengthSystem.imperial)
                                  ? GeoMath.milesToMeters(currentValue)
                                  : currentValue;

                              _lengthSystem = value;

                              double newDisplayValue =
                                  (_lengthSystem == LengthSystem.imperial)
                                  ? GeoMath.metersToMiles(meters)
                                  : meters;

                              if (_lengthSystem == LengthSystem.metric) {
                                if ((newDisplayValue - 0.25 * 1609.34).abs() < 10) {
                                  _selectedPreset = '500m';
                                  _zoneController.text = '500';
                                } else if ((newDisplayValue - 0.5 * 1609.34).abs() < 10) {
                                  _selectedPreset = '1000m';
                                  _zoneController.text = '1000';
                                } else {
                                  _selectedPreset = 'custom';
                                  _zoneController.text = newDisplayValue.toStringAsFixed(
                                    2,
                                  );
                                }
                              } else {
                                if ((meters - 500).abs() < 10) {
                                  _selectedPreset = '0.25mi';
                                  _zoneController.text = '0.25';
                                } else if ((meters - 1000).abs() < 10) {
                                  _selectedPreset = '0.5mi';
                                  _zoneController.text = '0.5';
                                } else {
                                  _selectedPreset = 'custom';
                                  _zoneController.text = newDisplayValue.toStringAsFixed(
                                    2,
                                  );
                                }
                              }
                            });
                          }
                        },

                        decoration: InputDecoration(
                          labelText: 'System',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Hiding Zone Size',
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select a preset or enter a custom radius (${_getUnitSuffix()}).',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 8,
                        children: (_lengthSystem == LengthSystem.metric)
                            ? [
                                ChoiceChip(
                                  label: const Text('500 m'),
                                  selected: _selectedPreset == '500m',
                                  onSelected: (_) => _onPresetSelected('500m'),
                                ),
                                ChoiceChip(
                                  label: const Text('1000 m'),
                                  selected: _selectedPreset == '1000m',
                                  onSelected: (_) => _onPresetSelected('1000m'),
                                ),
                                ChoiceChip(
                                  label: const Text('Custom'),
                                  selected: _selectedPreset == 'custom',
                                  onSelected: (_) => _onPresetSelected('custom'),
                                ),
                              ]
                            : [
                                ChoiceChip(
                                  label: const Text('0.25 mi'),
                                  selected: _selectedPreset == '0.25mi',
                                  onSelected: (_) => _onPresetSelected('0.25mi'),
                                ),
                                ChoiceChip(
                                  label: const Text('0.5 mi'),
                                  selected: _selectedPreset == '0.5mi',
                                  onSelected: (_) => _onPresetSelected('0.5mi'),
                                ),
                                ChoiceChip(
                                  label: const Text('Custom'),
                                  selected: _selectedPreset == 'custom',
                                  onSelected: (_) => _onPresetSelected('custom'),
                                ),
                              ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _zoneController,
                        enabled: _selectedPreset == 'custom',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Custom size (${_getUnitSuffix()})',
                          suffixText: _getUnitSuffix(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          final numValue = double.tryParse(value ?? '');
                          if (numValue == null || numValue <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
