import 'package:flutter/material.dart';
import 'package:weatherapp/app_settings.dart';

class SettingsUnitsPage extends StatefulWidget {
  const SettingsUnitsPage({super.key});

  @override
  State<SettingsUnitsPage> createState() => _SettingsUnitsPageState();
}

class _SettingsUnitsPageState extends State<SettingsUnitsPage> {
  String _tempUnits = AppSettings.units.value; 

  void _save() {
    AppSettings.units.value = _tempUnits; 
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved default units')),
    );
  }

  Widget _buildRadio(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _tempUnits,
      onChanged: (v) => setState(() => _tempUnits = v!),
      title: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings: Units')),
      body: ListView(
        children: [
          _buildRadio('metric', 'Celsius (°C)'),
          _buildRadio('imperial', 'Fahrenheit (°F)'),
          _buildRadio('standard', 'Kelvin (K)'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
