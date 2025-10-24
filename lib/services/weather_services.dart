import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_models.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  final String apikey;

  WeatherServices([String? key])
      : apikey = key ?? const String.fromEnvironment('OWM_API_KEY');

  Future<List> getCurrentLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    debugPrint(pos.toString());
    return [pos.latitude, pos.longitude];
  }

  Future<Weather> getWeather(List pos, {String units = 'metric'}) async {
    final params = <String, String>{
      'lat': pos[0].toString(),
      'lon': pos[1].toString(),
      'appid': apikey,
    };
    if (units != 'standard') {
      params['units'] = units; 
    }
    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      params,
    );
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      debugPrint(
        'Current location weather failed: ${res.statusCode} ${res.body}',
      );
      throw Exception("Failed to load weather data");
    }
  }

  Future<Weather> getByCityCountry({
    required String city,
    required String countryCode,
    String units = 'metric',
  }) async {
    final params = <String, String>{'q': '$city,$countryCode', 'appid': apikey};

    if (units != 'standard') {
      params['units'] = units;
    }

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      params,
    );
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      debugPrint('City search failed: ${res.statusCode} ${res.body}');
      throw Exception("Failed to load weather data (city search)");
    }
  }

  Future<Weather> getByZipCountry({
    required String zip,
    required String countryCode,
    String units = 'metric',
  }) async {
    final params = <String, String>{
      'zip': '$zip,$countryCode',
      'appid': apikey,
    };

    if (units != 'standard') {
      params['units'] = units;
    }

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      params,
    );
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      debugPrint('Zip search failed: ${res.statusCode} ${res.body}');
      throw Exception("Failed to load weather data (zip search)");
    }
  }

  Future<Weather> getByLatLon({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final params = <String, String>{
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': apikey,
    };

    if (units != 'standard') {
      params['units'] = units;
    }

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      params,
    );
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      debugPrint('Lat/Lon search failed: ${res.statusCode} ${res.body}');
      throw Exception("Failed to load weather data (lat/lon search)");
    }
  }
}
