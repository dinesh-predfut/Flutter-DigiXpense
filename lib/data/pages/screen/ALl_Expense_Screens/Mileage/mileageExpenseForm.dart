import 'dart:async';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
  final controller = Get.put(Controller());
  final List<LatLng> _startCoords = [];
  final List<LatLng> _endCoords = [];

  double totalDistanceKm = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _calculateAllDistances();
    controller.checkAndRequestPermission();
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

          totalDistanceKm += Geolocator.distanceBetween(
                startLatLng.latitude,
                startLatLng.longitude,
                endLatLng.latitude,
                endLatLng.longitude,
              ) /
              1000;
        } else {
          _showErrorSnackBar(
              "Could not find location for: $startCity or $endCity");
        }
      } catch (e) {
        _showErrorSnackBar("Location Error for $startCity or $endCity");
      }
    }

    if (mounted) setState(() {});
  }

  void _onTripTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _calculateAllDistances();
    });
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
  void dispose() {
    _debounce?.cancel();
    for (var controller in _startControllers) {
      controller.dispose();
    }
    for (var controller in _endControllers) {
      controller.dispose();
    }
    super.dispose();
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
              colors: [Color(0xFF0F1C44), Color(0xFF2E3C85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Mileage Registration',
                style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section
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
                                  child: FutureBuilder<List<String>>(
                                    future: controller.fetchPlaceSuggestions(
                                        _startControllers[index].text),
                                    builder: (context, snapshot) {
                                      return Autocomplete<String>(
                                        initialValue: TextEditingValue(
                                            text:
                                                _startControllers[index].text),
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) async {
                                          if (textEditingValue.text == '') {
                                            return const Iterable<
                                                String>.empty();
                                          }
                                          return await controller
                                              .fetchPlaceSuggestions(
                                                  textEditingValue.text);
                                        },
                                        onSelected: (String selection) {
                                          _startControllers[index].text =
                                              selection;
                                          _onTripTextChanged();
                                        },
                                        fieldViewBuilder: (context, controller,
                                            focusNode, onFieldSubmitted) {
                                          return TextField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Start Trip ${index + 1}",
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (_) =>
                                                _onTripTextChanged(),
                                          );
                                        },
                                      );
                                    },
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
                                    onChanged: (_) => _onTripTextChanged(),
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoCard("Total Distance KM",
                            "${totalDistanceKm.toStringAsFixed(2)} Km"),
                        _infoCard("Total Amount (USD)",
                            "${(totalDistanceKm * 0.5).toStringAsFixed(0)}"),
                        _infoCard("Total Amount (INR)",
                            "${(totalDistanceKm * 40).toStringAsFixed(0)}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map Section
          const SizedBox(
            height: 300, // or MediaQuery.of(context).size.height * 0.5
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(20.5937, 78.9629),
                zoom: 5,
              ),
              zoomControlsEnabled: true,
              myLocationEnabled: true,
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
