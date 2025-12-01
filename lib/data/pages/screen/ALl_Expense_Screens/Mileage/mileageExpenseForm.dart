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

class MileageRegistrationPage extends StatefulWidget {
  final bool? isEditMode;
  final ExpenseModelMileage? mileageId;

  const MileageRegistrationPage({Key? key, this.isEditMode, this.mileageId})
    : super(key: key);

  @override
  State<MileageRegistrationPage> createState() =>
      _MileageRegistrationPageState();
}

class _MileageRegistrationPageState extends State<MileageRegistrationPage> {
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
  bool isCalculatingDistance = false;
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
  }
  // @override
  // void dispose() {
  //   for (var controller in controller.tripControllers) {
  //     controller.dispose();
  //   }
  //   _debounce?.cancel();
  //   super.dispose();
  // }

  int _calculationToken = 0;

  // Future<void> _calculateAllDistances() async {
  //   print("_calculateAllDistances is Calling");

  //   if (!mounted) return;

  //   // increase token every new call
  //   final int currentToken = ++_calculationToken;

  //   _polylines.clear();
  //   _markers.clear();
  //   controller.calculatedAmountINR = 0;
  //   controller.totalDistanceKm = 0;

  //   if (controller.tripControllers.length < 2) {
  //     if (mounted) setState(() {});
  //     return;
  //   }

  //   for (int i = 0; i < controller.tripControllers.length - 1; i++) {
  //     // if another call started, stop this one
  //     if (currentToken != _calculationToken) return;

  //     String startCity = controller.tripControllers[i].text.trim();
  //     String endCity = controller.tripControllers[i + 1].text.trim();

  //     if (startCity.isEmpty || endCity.isEmpty) continue;

  //     try {
  //       List<Location> startLoc = await locationFromAddress(startCity);
  //       if (!mounted || currentToken != _calculationToken) return;

  //       List<Location> endLoc = await locationFromAddress(endCity);
  //       if (!mounted || currentToken != _calculationToken) return;

  //       if (startLoc.isNotEmpty && endLoc.isNotEmpty) {
  //         LatLng startLatLng =
  //             LatLng(startLoc.first.latitude, startLoc.first.longitude);
  //         LatLng endLatLng =
  //             LatLng(endLoc.first.latitude, endLoc.first.longitude);

  //         String startMarkerLabel = getMarkerLabel(i);
  //         String endMarkerLabel = getMarkerLabel(i + 1);

  //         BitmapDescriptor startMarkerIcon =
  //             await createMarkerWithLabel(startMarkerLabel);
  //         if (!mounted || currentToken != _calculationToken) return;

  //         BitmapDescriptor endMarkerIcon =
  //             await createMarkerWithLabel(endMarkerLabel);
  //         if (!mounted || currentToken != _calculationToken) return;

  //         _markers.add(Marker(
  //           markerId: MarkerId('start_$i'),
  //           position: startLatLng,
  //           infoWindow: InfoWindow(
  //               title: "Point $startMarkerLabel", snippet: startCity),
  //           icon: startMarkerIcon,
  //         ));

  //         _markers.add(Marker(
  //           markerId: MarkerId('end_${i + 1}'),
  //           position: endLatLng,
  //           infoWindow:
  //               InfoWindow(title: "Point $endMarkerLabel", snippet: endCity),
  //           icon: endMarkerIcon,
  //         ));

  //         double routeDistance =
  //             await _fetchRoutePolyline(startLatLng, endLatLng, i);
  //         if (!mounted || currentToken != _calculationToken) return;

  //         controller.totalDistanceKm += routeDistance;
  //         controller.calculateAmount();

  //         if (controller.isRoundTrip &&
  //             i == controller.tripControllers.length - 2) {
  //           double returnDistance =
  //               await _fetchRoutePolyline(endLatLng, startLatLng, i + 100);
  //           if (!mounted || currentToken != _calculationToken) return;

  //           controller.totalDistanceKm += returnDistance;
  //           controller.calculateAmount();
  //         }
  //       }
  //     } catch (e) {
  //       print("Error: $e");
  //     }
  //   }

  //   if (mounted && currentToken == _calculationToken) {
  //     setState(() {});
  //     _adjustCameraBounds();
  //   }
  // }


