import 'package:attend_system/features/admin_feature/presentation/views/widgets/user_arrival_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class UserDetailsCard extends StatefulWidget {
  const UserDetailsCard({
    super.key,
    required this.userName,
    required this.workId,
    this.arrivalTime,
    this.departTime,
    this.workingTime,
    required this.lat,
    required this.lang,
    required this.outLat,
    required this.outLang,
  });

  final String userName;
  final String workId;
  final String? arrivalTime;
  final String? departTime;
  final String? workingTime;
  final double lat;
  final double lang;
  final double outLat;
  final double outLang;

  @override
  State<UserDetailsCard> createState() => _UserDetailsCardState();
}

class _UserDetailsCardState extends State<UserDetailsCard> {
  String? checkInAddress;
  String? checkOutAddress;
  bool loadingCheckIn = false;
  bool loadingCheckOut = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations if needed
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    // Load check-in address
    if (widget.lat != 0.0 && widget.lang != 0.0) {
      if (mounted) setState(() => loadingCheckIn = true);
      try {
        final address = await _getAddressFromCoordinates(widget.lat, widget.lang);
        if (mounted) {
          setState(() {
            checkInAddress = address;
            loadingCheckIn = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => loadingCheckIn = false);
      }
    }

    // Load check-out address
    if (widget.outLat != 0.0 && widget.outLang != 0.0) {
      if (mounted) setState(() => loadingCheckOut = true);
      try {
        final address = await _getAddressFromCoordinates(widget.outLat, widget.outLang);
        if (mounted) {
          setState(() {
            checkOutAddress = address;
            loadingCheckOut = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => loadingCheckOut = false);
      }
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^, |, $'), '') // Remove leading/trailing commas
            .replaceAll(RegExp(r', ,'), ','); // Remove double commas
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return 'Address not available';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ID: ${widget.workId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Location Section
            Row(
              children: [
                Expanded(
                  child: _buildLocationInfo(
                    'Check In',
                    widget.lat,
                    widget.lang,
                    Icons.login,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLocationInfo(
                    'Check Out',
                    widget.outLat,
                    widget.outLang,
                    Icons.logout,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Time Data Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: UserArrivalData(
                  arrivalTime: widget.arrivalTime,
                  departueTime: widget.departTime,
                  workingTime: widget.workingTime,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String title, double lat, double lng, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _openGoogleMaps(lat, lng),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(icon, color: color, size: 24),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tap to view on map',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 8,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _openGoogleMaps(double lat, double lng) async {
    // Check if coordinates are valid (not 0,0 which indicates no location)
    if (lat == 0.0 && lng == 0.0) {
      _showLocationNotAvailable();
      return;
    }

    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final googleMapsAppUrl = 'comgooglemaps://?q=$lat,$lng';
    
    try {
      // Try to open in Google Maps app first
      if (await canLaunchUrl(Uri.parse(googleMapsAppUrl))) {
        await launchUrl(Uri.parse(googleMapsAppUrl));
      } else {
        // Fallback to web version
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // If all fails, show error message
      _showLocationError();
    }
  }

  void _showLocationNotAvailable() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location coordinates not available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLocationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
