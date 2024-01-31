// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';

class ScanScreen extends StatefulWidget {
  final Function(String) onScanResult;

  ScanScreen({required this.onScanResult});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: MobileScannerController(
        returnImage: true,
        detectionSpeed: DetectionSpeed.noDuplicates,
      ),
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        final Uint8List? image = capture.image;
        for (final index in barcodes) {
          print('barcode string:${index.rawValue}');
          widget.onScanResult(index.rawValue!);
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool check = true;
  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      print('Location permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever');
    } else {
      print('Location permission granted');
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      await requestLocationPermission();

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> checkInOut(String action, String scannedBarcode) async {
  try {
    final Map<String, dynamic> qrCodeData = json.decode(scannedBarcode);
    final Map<String, dynamic> companyLocation = qrCodeData['companyLocation'];
    final double companyLatitude = companyLocation['latitude'];
    final double companyLongitude = companyLocation['longitude'];
    final String barcodeId = qrCodeData['timestamp']; 

//assigning getCurrentLocation() results to deviceLocation
    final Position? deviceLocation = await getCurrentLocation();

    if (deviceLocation != null) {
      print('LOC IS ON..........');
      if (compareLocations(
          deviceLocation.latitude, deviceLocation.longitude, companyLatitude, companyLongitude)) {
        print('COMPARISON SUCCEEDED.......');
        final response = await http.post(
          Uri.parse('http://192.168.100.118:8084/api/BarcodeApp/${action.toLowerCase()}'),
          headers: {'Content-Type': 'application/json'},
          body: '{"barcodeId": "$barcodeId","name":"${widget.username}"}',
        );
        print(scannedBarcode);
        print('API Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          print('$action successful');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$action successful'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        }else {
      print('$action failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
       final Map<String, dynamic> errorData = json.decode(response.body);

        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is Map<String, dynamic>) {
            errors.forEach((key, value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        } else {
          final Map<String, dynamic> errorData = json.decode(response.body);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${errorData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
    }
  
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location does not match with QR code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Device location not available');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  bool compareLocations(double lat1, double lon1, double lat2, double lon2) {
    try {
      // Use geolocator's distanceBetween to calculate the distance
      double distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

      // Print the distance for debugging
      print('Distance between locations: $distance meters');

      //maximum allowed distance b/w two locations
      const double distanceThreshold = 40.0; 

      // Check if the distance is within the threshold
      //it return true if condition is correct
      return distance <= distanceThreshold;
    } catch (e) {
      print('Error comparing locations: $e');
      return false;
    }
  }

  Future<void> startScan(String action) async {
    try {
      final Position? deviceLocation = await getCurrentLocation();

      if (deviceLocation != null) {
        final scannedData = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanScreen(
              onScanResult: (result) {
                Navigator.pop(context, result);
              },
            ),
          ),
        );

        if (scannedData != null && scannedData.isNotEmpty) {
          checkInOut(action, scannedData);
        }
      } else {
        print('Device location not available');
      }
    } catch (e) {
      print('Error during scanning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Employee Checkin-out App ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            if (check == true)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    check = false;
                  });

                  // Corrected: Use async/await to wait for the result
                  await startScan('CheckIn');
                },
                child: Text(
                  'Check-In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 20.0),
            if (check == false)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    check = true;
                  });
                  // Corrected: Use async/await to wait for the result
                  startScan('CheckOut');
                },
                child: Text(
                  'Check-Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
