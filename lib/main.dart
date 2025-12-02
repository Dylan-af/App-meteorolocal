
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

import 'theme.dart';

// --- MODELO DE DATOS ---

/// Representa una lectura meteorológica con temperatura, humedad, presión,
/// condición climática y un icono asociado.
class Weather {
  final double temperature;
  final double humidity;
  final double pressure;
  final String condition;
  final IconData icon;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.condition,
    required this.icon,
  });
}

// --- SERVICIO DE DATOS ---

/// Simula la obtención de datos meteorológicos desde una fuente externa (como el ESP32).
class WeatherService {
  final Random _random = Random();

  /// Simula una llamada a una API para obtener los datos meteorológicos actuales.
  Future<Weather> fetchWeather() {
    // Simula un retardo de red para emular una llamada asíncrona.
    return Future.delayed(const Duration(seconds: 1), () {
      final temp = 15 + _random.nextDouble() * 10; // Rango: 15-25°C
      final humidity = 40 + _random.nextDouble() * 20; // Rango: 40-60%
      final pressure = 1000 + _random.nextDouble() * 20; // Rango: 1000-1020 hPa

      String condition;
      IconData icon;
      if (temp > 22) {
        condition = 'Soleado';
        icon = Icons.wb_sunny;
      } else if (temp < 18) {
        condition = 'Nublado';
        icon = Icons.cloud;
      } else {
        condition = 'Parcialmente Nublado';
        icon = Icons.wb_cloudy;
      }

      return Weather(
        temperature: temp,
        humidity: humidity,
        pressure: pressure,
        condition: condition,
        icon: icon,
      );
    });
  }

  /// Genera un pronóstico del tiempo simulado para los próximos 5 días.
  List<Map<String, dynamic>> getForecast() {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
    return List.generate(5, (index) {
      final temp = 15 + _random.nextDouble() * 10;
      IconData icon;
      if (temp > 22) {
        icon = Icons.wb_sunny;
      } else if (temp < 18) {
        icon = Icons.cloud;
      } else {
        icon = Icons.wb_cloudy;
      }
      return {
        'day': days[index],
        'icon': icon,
        'temp': temp.toStringAsFixed(1),
      };
    });
  }
}

// --- GESTOR DE ESTADO (PROVIDER) ---

/// Gestiona el estado de los datos meteorológicos, notificando a los oyentes cuando hay cambios.
class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = false;

  Weather? get weather => _weather;
  List<Map<String, dynamic>> get forecast => _forecast;
  bool get isLoading => _isLoading;

  WeatherProvider() {
    fetchWeather();
  }

  /// Obtiene los datos meteorológicos y el pronóstico, y notifica a los oyentes.
  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();
    _weather = await _weatherService.fetchWeather();
    _forecast = _weatherService.getForecast();
    _isLoading = false;
    notifyListeners();
  }
}

// --- PUNTO DE ENTRADA DE LA APLICACIÓN ---

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MyApp(),
    ),
  );
}

/// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estación Meteorológica',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Alternar entre .light y .dark para probar
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- PANTALLA PRINCIPAL ---

/// Muestra la interfaz principal de la aplicación.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estación Meteorológica',
          style: textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: weatherProvider.fetchWeather,
        backgroundColor: colorScheme.primary,
        color: colorScheme.onPrimary,
        child: Center(
          child: weatherProvider.isLoading
              ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary))
              : _buildWeatherContent(context, weatherProvider),
        ),
      ),
    );
  }

  /// Construye el contenido principal cuando los datos del tiempo están disponibles.
  Widget _buildWeatherContent(BuildContext context, WeatherProvider weatherProvider) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Ahora', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (weatherProvider.weather != null)
            _buildCurrentWeather(context, weatherProvider.weather!),
          const SizedBox(height: 40),
          Text('Pronóstico Semanal', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (weatherProvider.forecast.isNotEmpty)
            _buildForecast(context, weatherProvider.forecast),
        ],
      ),
    );
  }

  /// Construye la tarjeta que muestra el tiempo actual.
  Widget _buildCurrentWeather(BuildContext context, Weather weather) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(weather.icon, size: 80, color: colorScheme.primary),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
                    ),
                    Text(
                      weather.condition,
                      style: textTheme.headlineMedium?.copyWith(color: textTheme.bodyMedium?.color?.withAlpha(180)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(context, 'Humedad', '${weather.humidity.toStringAsFixed(1)}%', Icons.water_drop_outlined),
                _buildWeatherDetail(context, 'Presión', '${weather.pressure.toStringAsFixed(1)} hPa', Icons.compress),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un widget para mostrar un detalle del tiempo (humedad, presión, etc.).
  Widget _buildWeatherDetail(BuildContext context, String label, String value, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 8),
        Text(label, style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withAlpha(180))),
        const SizedBox(height: 4),
        Text(value, style: textTheme.labelLarge),
      ],
    );
  }

  /// Construye la lista horizontal para el pronóstico semanal.
  Widget _buildForecast(BuildContext context, List<Map<String, dynamic>> forecast) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final dayForecast = forecast[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 110,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    dayForecast['day'],
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Icon(dayForecast['icon'], size: 32, color: colorScheme.primary),
                  Text('${dayForecast['temp']}°C', style: textTheme.labelLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
