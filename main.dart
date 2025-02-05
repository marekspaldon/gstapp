import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_signal_strength/flutter_signal_strength.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';

postData(String signal, String name, String latitude, String longitude, String time) async {
  try {
    var response = await http.post(
      Uri.parse('https://gstapp.panska.cz/receive.php'),
      body: {
        "signal": signal,
        "name": name,
        "latitude": latitude,
        "longtitude": longitude,
        "time": time,
      },
    );
    print('Response: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSTAPP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GSTAPP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = "";
  final TextEditingController _controller = TextEditingController();
  Location location = Location();

  String signalStrength = "";
  String sentName = "";
  String sentLatitude = "";
  String sentLongitude = "";
  String sentTime = "";

  Future<LocationData?> _getLocation() async {
    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    await location.requestPermission();

    return await location.getLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF005b96),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                style: const TextStyle(
                  color: Colors.black, // TextField text color
                ),
                decoration: const InputDecoration(
                  hintText: 'Jméno měření',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0), // TextField hint text color
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // TextField border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // TextField focused border color
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Signal: $signalStrength",
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Text color white
                      ),
                      Text(
                        "Name: $sentName",
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Text color white
                      ),
                      Text(
                        "Latitude: $sentLatitude",
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Text color white
                      ),
                      Text(
                        "Longitude: $sentLongitude",
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Text color white
                      ),
                      Text(
                        "Time: $sentTime",
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Text color white
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    await Permission.location.request();
                    LocationData? locationData = await _getLocation();
                    final signalStrengthInstance = FlutterSignalStrength();
                    final signal = await signalStrengthInstance.getCellularSignalStrengthDbm();

                    if (locationData != null) {
                      String latitude = locationData.latitude.toString();
                      String longitude = locationData.longitude.toString();
                      int timestamp = locationData.time!.toInt();
                      String time = DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String();

                      setState(() {
                        signalStrength = signal.toString();
                        sentName = name;
                        sentLatitude = latitude;
                        sentLongitude = longitude;
                        sentTime = time;
                      });

                      postData(signal.toString(), name, latitude, longitude, time);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location or signal not available')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white, // Button text color
                    ),
                  ),
                  child: const Text('Odeslat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}