Future<Location?> getCoordinatesFromAddress(String address) async {
  final encoded = Uri.encodeComponent(address);
  const String apiKey = 'AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0'; // 🔑 Replace this
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$apiKey',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final loc = data['results'][0]['geometry']['location'];
        return Location(
          latitude: loc['lat'],
          longitude: loc['lng'],
          timestamp: DateTime.now(),
        );
      }
    }
  } catch (e) {
    debugPrint("❌ Geocode failed for $address: $e");
  }
  return null;
}



Future<void> _calculateAllDistances() async {
  print("_calculateAllDistances is Calling");

  setState(() => isCalculatingDistance = true);

  final int currentToken = ++_calculationToken;

  _polylines.clear();
  _markers.clear();
  controller.calculatedAmountINR = 0;
  controller.totalDistanceKm = 0;

  if (controller.tripControllers.length < 2) {
    if (mounted) setState(() => isCalculatingDistance = false);
    return;
  }

  for (int i = 0; i < controller.tripControllers.length - 1; i++) {
    if (currentToken != _calculationToken) {
      setState(() => isCalculatingDistance = false);
      return;
    }

    String startCity = controller.tripControllers[i].text.trim();
    String endCity = controller.tripControllers[i + 1].text.trim();
    print("startCity: $startCity");
    print("endCity: $endCity");

    if (startCity.isEmpty || endCity.isEmpty) continue;

    try {
      // ✅ Use Google API instead of system geocoder
      final startLoc = await getCoordinatesFromAddress(startCity);
      if (!mounted || currentToken != _calculationToken) return;
      print("startLoc: $startLoc");

      final endLoc = await getCoordinatesFromAddress(endCity);
      if (!mounted || currentToken != _calculationToken) return;
      print("endLoc: $endLoc");

      if (startLoc == null || endLoc == null) {
        print("⚠️ Skipping route due to missing coordinates");
        continue;
      }

      LatLng startLatLng = LatLng(startLoc.latitude, startLoc.longitude);
      LatLng endLatLng = LatLng(endLoc.latitude, endLoc.longitude);

      print("✅ startLatLng: $startLatLng, endLatLng: $endLatLng");

      String startMarkerLabel = getMarkerLabel(i);
      String endMarkerLabel = getMarkerLabel(i + 1);

      BitmapDescriptor startMarkerIcon = await createMarkerWithLabel(startMarkerLabel);
      if (!mounted || currentToken != _calculationToken) return;

      BitmapDescriptor endMarkerIcon = await createMarkerWithLabel(endMarkerLabel);
      if (!mounted || currentToken != _calculationToken) return;

      _markers.add(
        Marker(
          markerId: MarkerId('start_$i'),
          position: startLatLng,
          infoWindow: InfoWindow(title: "Point $startMarkerLabel", snippet: startCity),
          icon: startMarkerIcon,
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('end_${i + 1}'),
          position: endLatLng,
          infoWindow: InfoWindow(title: "Point $endMarkerLabel", snippet: endCity),
          icon: endMarkerIcon,
        ),
      );

      // ✅ Fetch route and distance
      double routeDistance = await _fetchRoutePolyline(startLatLng, endLatLng, i);
      if (!mounted || currentToken != _calculationToken) return;

      controller.totalDistanceKm += routeDistance;
      controller.calculateAmount();

      // ✅ Handle round trip
      if (controller.isRoundTrip && i == controller.tripControllers.length - 2) {
        double returnDistance = await _fetchRoutePolyline(endLatLng, startLatLng, i + 100);
        if (!mounted || currentToken != _calculationToken) return;

        controller.totalDistanceKm += returnDistance;
        controller.calculateAmount();
      }
    } catch (e) {
      print("❌ Error while calculating distance: $e");
    }
  }

  if (mounted && currentToken == _calculationToken) {
    setState(() => isCalculatingDistance = false);
    _adjustCameraBounds();
  }

  print("✅ Total Distance: ${controller.totalDistanceKm.toStringAsFixed(2)} km");
  print("✅ Final Amount: ₹${controller.calculatedAmountINR.toStringAsFixed(2)}");
}


  Future<double> _fetchRoutePolyline(
    LatLng start,
    LatLng end,
    int index,
  ) async {
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

          _polylines.add(
            Polyline(
              polylineId: PolylineId('route_$index'),
              color: Colors.blueAccent,
              width: 5,
              points: polylineCoords,
            ),
          );

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

    double south = positions
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double north = positions
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double west = positions
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double east = positions
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

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
        msg: AppLocalizations.of(context)!.turnOffRoundTrip,
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
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

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

    final img = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
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
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          // backgroundColor: const Color.fromARGB(255, 11, 1, 61),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.mileageRegistration,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            if (widget.isEditMode!)
              if (widget.mileageId != null &&
                      widget.mileageId!.approvalStatus != "Cancelled" &&
                      widget.mileageId!.approvalStatus != "Approved" &&
                      widget.mileageId!.approvalStatus != "Pending" ||
                  widget.mileageId!.stepType == "Review")
                IconButton(
                  icon: Icon(
                    controller.isEnable.value
                        ? Icons.remove_red_eye
                        : Icons.edit_document,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.isEnable.value = !controller.isEnable.value;
                    });
                  },
                ),

            // if (!controller.isEnable.value &&
            //     widget.mileageId!.approvalStatus != "Cancelled" &&
            //     widget.mileageId!.approvalStatus != "Approved")
            //   IconButton(
            //     icon: const Icon(
            //       Icons.edit_document,
            //       color: Colors.white,
            //     ),
            //     onPressed: () {
            //       setState(() {
            //         controller.isEnable.value = true;
            //       });
            //     },
            //   ),
          ],
        ),
        body: Column(
          children: [
            // Header Section (Auto Height)
            Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.40,
                // minHeight: screenHeight * 0.45, // Set maximum height
              ),
              decoration: BoxDecoration(
                color: primaryColor,
                // gradient: LinearGradient(
                //   colors: [Color(0xFF3B3BD6), Color(0xFF7E1EFF)],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // const SizedBox(height: 10),

                  // Scrollable Trip Fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.tripControllers.length,
                            itemBuilder: (context, index) {
                              String fieldName;
                              if (index == 0) {
                                fieldName = AppLocalizations.of(
                                  context,
                                )!.startTrip;
                              } else if (index ==
                                  controller.tripControllers.length - 1) {
                                fieldName = AppLocalizations.of(
                                  context,
                                )!.endTrip;
                              } else {
                                fieldName =
                                    "${AppLocalizations.of(context)!.addTrip} $index";
                              }

                              String stopLetter = String.fromCharCode(
                                65 + index,
                              ); // A, B, C

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Autocomplete<String>(
                                        optionsBuilder:
                                            (
                                              TextEditingValue textEditingValue,
                                            ) async {
                                              if (textEditingValue
                                                  .text
                                                  .isEmpty) {
                                                return [];
                                              }
                                              return await fetchPlaceSuggestions(
                                                textEditingValue.text,
                                              );
                                            },
                                        onSelected: (String selection) {
                                          controller
                                                  .tripControllers[index]
                                                  .text =
                                              selection;
                                          controller
                                                  .tripControllers[index]
                                                  .selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: selection.length,
                                                ),
                                              );
                                          _onTripTextChanged();
                                          _zoomToLocation(selection);
                                        },
                                        fieldViewBuilder:
                                            (
                                              context,
                                              textEditingController,
                                              focusNode,
                                              onFieldSubmitted,
                                            ) {
                                              textEditingController.text =
                                                  controller
                                                      .tripControllers[index]
                                                      .text;
                                              textEditingController.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset:
                                                          textEditingController
                                                              .text
                                                              .length,
                                                    ),
                                                  );
                                              textEditingController.addListener(
                                                () {
                                                  controller
                                                          .tripControllers[index]
                                                          .text =
                                                      textEditingController
                                                          .text;
                                                },
                                              );

                                              return TextField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                enabled:
                                                    controller.isEnable.value,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87
                                                ),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  hintText: fieldName,
                                                  hintStyle: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 12,
                                                      ),

                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  // ✅ Show inline error if submit attempted
                                                  errorText:
                                                      isSubmitAttempted &&
                                                          controller
                                                              .tripControllers[index]
                                                              .text
                                                              .trim()
                                                              .isEmpty
                                                      ? AppLocalizations.of(
                                                          context,
                                                        )!.fieldRequired
                                                      : null,
                                                ),
                                                onChanged: (value) {
                                                  _onTripTextChanged();
                                                  setState(
                                                    () {},
                                                  ); // Refresh validation
                                                },
                                                onSubmitted: (_) =>
                                                    onFieldSubmitted(),
                                              );
                                            },
                                      ),
                                    ),
                                    if (controller.isEnable.value)
                                      if (index > 0 &&
                                          index <
                                              controller
                                                      .tripControllers
                                                      .length -
                                                  1)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
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
                            // const SizedBox(height: 7),
                          if (controller.isRoundTrip &&
                              controller.tripControllers.length < 3)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller:
                                          controller.tripControllers.first,
                                      readOnly: controller.isRoundTrip,
                                      style: const TextStyle(fontSize: 12,color: Colors.black),
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(
                                          context,
                                        )!.endTrip,
                                        hintStyle: const TextStyle(
                                          fontSize: 13,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 13,
                                              horizontal: 14,
                                            ),
                                        fillColor: controller.isRoundTrip
                                            ? Colors.grey.shade300
                                            : Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        // ✅ Show inline error if submit attempted
                                        errorText:
                                            isSubmitAttempted &&
                                                controller
                                                    .tripControllers
                                                    .first
                                                    .text
                                                    .trim()
                                                    .isEmpty
                                            ? AppLocalizations.of(
                                                context,
                                              )!.fieldRequired
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
                          if (controller.isEnable.value)
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
                                      Text(
                                        AppLocalizations.of(context)!.roundTrip,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                if (!controller.isRoundTrip)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: _addStopField,
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Info Cards pinned at bottom of header
                  const SizedBox(height: 12),
                  isCalculatingDistance
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white10,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _infoCardButton(
                              title: AppLocalizations.of(
                                context,
                              )!.totalDistance,
                              value:
                                  "${controller.totalDistanceKm.toStringAsFixed(2)} Km",
                              onTap: () => print("Total Distance tapped"),
                            ),
                            const SizedBox(width: 5),
                            _infoCardButton(
                              title: AppLocalizations.of(
                                context,
                              )!.totalAmountInInr,
                              value:
                                  "₹${controller.calculatedAmountINR.toStringAsFixed(2)}",
                              onTap: () => print("Total Amount tapped"),
                            ),
                            const SizedBox(width: 5),
                            _infoCardButton(
                              title: AppLocalizations.of(
                                context,
                              )!.totalAmountInInr,
                              value:
                                  "₹${controller.calculatedAmountINR.toStringAsFixed(2)}",
                              onTap: () => print("Third card tapped"),
                            ),
                            const SizedBox(width: 5),
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
                      bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Submit Button
                          if (controller.isEnable.value &&
                              widget.mileageId!.approvalStatus != "Pending" &&
                              widget.mileageId!.approvalStatus != "Rejected")
                            Obx(() {
                              final isSubmitLoading =
                                  controller.buttonLoaders['submit'] ?? false;
                              final isAnyLoading = controller
                                  .buttonLoaders
                                  .values
                                  .any((loading) => loading);

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: AppColors.gradientEnd,
                                ),
                                onPressed: (isSubmitLoading || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                          'submit',
                                          true,
                                        );
                                        try {
                                          await controller.submitMileageExpense(
                                            context,
                                            true,
                                            false,
                                            widget.mileageId!.recId,
                                            widget.mileageId!.expenseId,
                                          );
                                        } finally {
                                          controller.setButtonLoading(
                                            'submit',
                                            false,
                                          );
                                        }
                                      },
                                child: isSubmitLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.submit,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            }),

                          if (controller.isEnable.value &&
                              widget.mileageId!.approvalStatus == "Rejected")
                            Obx(() {
                              final isResubmitLoading =
                                  controller.buttonLoaders['resubmit'] ?? false;
                              final isAnyLoading = controller
                                  .buttonLoaders
                                  .values
                                  .any((loading) => loading);

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: AppColors.gradientEnd,
                                ),
                                onPressed: (isResubmitLoading || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                          'resubmit',
                                          true,
                                        );
                                        try {
                                          await controller.submitMileageExpense(
                                            context,
                                            true,
                                            true,
                                            widget.mileageId!.recId,
                                            widget.mileageId!.expenseId,
                                          );
                                        } finally {
                                          controller.setButtonLoading(
                                            'resubmit',
                                            false,
                                          );
                                        }
                                      },
                                child: isResubmitLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.resubmit,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            }),

                          // Save, Update & Cancel Buttons
                          Row(
                            children: [
                              if (controller.isEnable.value &&
                                  widget.mileageId!.approvalStatus == "Created")
                                Expanded(
                                  child: Obx(() {
                                    final isSaveLoading =
                                        controller.buttonLoaders['save'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((loading) => loading);

                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: (isSaveLoading || isAnyLoading)
                                          ? null
                                          : () {
                                              isSubmitAttempted = true;
                                              if (_validateTrips()) {
                                                controller.setButtonLoading(
                                                  'save',
                                                  true,
                                                );
                                                controller
                                                    .submitMileageExpense(
                                                      context,
                                                      false,
                                                      false,
                                                      widget.mileageId!.recId,
                                                      widget
                                                          .mileageId!
                                                          .expenseId,
                                                    )
                                                    .whenComplete(() {
                                                      controller.setButtonLoading(
                                                        'save',
                                                        false,
                                                      ); // ✅ Correct loader key
                                                    });
                                              } else {
                                                isSubmitAttempted = true;
                                                // Show error if validation fails
                                                Get.snackbar(
                                                  "Validation",
                                                  "Please fill all trip fields",
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                );
                                              }
                                            },
                                      child: isSaveLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.green,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.save,
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                              if (controller.isEnable.value &&
                                  widget.mileageId!.approvalStatus ==
                                      "Rejected")
                                Expanded(
                                  child: Obx(() {
                                    final isUpdatedLoading =
                                        controller
                                            .buttonLoaders['update_rejected'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((loading) => loading);

                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          (isUpdatedLoading || isAnyLoading)
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'update_rejected',
                                                true,
                                              );
                                              try {
                                                await controller
                                                    .submitMileageExpense(
                                                      context,
                                                      false,
                                                      false,
                                                      widget.mileageId!.recId,
                                                      widget
                                                          .mileageId!
                                                          .expenseId,
                                                    );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'update_rejected',
                                                  false,
                                                );
                                              }
                                            },
                                      child: isUpdatedLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.green,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.update,
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                              if (!controller.isEnable.value &&
                                  widget.mileageId!.stepType!.isEmpty &&
                                  widget.mileageId!.approvalStatus == "Pending")
                                Expanded(
                                  child: Obx(() {
                                    final isLoading =
                                        controller
                                            .buttonLoaders['cancel_pending'] ??
                                        false;
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          243,
                                          172,
                                          187,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'cancel_pending',
                                                true,
                                              );
                                              try {
                                                await controller.cancelExpense(
                                                  context,
                                                  widget.mileageId!.recId
                                                      .toString(),
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'cancel_pending',
                                                  false,
                                                );
                                              }
                                            },
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.red,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.cancel,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                              const SizedBox(width: 10),
                              // if(!controller.isEnable.value)
                              if (widget.mileageId!.stepType!.isEmpty ||
                                  widget.mileageId!.stepType == "Review" &&
                                      !controller.isEnable.value)
                                Expanded(
                                  child: Obx(() {
                                    final isLoading =
                                        controller
                                            .buttonLoaders['cancel_main'] ??
                                        false;
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade400,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'cancel_main',
                                                true,
                                              );
                                              try {
                                                controller.closeField();
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.generalExpense,
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'cancel_main',
                                                  false,
                                                );
                                              }
                                            },
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.close,
                                            ),
                                    );
                                  }),
                                ),
                                  
                            ],
                          ),
                         const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // REVIEW SECTION
                    if (controller.isEnable.value &&
                        widget.mileageId!.stepType == "Review")
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                           
                            Row(
                              children: [
                                Expanded(
  child: Obx(() {
    final isLoadingAccept =
        controller.buttonLoaders['update_accept'] ?? false;
    final isAnyLoading =
        controller.buttonLoaders.values.any((loading) => loading == true);

    return SizedBox(
      height: 40, // fixes button height consistently
      child: ElevatedButton(
        onPressed: (isLoadingAccept || isAnyLoading)
            ? null
            : () async {
                controller.setButtonLoading('update_accept', true);
                try {
                  await controller.reviewMileageRegistration(
                    context,
                    true,
                    workitemrecid,
                  );
                } finally {
                  controller.setButtonLoading('update_accept', false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 3, 20, 117),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: isLoadingAccept
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.updateAndAccept,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
      ),
    );
  }),
),

                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() {
                                    final isLoadingUpdate =
                                        controller
                                            .buttonLoaders['update_review'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((loading) => loading == true);

                                    return ElevatedButton(
                                      onPressed:
                                          (isLoadingUpdate || isAnyLoading)
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'update_review',
                                                true,
                                              );
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
                                          const Color.fromARGB(255, 3, 20, 117),
                                    ),
                                    child: isLoadingUpdate
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!
                                                .update,
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
                                        controller
                                            .buttonLoaders['reject_review'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((loading) => loading == true);

                                    return ElevatedButton(
                                      onPressed:
                                          (isLoadingReject || isAnyLoading)
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'reject_review',
                                                true,
                                              );
                                              try {
                                                showActionPopup(
                                                  context,
                                                  "Reject",
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'reject_review',
                                                  false,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          238,
                                          20,
                                          20,
                                        ),
                                      ),
                                      child: isLoadingReject
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.reject,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() {
                                    final isLoadingClose =
                                        controller
                                            .buttonLoaders['close_review'] ??
                                        false;
                                    final isAnyLoading = controller
                                        .buttonLoaders
                                        .values
                                        .any((loading) => loading == true);

                                    return ElevatedButton(
                                      onPressed:
                                          (isLoadingClose || isAnyLoading)
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'close_review',
                                                true,
                                              );
                                              try {
                                                controller.closeField();
                                                controller.chancelButton(
                                                  context,
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'close_review',
                                                  false,
                                                );
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
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.close,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12
                                              ),
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
                    if (!controller.isEnable.value &&
                        widget.mileageId!.stepType == "Approval")
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    final isLoading =
                                        controller.buttonLoaders['approve'] ??
                                        false;
                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'approve',
                                                true,
                                              );
                                              try {
                                                showActionPopup(
                                                  context,
                                                  "Approve",
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'approve',
                                                  false,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          30,
                                          117,
                                          3,
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.approvals,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() {
                                    final isLoading =
                                        controller
                                            .buttonLoaders['reject_approval'] ??
                                        false;
                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'reject_approval',
                                                true,
                                              );
                                              try {
                                                showActionPopup(
                                                  context,
                                                  "Reject",
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'reject_approval',
                                                  false,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          238,
                                          20,
                                          20,
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.reject,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
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
                                    final isLoading =
                                        controller.buttonLoaders['escalate'] ??
                                        false;
                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'escalate',
                                                true,
                                              );
                                              try {
                                                showActionPopup(
                                                  context,
                                                  "Escalate",
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'escalate',
                                                  false,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          3,
                                          20,
                                          117,
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.escalate,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() {
                                    final isLoading =
                                        controller
                                            .buttonLoaders['close_approval'] ??
                                        false;
                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              controller.setButtonLoading(
                                                'close_approval',
                                                true,
                                              );
                                              try {
                                                controller.closeField();
                                                controller.chancelButton(
                                                  context,
                                                );
                                              } finally {
                                                controller.setButtonLoading(
                                                  'close_approval',
                                                  false,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.close,
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ] else ...[
                    // 🚨 ELSE: When mileageId is NULL
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 🔵 Submit Button with Loader
                          Obx(() {
                            final isSubmitLoading =
                                controller.buttonLoaders['submit'] ?? false;
                            final isAnyLoading = controller.buttonLoaders.values
                                .any((loading) => loading);

                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: AppColors.gradientEnd,
                              ),
                              onPressed: (isSubmitLoading || isAnyLoading)
                                  ? null
                                  : () {
                                      isSubmitAttempted = true;
                                      if (_validateTrips()) {
                                        controller.setButtonLoading(
                                          'submit',
                                          true,
                                        );
                                        controller
                                            .submitMileageExpense(
                                              context,
                                              true,
                                              false,
                                              null,
                                              null,
                                            )
                                            .whenComplete(() {
                                              controller.setButtonLoading(
                                                'submit',
                                                false,
                                              );
                                            });
                                      }
                                    },
                              child: isSubmitLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.submit,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            );
                          }),
                          const SizedBox(height: 10),

                          // 🟢 Save and Cancel Buttons
                          Row(
                            children: [
                              // 🟢 Save Button with Loader
                              Expanded(
                                child: Obx(() {
                                  final isSaveLoading =
                                      controller.buttonLoaders['save'] ?? false;
                                  final isAnyLoading = controller
                                      .buttonLoaders
                                      .values
                                      .any((loading) => loading);

                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[100],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: (isSaveLoading || isAnyLoading)
                                        ? null
                                        : () {
                                            isSubmitAttempted = true;
                                            if (_validateTrips()) {
                                              controller.setButtonLoading(
                                                'save',
                                                true,
                                              );
                                              controller
                                                  .submitMileageExpense(
                                                    context,
                                                    false,
                                                    false,
                                                    null,
                                                    null,
                                                  )
                                                  .whenComplete(() {
                                                    controller.setButtonLoading(
                                                      'save',
                                                      false,
                                                    );
                                                  });
                                            }
                                          },
                                    child: isSaveLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.green,
                                            strokeWidth: 2,
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!.save,
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                  );
                                }),
                              ),
                              const SizedBox(
                                width: 12,
                              ), // Space between buttons
                              // ⚪ Cancel Button (No loader needed)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (controller.isEnable.value) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.dashboard_Main,
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.generalExpense,
                                      );
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
                // const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;

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
                      AppLocalizations.of(context)!.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${AppLocalizations.of(context)!.selectUser} *',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${AppLocalizations.of(context)!.user} *',
                          columnHeaders: [
                            AppLocalizations.of(context)!.userName,
                            AppLocalizations.of(context)!.userId,
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
                                vertical: 12,
                                horizontal: 16,
                              ),
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
                      AppLocalizations.of(context)!.comments,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
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
                        errorText: isCommentError
                            ? AppLocalizations.of(context)!.commentRequired
                            : null,
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
                          child: Text(AppLocalizations.of(context)!.close),
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
                              builder: (ctx) =>
                                  const Center(child: SkeletonLoaderPage()),
                            );

                            final success = await controller.postApprovalAction(
                              context,
                              workitemrecid: [workitemrecid!],
                              decision: status,
                              comment: commentController.text,
                            );

                            // Hide the loading indicator
                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.approvalDashboard,
                              );
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit action'),
                                ),
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
                     const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoCardButton({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      // Ensures card shares available space
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
