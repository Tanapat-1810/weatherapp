import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather_services.dart';
import 'package:weatherapp/models/weather_models.dart';
import 'package:weatherapp/app_settings.dart';

class SearchZipCountryPage extends StatefulWidget {
  const SearchZipCountryPage({super.key});

  @override
  State<SearchZipCountryPage> createState() => _SearchZipCountryPageState();
}

class _SearchZipCountryPageState extends State<SearchZipCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _zipController = TextEditingController();

  final List<Map<String, String>> _countries = const [
    {'code': 'TH', 'name': 'Thailand'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'GB', 'name': 'United Kingdom'},
  ];
  String _selectedCountry = 'TH';

  String _units = AppSettings.units.value;

  final _service = WeatherServices();
  bool _loading = false;
  Weather? _result;

  @override
  void dispose() {
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final zip = _zipController.text.trim();
    final country = _selectedCountry;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final weather = await _service.getByZipCountry(
        zip: zip,
        countryCode: country,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search: Zip and Country')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ZIP
              TextFormField(
                controller: _zipController,
                decoration: const InputDecoration(
                  labelText: 'ZIP / Postal Code',
                  hintText: 'e.g. 10110',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a ZIP/Postal code';
                  }
                  if (v.trim().length < 3) {
                    return 'ZIP seems too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                items: _countries
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['code'],
                        child: Text('${c['name']} (${c['code']})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedCountry = v);
                },
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
                    padding: const EdgeInsets.all(16.0),
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
