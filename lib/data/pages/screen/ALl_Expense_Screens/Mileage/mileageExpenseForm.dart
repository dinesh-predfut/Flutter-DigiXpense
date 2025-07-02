// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MileageRegistrationPage extends StatefulWidget {
  const MileageRegistrationPage({super.key});

  @override
  State<MileageRegistrationPage> createState() =>
      _MileageRegistrationPageState();
}

class _MileageRegistrationPageState extends State<MileageRegistrationPage> {
  final List<TextEditingController> _startControllers = [
    TextEditingController(text: "Bangalore")
  ];
  final List<TextEditingController> _endControllers = [
    TextEditingController(text: "Delhi")
  ];

  final List<LatLng> _startCoords = [];
  final List<LatLng> _endCoords = [];

  double totalDistanceKm = 0;
  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    _calculateAllDistances();
  }

  Future<void> _calculateAllDistances() async {
    _startCoords.clear();
    _endCoords.clear();
    totalDistanceKm = 0;

    for (int i = 0; i < _startControllers.length; i++) {
      String startCity = _startControllers[i].text.trim();
      String endCity = _endControllers[i].text.trim();

      try {
        List<Location> startLoc = await locationFromAddress(startCity);
        List<Location> endLoc = await locationFromAddress(endCity);

        if (startLoc.isNotEmpty && endLoc.isNotEmpty) {
          LatLng startLatLng =
              LatLng(startLoc.first.latitude, startLoc.first.longitude);
          LatLng endLatLng =
              LatLng(endLoc.first.latitude, endLoc.first.longitude);

          _startCoords.add(startLatLng);
          _endCoords.add(endLatLng);

          totalDistanceKm +=
              distance.as(LengthUnit.Kilometer, startLatLng, endLatLng);
        } else {
          debugPrint("Invalid city: $startCity or $endCity");
          _showErrorSnackBar(
              "Could not find location for: $startCity or $endCity");
        }
      } catch (e) {
        debugPrint("Location Error: $e");
        _showErrorSnackBar("Location Error for $startCity or $endCity");
      }
    }

    setState(() {});
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _addTrip() {
    setState(() {
      _startControllers.add(TextEditingController());
      _endControllers.add(TextEditingController());
    });
  }

  void _removeTrip(int index) {
    setState(() {
      _startControllers.removeAt(index);
      _endControllers.removeAt(index);
    });
    _calculateAllDistances();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F1C44),
                Color(0xFF2E3C85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Mileage Registration',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          // HEADER
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0F1C44), Color(0xFF2E3C85)]),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _startControllers.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle_outlined,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _startControllers[index],
                                    onChanged: (_) => _calculateAllDistances(),
                                    decoration: InputDecoration(
                                      hintText: "Start Trip ${index + 1}",
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _endControllers[index],
                                    onChanged: (_) => _calculateAllDistances(),
                                    decoration: InputDecoration(
                                      hintText: "End Trip ${index + 1}",
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_startControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () => _removeTrip(index),
                                  )
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.white, size: 30),
                        onPressed: _addTrip,
                      ),
                    ),
                    Row(
                      children: [
                        const Text("Round Trip",
                            style: TextStyle(color: Colors.white)),
                        Switch(
                          value: false,
                          onChanged: (_) {},
                          activeColor: Colors.pinkAccent,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoCard("Total Distance KM",
                            "${totalDistanceKm.toStringAsFixed(2)} Km"),
                        // ignore: unnecessary_string_interpolations
                        _infoCard("Total Amount in USD",
                            "${(totalDistanceKm * 0.5).toStringAsFixed(0)}"),
                        _infoCard("Total Amount in INR",
                            (totalDistanceKm * 40).toStringAsFixed(0)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // MAP SECTION
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                // ignore: deprecated_member_use
                center: _startCoords.isNotEmpty
                    ? _startCoords[0]
                    : const LatLng(20.5937, 78.9629),
                // ignore: deprecated_member_use
                zoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    for (var coord in _startCoords)
                      Marker(
                        point: coord,
                        child:
                            const Icon(Icons.location_on, color: Colors.green),
                      ),
                    for (var coord in _endCoords)
                      Marker(
                        point: coord,
                        child: const Icon(Icons.flag, color: Colors.red),
                      ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    for (int i = 0; i < _startCoords.length; i++)
                      Polyline(
                        points: [_startCoords[i], _endCoords[i]],
                        strokeWidth: 3,
                        color: Colors.blue,
                      )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Icon(Icons.directions_car, color: Colors.blue),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
