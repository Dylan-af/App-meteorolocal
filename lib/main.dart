
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

// Imports de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

import 'theme.dart';

// --- MODELO DE DATOS ---

class Weather {
  final double temperature;
  final double humidity;
  final String condition;
  final IconData icon;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.icon,
  });

  // Un constructor de fábrica para crear un Weather desde un mapa (lo que obtenemos de Firebase)
  factory Weather.fromMap(Map<dynamic, dynamic> map) {
    final double temp = (map['temperature'] as num?)?.toDouble() ?? 0.0;
    final double humidity = (map['humidity'] as num?)?.toDouble() ?? 0.0;

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
      condition: condition,
      icon: icon,
    );
  }
}

// --- SERVICIO DE DATOS ---

class WeatherService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sensor_data');

  // Stream para escuchar los cambios en tiempo real
  Stream<Weather> getWeatherStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        throw Exception('No se encontraron datos en la ruta especificada.');
      }
      return Weather.fromMap(data);
    });
  }

  // El pronóstico sigue siendo simulado
  final Random _random = Random();
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

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  List<Map<String, dynamic>> _forecast = [];
  StreamSubscription<Weather>? _weatherSubscription;
  String? _errorMessage;

  Weather? get weather => _weather;
  List<Map<String, dynamic>> get forecast => _forecast;
  bool get isLoading => _weather == null && _errorMessage == null;
  String? get errorMessage => _errorMessage;

  WeatherProvider() {
    _listenToWeatherUpdates();
    _forecast = _weatherService.getForecast(); // El pronóstico no cambia en tiempo real
  }

  void _listenToWeatherUpdates() {
    _weatherSubscription = _weatherService.getWeatherStream().listen((weatherData) {
      _weather = weatherData;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }
  
  // Función para refrescar manualmente el pronóstico (si quisiéramos)
  void refreshForecast(){
      _forecast = _weatherService.getForecast();
      notifyListeners();
  }

  @override
  void dispose() {
    _weatherSubscription?.cancel();
    super.dispose();
  }
}


// --- PUNTO DE ENTRADA DE LA APLICACIÓN ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MyApp(),
    ),
  );
}

// El resto de la UI (MyApp, HomePage, etc.) no necesita cambios significativos por ahora.


/// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estación Meteorológica',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, 
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- PANTALLA PRINCIPAL ---

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
       body: Center(
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary));
              } else if (provider.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: No se pudieron cargar los datos.\nVerifica tu conexión y que el ESP32 esté enviando datos a la ruta correcta en Firebase.\n\nDetalle: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async => provider.refreshForecast(),
                  backgroundColor: colorScheme.primary,
                  color: colorScheme.onPrimary,
                  child: _buildWeatherContent(context, provider),
                );
              }
            },
          ),
        ),
    );
  }

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWeatherDetail(context, 'Humedad', '${weather.humidity.toStringAsFixed(1)}%', Icons.water_drop_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
