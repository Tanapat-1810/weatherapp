import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:weatherapp/models/weather_models.dart';
import 'package:weatherapp/pages/search_city_country_page.dart';
import 'package:weatherapp/services/weather_services.dart';
import 'package:weatherapp/pages/search_zip_country_page.dart';
import 'package:weatherapp/pages/search_latlon_page.dart';
import 'package:weatherapp/pages/settings_units_page.dart';
import 'package:weatherapp/app_settings.dart';

class WeatherPages extends StatefulWidget {
  const WeatherPages({super.key});

  @override
  State<WeatherPages> createState() => _WeatherPagesState();
}

class _WeatherPagesState extends State<WeatherPages> {
  final _weatherServices = WeatherServices();
  late final VoidCallback _unitsListener;

  Weather? _weather;

  Future<void> _fetchWeather(String units) async {
    List pos = await _weatherServices.getCurrentLocation();
    try {
      final weather = await _weatherServices.getWeather(pos, units: units);
      if (!mounted) return;
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchWeather(AppSettings.units.value);
    _unitsListener = () => _fetchWeather(AppSettings.units.value);
    AppSettings.units.addListener(_unitsListener);
  }

  @override
  void dispose() {
    AppSettings.units.removeListener(_unitsListener);
    super.dispose();
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return "assets/lotties/loading.json";
    switch (mainCondition.toLowerCase()) {
      case "clouds":
      case "fog":
      case "mist":
      case "smoke":
      case "dust":
      case "haze":
        return "assets/lotties/cloudy.json";
      case "rain":
      case "drizzle":
      case "shower rain":
        return "assets/lotties/rainy.json";
      case "thunderstorm":
        return "assets/lotties/thunder.json";
      default:
        return "assets/lotties/sunny.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: scheme.primaryContainer),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('City and Country'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchCityCountryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_post_office),
              title: const Text('Zip and Country'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchZipCountryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Latitude and Longitude'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchLatLonPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Units'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsUnitsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;

          final lottieMaxHeight = h * 0.35;
          final lottieMaxWidth = w * 0.8;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    "assets/lotties/location.json",
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _weather?.cityName ?? "Loading City...",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: lottieMaxHeight,
                      maxWidth: lottieMaxWidth,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 500,
                        height: 500,
                        child: Lottie.asset(
                          getWeatherAnimation(_weather?.mainCondition),
                        ),
                      ),
                    ),
                  ),

                  ValueListenableBuilder<String>(
                    valueListenable: AppSettings.units,
                    builder: (_, units, __) {
                      final unitLabel = units == 'metric'
                          ? '°C'
                          : units == 'imperial'
                          ? '°F'
                          : 'K';
                      final temp = _weather?.temperature;
                      final text = (temp == null)
                          ? '...'
                          : '${temp.round()} $unitLabel';
                      return Text(text, style: Theme.of(context).textTheme.titleLarge,);
                    },
                  ),

                  const SizedBox(height: 20),
                  Text(_weather?.mainCondition ?? "", style: Theme.of(context).textTheme.titleMedium,),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
