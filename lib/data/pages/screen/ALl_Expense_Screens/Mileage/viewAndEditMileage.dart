import 'dart:convert';
import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MileageDetailsPage extends StatefulWidget {
  final ExpenseModelMileage? mileageId;

  const MileageDetailsPage({super.key,  this.mileageId});

  @override
  State<MileageDetailsPage> createState() => _MileageDetailsPageState();
}

class _MileageDetailsPageState extends State<MileageDetailsPage> {
  bool isEditMode = false;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _stopController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  String expenseId = '';
  String employeeId = '';
  String status = '';
  String vehicle = '';
  String project = '';
  String mileage = '';
  double totalDistance = 0;
  double totalAmount = 0;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String googleApiKey = 'AIzaSyDRILJyIU6u6pII7EEP5_n7BQwYZLWr8E0';


 @override
  void initState() {
    super.initState();

    if (widget.mileageId != null) {
      final expense = widget.mileageId!;

      if (expense.travelPoints.isNotEmpty) {
        _startController.text = expense.travelPoints.first.fromLocation;
        _endController.text = expense.travelPoints.last.fromLocation;

        // Midpoint as stop (if any)
        if (expense.travelPoints.length > 2) {
          _stopController.text = expense.travelPoints[1].fromLocation;
        }
      }

      setState(() {
        expenseId = expense.expenseId;
        employeeId = expense.employeeId;
        status = expense.approvalStatus;
        // vehicle = expense.vehicleType ?? '';
        project = expense.projectId;
        mileage = expense.expenseStatus;
        totalDistance = expense.travelPoints.fold(
            0, (sum, tp) => sum + tp.quantity);
        totalAmount = totalDistance * 40; // Example
      });
    }
    _drawRoute(
        _startController.text,
        _stopController.text,
        _endController.text,
      );
    //  _fetchMileageDetails();
  }
  // Future<void> _fetchMileageDetails() async {
  //   final response = await http.get(
  //       Uri.parse("https://your-api.com/mileage/${widget.mileageId}"));
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);

  //     setState(() {
  //       expenseId = data['expense_id'].toString();
  //       employeeId = data['employee_id'].toString();
  //       status = data['status'];
  //       vehicle = data['vehicle'];
  //       project = data['project'];
  //       mileage = data['mileage'];
  //       totalDistance = data['total_distance'];
  //       totalAmount = data['total_amount'];
  //       _startController.text = data['start_point'];
  //       _stopController.text = data['stop_point'];
  //       _endController.text = data['end_point'];
  //     });

  //     await _drawRoute(
  //       _startController.text,
  //       _stopController.text,
  //       _endController.text,
  //     );
  //   }
  // }

  Future<void> _drawRoute(String start, String stop, String end) async {
    _markers.clear();
    _polylines.clear();

    final startLoc = await _getLatLng(start);
    final stopLoc = await _getLatLng(stop);
    final endLoc = await _getLatLng(end);

    if (startLoc != null && endLoc != null) {
      // Add markers
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: startLoc,
        infoWindow: InfoWindow(title: 'Start', snippet: start),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
      if (stopLoc != null) {
        _markers.add(Marker(
          markerId: const MarkerId('stop'),
          position: stopLoc,
          infoWindow: InfoWindow(title: 'Stop', snippet: stop),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ));
      }
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: endLoc,
        infoWindow: InfoWindow(title: 'End', snippet: end),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));

      // Draw route
      await _fetchPolyline(startLoc, stopLoc, endLoc);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              startLoc.latitude < endLoc.latitude
                  ? startLoc.latitude
                  : endLoc.latitude,
              startLoc.longitude < endLoc.longitude
                  ? startLoc.longitude
                  : endLoc.longitude,
            ),
            northeast: LatLng(
              startLoc.latitude > endLoc.latitude
                  ? startLoc.latitude
                  : endLoc.latitude,
              startLoc.longitude > endLoc.longitude
                  ? startLoc.longitude
                  : endLoc.longitude,
            ),
          ),
          50,
        ),
      );

      setState(() {});
    }
  }

  Future<LatLng?> _getLatLng(String address) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

  Future<void> _fetchPolyline(LatLng start, LatLng? stop, LatLng end) async {
    String waypoints = stop != null
        ? "&waypoints=${stop.latitude},${stop.longitude}"
        : "";
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}$waypoints&destination=${end.latitude},${end.longitude}&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        String encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: _decodePolyline(encodedPolyline),
        ));
      }
    }
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

  Future<void> _saveMileage() async {
    final response = await http.put(
      Uri.parse("https://your-api.com/mileage/${widget.mileageId}"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'start_point': _startController.text,
        'stop_point': _stopController.text,
        'end_point': _endController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mileage updated successfully')),
      );
      setState(() => isEditMode = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update mileage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Mileage'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditMode) {
                await _saveMileage();
              } else {
                setState(() => isEditMode = true);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(15), // reduced curve
            ),
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
                  // Expense Info
                  Row(
                    children: [
                      _infoLabel('Expense ID:', expenseId),
                      _infoLabel('Employee ID:', employeeId),
                      _infoLabel('Status:', status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Details Fields
                  _textField('Start Location *', _startController,
                      readOnly: !isEditMode),
                  _textField('Stopping Point A', _stopController,
                      readOnly: !isEditMode),
                  _textField('End Trip', _endController,
                      readOnly: !isEditMode),

                  _readOnlyField('Total Distance in',
                      '${totalDistance.toStringAsFixed(1)} Km'),
                  _readOnlyField('Total Amount in',
                      '${totalAmount.toStringAsFixed(2)} INR'),

                  const SizedBox(height: 16),

                  // History Timeline Placeholder
                  _historyTimeline(),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF7B61FF), // purple gradient start
                        ),
                        child: const Text('Cancel Per Diem'),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoLabel(String title, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Text(value),
            ),
          ],
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
        onChanged: (_) {
          if (isEditMode) {
            _drawRoute(
              _startController.text,
              _stopController.text,
              _endController.text,
            );
          }
        },
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return _textField(
      label,
      TextEditingController(text: value),
      readOnly: true,
    );
  }

  Widget _historyTimeline() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Show History',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          SizedBox(height: 8),
          // Placeholder for timeline
          Text('Create > Level-1 > Level-2 > Approved'),
        ],
      ),
    );
  }
}
