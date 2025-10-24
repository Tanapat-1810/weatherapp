import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather_services.dart';
import 'package:weatherapp/models/weather_models.dart';
import 'package:weatherapp/app_settings.dart';


class SearchCityCountryPage extends StatefulWidget {
  const SearchCityCountryPage({super.key});

  @override
  State<SearchCityCountryPage> createState() => _SearchCityCountryPageState();
}

class _SearchCityCountryPageState extends State<SearchCityCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _service = WeatherServices();
  bool _loading = false;
  Weather? _result;
  String _units = AppSettings.units.value;


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

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
  void _onSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  final city = _cityController.text.trim();
  final country = _selectedCountry;

  setState(() {
    _loading = true;
    _result = null;
  });

  try {
    final weather = await _service.getByCityCountry(
      city: city,
      countryCode: country,
      units: _units,
    );
    setState(() {
      _result = weather;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search failed: $e')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search: City and Country')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'e.g. Bangkok',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a city';
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
                    .map((c) => DropdownMenuItem<String>(
                          value: c['code'],
                          child: Text('${c['name']} (${c['code']})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCountry = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSubmit,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 24),
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (!_loading && _result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('City: ${_result!.cityName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Condition: ${_result!.mainCondition}'),
                      const SizedBox(height: 8),
                      Text('Temperature: ${_result!.temperature.toStringAsFixed(1)}'
                      '${_units == 'metric' ? ' °C' : _units == 'imperial' ? ' °F' : ' K'}'),
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
