import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/core/constant/url.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';

import '../../../../../core/comman/widgets/pageLoaders.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../service.dart';

class HubMileageSecondFrom extends StatefulWidget {
  final bool isEditMode;
  final ExpenseModelMileage? mileageId;
  const HubMileageSecondFrom({
    Key? key,
    this.isEditMode = false,
    this.mileageId,
  }) : super(key: key);

  @override
  State<HubMileageSecondFrom> createState() => _HubMileageSecondFromState();
}

class _HubMileageSecondFromState extends State<HubMileageSecondFrom> {
  List<String> vehicleTypes = []; // Dropdown values from API
  String selectedVehicleType = ""; // Currently selected type
  List<Map<String, dynamic>> mileageRateLines = [];
  bool isSubmitAttempted = false;
  final controller = Get.put(Controller());
  MapType _currentMapType = MapType.normal; // Start with Normal map
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool isEditMode = true;
  // bool shouldShow = false;
  RxBool shouldShow = false.obs;
  late final int workitemrecid;
  // double controller.totalDistanceKm = 0;

  Timer? _debounce;

  final String googleApiKey =
      'AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0'; // Replace with your API key
  @override
  void initState() {
    super.initState();
    if (controller.totalDistanceKm != 0) {
      _calculateAllDistances();
    }
    if (widget.mileageId != null) {
      workitemrecid = widget.mileageId!.workitemRecId!;
      _calculateAllDistances();
    }
// final shouldShow = (widget.mileageId?.stepType?.isNotEmpty ?? false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.isEnable.value = false;

// // Start in view mode
//     });

    //  print("controller.isRoundTrip = true;${controller.isRoundTrip = true}");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.mileageId!.stepType == "Review") {
        controller.isEnable.value = true;
      } else {
        controller.isEnable.value = false;
      }
    });
  }
  // @override
  // void dispose() {
  //   for (var controller in controller.tripControllers) {
  //     controller.dispose();
  //   }
  //   _debounce?.cancel();
  //   super.dispose();
  // }

  Future<void> _calculateAllDistances() async {
    print("_calculateAllDistances is Calling");

    if (!mounted) return; // Check before doing anything

    _polylines.clear();
    _markers.clear();
    controller.calculatedAmountINR = 0;
    controller.totalDistanceKm = 0;

    if (controller.tripControllers.length < 2) {
      if (mounted) setState(() {});
      return;
    }

    for (int i = 0; i < controller.tripControllers.length - 1; i++) {
      String startCity = controller.tripControllers[i].text.trim();
      String endCity = controller.tripControllers[i + 1].text.trim();

      if (startCity.isEmpty || endCity.isEmpty) continue;

      try {
        List<Location> startLoc = await locationFromAddress(startCity);
        if (!mounted) return;

        List<Location> endLoc = await locationFromAddress(endCity);
        if (!mounted) return;

        if (startLoc.isNotEmpty && endLoc.isNotEmpty) {
          LatLng startLatLng =
              LatLng(startLoc.first.latitude, startLoc.first.longitude);
          LatLng endLatLng =
              LatLng(endLoc.first.latitude, endLoc.first.longitude);

          // Create labeled markers
          String startMarkerLabel = getMarkerLabel(i);
          String endMarkerLabel = getMarkerLabel(i + 1);

          BitmapDescriptor startMarkerIcon =
              await createMarkerWithLabel(startMarkerLabel);
          if (!mounted) return;

          BitmapDescriptor endMarkerIcon =
              await createMarkerWithLabel(endMarkerLabel);
          if (!mounted) return;

          // Add start and end markers
          _markers.add(Marker(
            markerId: MarkerId('start_$i'),
            position: startLatLng,
            infoWindow: InfoWindow(
                title: "Point $startMarkerLabel", snippet: startCity),
            icon: startMarkerIcon,
          ));

          _markers.add(Marker(
            markerId: MarkerId('end_${i + 1}'),
            position: endLatLng,
            infoWindow:
                InfoWindow(title: "Point $endMarkerLabel", snippet: endCity),
            icon: endMarkerIcon,
          ));

          // Fetch polyline for this route
          double routeDistance =
              await _fetchRoutePolyline(startLatLng, endLatLng, i);
          if (!mounted) return;

          controller.totalDistanceKm += routeDistance;
          controller.calculateAmount();

          if (controller.isRoundTrip &&
              i == controller.tripControllers.length - 2) {
            double returnDistance = await _fetchRoutePolyline(
              endLatLng,
              startLatLng,
              i + 100,
            );
            if (!mounted) return;

            controller.totalDistanceKm += returnDistance;
            controller.calculateAmount();
          }
        }
      } catch (e) {
        print("Error: $e");
      }
    }

    if (mounted) {
      setState(() {});
      _adjustCameraBounds();
    }
  }

  Future<double> _fetchRoutePolyline(
      LatLng start, LatLng end, int index) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'].isNotEmpty) {
          String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];
          List<LatLng> polylineCoords = _decodePolyline(encodedPolyline);

          _polylines.add(Polyline(
            polylineId: PolylineId('route_$index'),
            color: Colors.blueAccent,
            width: 5,
            points: polylineCoords,
          ));

          double distanceMeters = 0;
          var legs = data['routes'][0]['legs'];
          for (var leg in legs) {
            distanceMeters += leg['distance']['value'];
          }

          return distanceMeters / 1000; // Return distance in KM
        }
      }
    } catch (_) {
      print("Failed to fetch route data.");
    }
    return 0;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _adjustCameraBounds() async {
    if (_mapController == null || _markers.isEmpty) return;

    LatLngBounds bounds;
    var positions = _markers.map((m) => m.position).toList();

    double south =
        positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double north =
        positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double west =
        positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double east =
        positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    bounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _onTripTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _calculateAllDistances();
    });
  }

  Future<void> _zoomToLocation(String address) async {
    if (_mapController == null || address.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng target = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );

        // Animate camera to this point
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: target,
              zoom: 14, // adjust zoom level
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Zoom Error: $e");
    }
  }

  void _addStopField() {
    if (controller.isRoundTrip) {
      Fluttertoast.showToast(
        msg: "Turn off the Round Trip",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 35, 2, 124),
        textColor: const Color.fromARGB(255, 253, 252, 253),
        fontSize: 16.0,
      );
    } else {
      setState(() {
        isEditMode = false;
        int insertIndex = controller.tripControllers.length - 1;
        controller.tripControllers.insert(insertIndex, TextEditingController());
      });
      for (var i = 0; i < controller.tripControllers.length; i++) {
        print("tripControllers[$i]: '${controller.tripControllers[i].text}'");
      }
      _calculateAllDistances();
    }
  }

  void _removeStopField(TextEditingController controllerToRemove) {
    if (controller.tripControllers.length > 2) {
      // Don’t allow removing Start/End
      setState(() {
        controller.tripControllers.remove(controllerToRemove);
        controllerToRemove.dispose(); // Dispose the controller to avoid leaks
      });
      _calculateAllDistances();
      controller.isRoundTrip = false;
    }
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) return [];
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&components=country:in';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        return predictions.map((p) => p['description'] as String).toList();
      }
    } catch (e) {
      print("Autocomplete Error: $e");
    }
    return [];
  }

  String getMarkerLabel(int index) {
    return String.fromCharCode(65 + index); // 65 = ASCII 'A'
  }

  Future<BitmapDescriptor> createMarkerWithLabel(String label) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.blueAccent;

    const double size = 80.0;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    print("controller.calculatedAmountINR${shouldShow.value}");
    // shouldShow.value = widget.mileageId?.stepType != null;
    return GestureDetector(
      onTap: () {
        // Hide keyboard & remove focus when tapping outside
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // Header Section (Auto Height)
            Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.40,
                // minHeight: screenHeight * 0.45, // Set maximum height
              ),
              decoration: const BoxDecoration(
                color: const Color.fromARGB(255, 11, 1, 61),
                // gradient: LinearGradient(
                //   colors: [Color(0xFF3B3BD6), Color(0xFF7E1EFF)],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Scrollable Trip Fields
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.tripControllers.length,
                      itemBuilder: (context, index) {
                        String fieldName;
                        if (index == 0) {
                          fieldName = AppLocalizations.of(context)!.startTrip;
                        } else if (index ==
                            controller.tripControllers.length - 1) {
                          fieldName = AppLocalizations.of(context)!.endTrip;
                        } else {
                          fieldName = "${AppLocalizations.of(context)!.addTrip} $index";
                        }

                        String stopLetter =
                            String.fromCharCode(65 + index); // A, B, C

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 10,
                                child: Text(
                                  stopLetter,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Autocomplete<String>(
                                  optionsBuilder: (TextEditingValue
                                      textEditingValue) async {
                                    if (textEditingValue.text.isEmpty) {
                                      return [];
                                    }
                                    return await fetchPlaceSuggestions(
                                        textEditingValue.text);
                                  },
                                  onSelected: (String selection) {
                                    controller.tripControllers[index].text =
                                        selection;
                                    controller
                                            .tripControllers[index].selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: selection.length));
                                    _onTripTextChanged();
                                    _zoomToLocation(selection);
                                  },
                                  fieldViewBuilder: (context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted) {
                                    textEditingController.text =
                                        controller.tripControllers[index].text;
                                    textEditingController.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: textEditingController
                                                .text.length));
                                    textEditingController.addListener(() {
                                      controller.tripControllers[index].text =
                                          textEditingController.text;
                                    });

                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      enabled: controller.isEnable.value,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: fieldName,
                                        hintStyle:
                                            const TextStyle(fontSize: 12),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        // ✅ Show inline error if submit attempted
                                        errorText: isSubmitAttempted &&
                                                controller
                                                    .tripControllers[index].text
                                                    .trim()
                                                    .isEmpty
                                            ? "This field is required"
                                            : null,
                                      ),
                                      onChanged: (value) {
                                        _onTripTextChanged();
                                        setState(() {}); // Refresh validation
                                      },
                                      onSubmitted: (_) => onFieldSubmitted(),
                                    );
                                  },
                                ),
                              ),
                              if (controller.isEnable.value)
                                if (index > 0 &&
                                    index <
                                        controller.tripControllers.length - 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        controller.tripControllers
                                            .removeAt(index);
                                      });
                                      _calculateAllDistances();
                                    },
                                  ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Round trip end trip field
                    if (controller.isRoundTrip &&
                        controller.tripControllers.length < 3)
                      const SizedBox(height: 7),
                    if (controller.isRoundTrip &&
                        controller.tripControllers.length < 3)
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                controller: controller.tripControllers.first,
                                readOnly: controller.isRoundTrip,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText:AppLocalizations.of(context)!.endTrip,
                                  hintStyle: const TextStyle(fontSize: 13),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                    horizontal: 14,
                                  ),
                                  fillColor: controller.isRoundTrip
                                      ? Colors.grey.shade300
                                      : Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  // ✅ Show inline error if submit attempted
                                  errorText: isSubmitAttempted &&
                                          controller.tripControllers.first.text
                                              .trim()
                                              .isEmpty
                                      ? AppLocalizations.of(context)!.fieldRequired
                                      : null,
                                ),
                                onChanged: (value) {
                                  if (!controller.isRoundTrip) {
                                    _onTripTextChanged();
                                    setState(() {}); // Refresh validation
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Add Stoqp + Round Trip Switch
                    // if (controller.isEnable.value)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (controller.tripControllers.length < 3)
                          Row(
                            children: [
                              Switch(
                                value: controller.isRoundTrip,
                                onChanged: (value) {
                                  setState(() {
                                    controller.isRoundTrip = value;
                                    _calculateAllDistances();
                                  });
                                },
                                activeColor: Colors.white,
                              ),
                               Text(AppLocalizations.of(context)!.roundTrip,
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.white, size: 28),
                          onPressed: _addStopField,
                        ),
                      ],
                    ),
                  ]))),

                  // Info Cards pinned at bottom of header
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoCard(AppLocalizations.of(context)!.totalDistance,
                          "${controller.totalDistanceKm.toStringAsFixed(2)} Km"),
                      _infoCard(AppLocalizations.of(context)!.amountInInr,
                          "₹${controller.calculatedAmountINR.toStringAsFixed(2)}"),
                      _infoCard(AppLocalizations.of(context)!.amountInInr,
                          "₹${controller.calculatedAmountINR.toStringAsFixed(2)}"),
                    ],
                  ),
                ],
              ),
            ),

            // Map Section (Takes Remaining Space)
            Expanded(
                child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(20.5937, 78.9629), // Center on India
                    zoom: 4,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  mapType: _currentMapType,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _adjustCameraBounds();
                  },
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: "toggleMapType",
                    backgroundColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _currentMapType = _currentMapType == MapType.normal
                            ? MapType.hybrid
                            : MapType.normal;
                      });
                    },
                    child: Icon(
                      _currentMapType == MapType.normal
                          ? Icons.satellite
                          : Icons.map,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (widget.mileageId != null) ...[
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Submit Button

                        // REVIEW SECTION
                        if (widget.mileageId!.stepType == "Review")
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 🔵 Row 1: Update & Accept + Update
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() {
                                        final isLoadingAccept =
                                            controller.buttonLoaders[
                                                    'update_accept'] ??
                                                false;
                                        final isAnyLoading = controller
                                            .buttonLoaders.values
                                            .any((loading) => loading == true);

                                        return ElevatedButton(
                                          onPressed: (isLoadingAccept ||
                                                  isAnyLoading)
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'update_accept', true);
                                                  try {
                                                    await controller
                                                        .reviewMileageRegistration(
                                                            context,
                                                            true,
                                                            workitemrecid);
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'update_accept', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 3, 20, 117),
                                          ),
                                          child: isLoadingAccept
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.updateAndAccept,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Obx(() {
                                        final isLoadingUpdate =
                                            controller.buttonLoaders[
                                                    'update_review'] ??
                                                false;
                                        final isAnyLoading = controller
                                            .buttonLoaders.values
                                            .any((loading) => loading == true);

                                        return ElevatedButton(
                                          onPressed: (isLoadingUpdate ||
                                                  isAnyLoading)
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'update_review', true);
                                                  try {
                                                    await controller
                                                        .reviewMileageRegistration(
                                                            context,
                                                            false,
                                                            workitemrecid);
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'update_review', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 3, 20, 117),
                                          ),
                                          child: isLoadingUpdate
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                 AppLocalizations.of(context)!.update,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 🔴 Row 2: Reject + Close
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() {
                                        final isLoadingReject =
                                            controller.buttonLoaders[
                                                    'reject_review'] ??
                                                false;
                                        final isAnyLoading = controller
                                            .buttonLoaders.values
                                            .any((loading) => loading == true);

                                        return ElevatedButton(
                                          onPressed: (isLoadingReject ||
                                                  isAnyLoading)
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'reject_review', true);
                                                  try {
                                                    showActionPopup(
                                                        context, "Reject");
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'reject_review', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 238, 20, 20),
                                          ),
                                          child: isLoadingReject
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.reject,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Obx(() {
                                        final isLoadingClose =
                                            controller.buttonLoaders[
                                                    'close_review'] ??
                                                false;
                                        final isAnyLoading = controller
                                            .buttonLoaders.values
                                            .any((loading) => loading == true);

                                        return ElevatedButton(
                                          onPressed: (isLoadingClose ||
                                                  isAnyLoading)
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'close_review', true);
                                                  try {
                                                    controller.skipCurrentItem(
                                                        widget.mileageId!
                                                            .workitemRecId!,
                                                        context);
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'close_review', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                          ),
                                          child: isLoadingClose
                                              ? const CircularProgressIndicator(
                                                  color: Colors.black,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.skip,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // APPROVAL SECTION
                        if (widget.mileageId!.stepType == "Approval")
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() {
                                        final isLoading = controller
                                                .buttonLoaders['approve'] ??
                                            false;
                                        return ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'approve', true);
                                                  try {
                                                    showActionPopup(
                                                        context, "Approve");
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'approve', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 30, 117, 3),
                                          ),
                                          child: isLoading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.approve,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Obx(() {
                                        final isLoading =
                                            controller.buttonLoaders[
                                                    'reject_approval'] ??
                                                false;
                                        return ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'reject_approval', true);
                                                  try {
                                                    showActionPopup(
                                                        context, "Reject");
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'reject_approval',
                                                        false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 238, 20, 20),
                                          ),
                                          child: isLoading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.reject,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() {
                                        final isLoading = controller
                                                .buttonLoaders['escalate'] ??
                                            false;
                                        return ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'escalate', true);
                                                  try {
                                                    showActionPopup(
                                                        context, "Escalate");
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'escalate', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 3, 20, 117),
                                          ),
                                          child: isLoading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.escalate,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Obx(() {
                                        final isLoadingClose =
                                            controller.buttonLoaders[
                                                    'close_review'] ??
                                                false;
                                        final isAnyLoading = controller
                                            .buttonLoaders.values
                                            .any((loading) => loading == true);

                                        return ElevatedButton(
                                          onPressed: (isLoadingClose ||
                                                  isAnyLoading)
                                              ? null
                                              : () async {
                                                  controller.setButtonLoading(
                                                      'close_review', true);
                                                  try {
                                                    controller.skipCurrentItem(
                                                        widget.mileageId!
                                                            .workitemRecId!,
                                                        context);
                                                  } finally {
                                                    controller.setButtonLoading(
                                                        'close_review', false);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                          ),
                                          child: isLoadingClose
                                              ? const CircularProgressIndicator(
                                                  color: Colors.black,
                                                  strokeWidth: 2,
                                                )
                                              :  Text(
                                                  AppLocalizations.of(context)!.skip,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ],
            )),
          ],
        ),
      ),
    );
  }
void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;
  final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                     Text(
                      loc.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                       Text(
                        '${loc.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${loc.user} *',
                          columnHeaders:  [
                            loc.userName,
                            loc.userId,
                          ],
                          items: controller.userList,
                          selectedValue: controller.selectedUser.value,
                          searchValue: (user) =>
                              '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(child: Text(user.userName)),
                                  Expanded(child: Text(user.userId)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                     Text(
                     loc.comments,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: loc.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.teal,
                            width: 2,
                          ),
                        ),
                        errorText:
                            isCommentError ? AppLocalizations.of(context)!.commentRequired : null,
                      ),
                      onChanged: (value) {
                        if (isCommentError && value.trim().isNotEmpty) {
                          setState(() => isCommentError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child:  Text(loc.close),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                        onPressed: () async {
                          final comment = commentController.text.trim();
                          if (status != "Approve" && comment.isEmpty) {
                            setState(() => isCommentError = true);
                            return;
                          }

                          // Show full-page loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                              child: SkeletonLoaderPage(),
                            ),
                          );

                          final success = await controller.approvalHubpostApprovalAction(
                            context,
                            workitemrecid: [workitemrecid!],
                            decision: status,
                            comment: commentController.text,
                          );

                          // Hide the loading indicator
                          if (Navigator.of(context, rootNavigator: true).canPop()) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pushNamed(
                                context, AppRoutes.approvalHubMain);
                            controller.isApprovalEnable.value = false;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to submit action')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(status),
                      ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }




  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateTrips() {
    for (var tripController in controller.tripControllers) {
      if (tripController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllTripLocations),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false; // Block submission
      }
    }
    return true; // All fields are filled
  }
}
