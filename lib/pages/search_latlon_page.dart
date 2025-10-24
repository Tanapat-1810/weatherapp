import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather_services.dart';
import 'package:weatherapp/models/weather_models.dart';
import 'package:weatherapp/app_settings.dart';

class SearchLatLonPage extends StatefulWidget {
  const SearchLatLonPage({super.key});

  @override
  State<SearchLatLonPage> createState() => _SearchLatLonPageState();
}

class _SearchLatLonPageState extends State<SearchLatLonPage> {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  String _units = AppSettings.units.value;
  final _service = WeatherServices();

  bool _loading = false;
  Weather? _result;

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  double? _parseNum(String s) {
    try {
      return double.parse(s.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = _parseNum(_latController.text)!;
    final lon = _parseNum(_lonController.text)!;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final weather = await _service.getByLatLon(
        lat: lat,
        lon: lon,
        units: _units,
      );
      setState(() => _result = weather);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateLat(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter latitude';
    final d = _parseNum(v);
    if (d == null) return 'Latitude must be a number';
    if (d < -90 || d > 90) return 'Latitude must be between -90 and 90';
    return null;
  }

  String? _validateLon(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter longitude';
    final d = _parseNum(v);
    if (d == null) return 'Longitude must be a number';
    if (d < -180 || d > 180) return 'Longitude must be between -180 and 180';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search: Latitude and Longitude')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g. 13.7563',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: _validateLat,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lonController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g. 100.5018',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: _validateLon,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Units:'),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: AppSettings.units,
                    builder: (_, defaultUnits, __) {
                      final label = defaultUnits == 'metric'
                          ? '°C'
                          : defaultUnits == 'imperial'
                          ? '°F'
                          : 'K';
                      return Text(
                        'Default: $label',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSubmit,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
              const SizedBox(height: 24),
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (!_loading && _result != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'City: ${_result!.cityName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Condition: ${_result!.mainCondition}'),
                        const SizedBox(height: 8),
                        Text(
                          'Temperature: ${_result!.temperature.toStringAsFixed(1)}'
                          '${_units == "metric"
                              ? " °C"
                              : _units == "imperial"
                              ? " °F"
                              : " K"}',
                        ),
                      ],
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
