import 'package:attend_system/core/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserRecordsPage extends StatelessWidget {
  const UserRecordsPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.workId,
  });

  final String userId;
  final String userName;
  final String workId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '$userName Records',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('records')
            .orderBy('attendance', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading records'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No attendance records found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final data = record.data() as Map<String, dynamic>;

              return _buildRecordCard(context, record.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, String date, Map<String, dynamic> data) {
    final Timestamp? attendance = data['attendance'];
    final Timestamp? departure = data['departure'];
    final Map<String, dynamic>? location = data['location'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time and Location Information
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    'Check In',
                    attendance,
                    Icons.login,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeInfo(
                    'Check Out',
                    departure,
                    Icons.logout,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLocationInfo(
                    context,
                    'Check In Location',
                    location?['latitude']?.toDouble(),
                    location?['longitude']?.toDouble(),
                    Icons.location_on,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String title, Timestamp? timestamp, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timestamp != null
                ? formatDate(timestamp.toDate().toLocal(), [hh, ':', nn, ' ', am])
                : 'Not recorded',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(
    BuildContext context,
    String title,
    double? lat,
    double? lng,
    IconData icon,
    Color color,
  ) {
    final bool hasLocation = lat != null && lng != null && lat != 0.0 && lng != 0.0;

    return GestureDetector(
      onTap: hasLocation ? () => _openGoogleMaps(context, lat, lng) : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hasLocation ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasLocation ? color.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: hasLocation ? color : Colors.grey,
                  size: 16,
                ),
                if (hasLocation)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 4,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: hasLocation ? color : Colors.grey,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasLocation) ...[
              const SizedBox(height: 7),
              Text(
                'Tap to view',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(
                'No location',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = parts[0];
        final month = parts[1];
        final year = parts[2];
        return '$day/$month/$year';
      }
    } catch (e) {
      // If parsing fails, return the original string
    }
    return dateString;
  }

  Future<void> _openGoogleMaps(BuildContext context, double lat, double lng) async {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
