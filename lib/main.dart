import 'package:flutter/material.dart';
import 'package:weatherapp/pages/weather_pages.dart';
import 'package:weatherapp/theme/app_theme.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: AppTheme.light,        
      darkTheme: AppTheme.dark,     
      themeMode: ThemeMode.system,   
      home: const WeatherPages(),
      debugShowCheckedModeBanner: false,
    );
  }
}
