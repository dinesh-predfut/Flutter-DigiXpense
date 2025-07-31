import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../core/constant/url.dart';

class MileageDetailsPage extends StatefulWidget {
  final ExpenseModelMileage? mileageId;
  const MileageDetailsPage({super.key, this.mileageId});

  @override
  State<MileageDetailsPage> createState() => _MileageDetailsPageState();
}

class _MileageDetailsPageState extends State<MileageDetailsPage> {
  bool isEditMode = false;
  bool isLoadingGE2 = false;
List<VehicleType> vehicleTypes = [];
VehicleType? selectedVehicleType;
  late Future<List<ExpenseHistory>> historyFuture;

double calculatedAmountINR = 0;
double calculatedAmountUSD = 0;
double totalDistanceKm = 0;
  late GoogleMapController _mapController;
  final controller = Get.put(Controller());

  final TextEditingController expenseId = TextEditingController();
  final TextEditingController employeeId = TextEditingController();
  final TextEditingController vehicle = TextEditingController();
  final TextEditingController project = TextEditingController();
  final TextEditingController mileage = TextEditingController();
  final TextEditingController totalDistance = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String googleApiKey = 'AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0';

  @override
  void initState() {
    super.initState();
    if (widget.mileageId != null) {
      final expense = widget.mileageId!;
        historyFuture = controller.fetchExpenseHistory(widget.mileageId!.recId);

      // Set basic fields
      expenseId.text = expense.expenseId;
      employeeId.text = expense.employeeId;
      vehicle.text = expense.vehicalType ?? 'N/A';
      project.text = expense.projectId ?? 'N/A';
      mileage.text = expense.mileageRateId;

      // 🔁 Check if round trip
      bool isRoundTrip = false;
      if (expense.travelPoints.isNotEmpty) {
        final firstFrom = expense.travelPoints.first.fromLocation;
        final lastTo = expense.travelPoints.last.toLocation;
        isRoundTrip = firstFrom == lastTo;
      }

     
    totalDistanceKm = expense.travelPoints.fold(0.0, (sum, tp) => sum + (tp.quantity ?? 0.0));
    totalDistance.text = totalDistanceKm.toStringAsFixed(2);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMileageRates(); 
    });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateAllDistances(expense.travelPoints, isRoundTrip: isRoundTrip);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // 🧮 Calculate route with dynamic points
  Future<void> _calculateAllDistances(List<TravelPoint> travelPoints,
      {required bool isRoundTrip}) async {
    if (travelPoints.isEmpty || !mounted) return;

    _markers.clear();
    _polylines.clear();

    final locations = <String>[];
    for (var tp in travelPoints) {
      if (!locations.contains(tp.fromLocation)) locations.add(tp.fromLocation);
      if (!locations.contains(tp.toLocation)) locations.add(tp.toLocation);
    }

    double totalKm = 0;

    for (int i = 0; i < travelPoints.length; i++) {
      final tp = travelPoints[i];
      String startAddress = tp.fromLocation.trim();
      String endAddress = tp.toLocation.trim();

      if (startAddress.isEmpty || endAddress.isEmpty) continue;

      try {
        List<Location> startLoc = await locationFromAddress(startAddress);
        if (!mounted || startLoc.isEmpty) continue;

        List<Location> endLoc = await locationFromAddress(endAddress);
        if (!mounted || endLoc.isEmpty) continue;

        LatLng startLatLng =
            LatLng(startLoc.first.latitude, startLoc.first.longitude);
        LatLng endLatLng =
            LatLng(endLoc.first.latitude, endLoc.first.longitude);

        // 🔤 Marker labels: A, B, C...
        String startLabel = String.fromCharCode(65 + i);
        String endLabel = String.fromCharCode(65 + i + 1);

        BitmapDescriptor startIcon = await createMarkerWithLabel(startLabel);
        BitmapDescriptor endIcon = await createMarkerWithLabel(endLabel);

        // Add start marker
        _markers.add(Marker(
          markerId: MarkerId('start_$i'),
          position: startLatLng,
          infoWindow:
              InfoWindow(title: 'Point $startLabel', snippet: startAddress),
          icon: startIcon,
        ));

        // Add end marker only once
        if (!_markers.any((m) => m.markerId == MarkerId('marker_${i + 1}'))) {
          _markers.add(Marker(
            markerId: MarkerId('marker_${i + 1}'),
            position: endLatLng,
            infoWindow:
                InfoWindow(title: 'Point $endLabel', snippet: endAddress),
            icon: endIcon,
          ));
        }

        // 🛣️ Draw polyline
        double distanceKm =
            await _fetchRoutePolyline(startLatLng, endLatLng, i);
        totalKm += distanceKm;
      } catch (e) {
        print("Error in segment $i: $e");
      }
    }

    // Update totals
    totalDistance.text = totalKm.toStringAsFixed(2);
    double rate = 40.0;
    totalAmount.text = (totalKm * rate).toStringAsFixed(2);

    if (mounted) {
      setState(() {});
      _adjustCameraBounds(locations);
    }
  }
Future<void> fetchMileageRates() async {
  setState(() {
    isLoadingGE2 = true;
  });

  final dateToUse = DateTime.now(); // Use receipt date if available
  final formatted = DateFormat('dd-MMM-yyyy').format(dateToUse);
  final fromDate = (DateTime.parse(formatted).millisecondsSinceEpoch / 1000).floor();

  try {
    final response = await http.get(
      Uri.parse('${Urls.empmileagevehicledetails}${Params.employeeId}&ReceiptDate=$fromDate'),
      headers: {
        "Authorization": 'Bearer ${Params.userToken ?? ''}',
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      vehicleTypes = data.map((item) => VehicleType.fromJson(item)).toList();

      // Find the vehicle used in the expense
      final expense = widget.mileageId!;
      final vehicleName = expense.vehicalType;

      selectedVehicleType =
          vehicleTypes.firstWhere((v) => v.name == vehicleName, orElse: () => vehicleTypes.first);

      // Now calculate amount
      calculateAmount();

      setState(() {
        isLoadingGE2 = false;
      });
    } else {
      print("API Error: ${response.statusCode}");
      setState(() {
        isLoadingGE2 = false;
      });
    }
  } catch (e) {
    print("Fetch Mileage Rates Error: $e");
    setState(() {
      isLoadingGE2 = false;
    });
  }
}
void calculateAmount() {
  if (selectedVehicleType == null || totalDistanceKm <= 0) {
    calculatedAmountINR = 0;
    calculatedAmountUSD = 0;
    return;
  }

  double ratePerKm = 0;

  for (var rate in selectedVehicleType!.mileageRateLines) {
    if ((rate.maximumDistances == 0 && totalDistanceKm >= rate.minimumDistances) ||
        (totalDistanceKm >= rate.minimumDistances && totalDistanceKm <= rate.maximumDistances)) {
      ratePerKm = rate.mileageRate;
      break;
    }
  }

  calculatedAmountINR = totalDistanceKm * ratePerKm;
  calculatedAmountUSD = calculatedAmountINR / 80; // Approx INR to USD

  // Update text controllers
  totalAmount.text = calculatedAmountINR.toStringAsFixed(2);

  print("Rate per KM: $ratePerKm");
  print("Total Distance: $totalDistanceKm km");
  print("Total Amount (INR): ₹$calculatedAmountINR");
}
  // 📍 Geocode address
  Future<List<Location>> locationFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?'
      'address=${Uri.encodeComponent(address)}&key=$googleApiKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'].isNotEmpty) {
          final loc = data['results'][0]['geometry']['location'];
          final lat = loc['lat'];
          final lng = loc['lng'];
          if (lat is num && lng is num) {
            return [
              Location(
                latitude: lat.toDouble(),
                longitude: lng.toDouble(),
                timestamp: DateTime.now(),
              )
            ];
          }
        }
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return [];
  }

  // 🛣️ Fetch route polyline
  Future<double> _fetchRoutePolyline(
      LatLng start, LatLng end, int index) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${start.latitude},${start.longitude}'
      '&destination=${end.latitude},${end.longitude}'
      '&key=$googleApiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final points =
            _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        final distanceInMeters =
            data['routes'][0]['legs'][0]['distance']['value'];

        _polylines.add(Polyline(
          polylineId: PolylineId('route_$index'),
          color: Colors.blue,
          width: 5,
          points: points,
        ));

        return distanceInMeters / 1000; // km
      }
    }
    return 0.0;
  }

  // 🔤 Create custom marker with label (A, B, C)
  Future<BitmapDescriptor> createMarkerWithLabel(String label) async {
    final icon =
        await _createIcon(label, const Size(40, 40), const Color(0xFF7B61FF));
    final byteData = await icon.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<ui.Image> _createIcon(String text, ui.Size size, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    final textStyle = ui.TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);
    final paragraphStyle = ui.ParagraphStyle(textAlign: TextAlign.center);
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);
    final paragraph = builder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 40));
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    canvas.drawParagraph(
        paragraph,
        Offset((size.width - paragraph.maxIntrinsicWidth) / 2,
            (size.height - paragraph.height) / 2));
    final img = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    return img;
  }

  // 🧭 Fit all points in camera
  void _adjustCameraBounds(List<String> locations) async {
    List<LatLng> latLngs = [];
    for (var loc in locations) {
      List<Location> results = await locationFromAddress(loc);
      if (results.isNotEmpty) {
        latLngs.add(LatLng(results.first.latitude, results.first.longitude));
      }
    }
    if (latLngs.isEmpty) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: latLngs.reduce((a, b) => LatLng(
            a.latitude < b.latitude ? a.latitude : b.latitude,
            a.longitude < b.longitude ? a.longitude : b.longitude,
          )),
      northeast: latLngs.reduce((a, b) => LatLng(
            a.latitude > b.latitude ? a.latitude : b.latitude,
            a.longitude > b.longitude ? a.longitude : b.longitude,
          )),
    );

    try {
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      print("Camera error: $e");
    }
  }

  // 🟰 Decode polyline
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
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // 💾 Save changes
  Future<void> _saveMileage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mileage updated successfully')),
    );
    setState(() => isEditMode = false);
  }

  @override
  Widget build(BuildContext context) {
    final expense = widget.mileageId;
    if (expense == null) return const Center(child: Text('No data'));

    // 🔁 Is round trip?
    final isRoundTrip = expense.travelPoints.isNotEmpty &&
        expense.travelPoints.first.fromLocation ==
            expense.travelPoints.last.toLocation;

    // 📍 Extract locations
    final startLoc = expense.travelPoints.first.fromLocation;
    final endLoc = expense.travelPoints.last.toLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Mileage'),
        // actions: [
        //   IconButton(
        //     icon: Icon(isEditMode ? Icons.save : Icons.edit),
        //     onPressed: () {
        //       if (isEditMode) {
        //         _saveMileage();
        //       } else {
        //         setState(() => isEditMode = true);
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(15)),
            child: SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(20.5937, 78.9629),
                  zoom: 5,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _textField('Expense ID', expenseId, readOnly: !isEditMode),
                  _textField('Project', project, readOnly: !isEditMode),
                  _textField('Mileage Type', mileage, readOnly: !isEditMode),
                  _textField('Vehicle Type', vehicle, readOnly: !isEditMode),

                  const Text(
                    "Travelling Points",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 🟢 Always show Start Trip
                  _textField(
                      'Start Trip', TextEditingController(text: startLoc),
                      readOnly: true),

                  // 🟡 Show Stop Points only if not round trip and has intermediate points
                  if (!isRoundTrip && expense.travelPoints.length > 2)
                    ...List.generate(expense.travelPoints.length - 2, (index) {
                      final stopLoc =
                          expense.travelPoints[index + 1].fromLocation;
                      return _textField('Stopping Point ${index + 1}',
                          TextEditingController(text: stopLoc),
                          readOnly: true);
                    }),

                  // 🔴 Show End Trip
                  _textField('End Trip', TextEditingController(text: endLoc),
                      readOnly: true),
                  _textField('Total Distance in Km',
                      TextEditingController(text: totalDistance.text),
                      readOnly: true),
                  _textField('Total Amount in INR',
                      TextEditingController(text: totalAmount.text),
                      readOnly: true),
                  _textField('Total Amount in INR',
                      TextEditingController(text: totalAmount.text),
                      readOnly: true),
                  // 💵 Totals

                  const SizedBox(height: 16),
                   _buildSection(
                title: "Tracking History",
                children: [
                  const SizedBox(height: 12),
                  FutureBuilder<List<ExpenseHistory>>(
                    future: historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final historyList = snapshot.data!;
                      if (historyList.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'The expense does not have a history. Please consider submitting it for approval.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item = historyList[index];
                          print("Trackingitem: $item");
                          return _buildTimelineItem(
                            item,
                            index == historyList.length - 1,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () {},
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFF7B61FF)),
                      //   child: const Text('Cancel Per Diem'),
                      // ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            textColor: Colors.deepPurple,
            iconColor: Colors.deepPurple,
            collapsedIconColor: Colors.grey,
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            children: children,
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool? bool,
      {int maxLines = 1, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: bool,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
  Widget _textField(String label, TextEditingController controller,
      {bool readOnly = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(value, style: const TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue),
            if (!isLast)
              Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.eventType,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.notes),
                  const SizedBox(height: 6),
                  Text(
                    'Submitted on ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
