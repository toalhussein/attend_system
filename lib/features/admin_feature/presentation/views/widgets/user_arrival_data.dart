// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class UserArrivalData extends StatelessWidget {
  const UserArrivalData({
    super.key,
    this.arrivalTime,
    this.departueTime,
    this.workingTime,
  });

  final String? arrivalTime;
  final String? departueTime;
  final String? workingTime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we have enough space for horizontal layout
        bool useHorizontalLayout = constraints.maxWidth > 300;
        
        if (useHorizontalLayout) {
          return _buildHorizontalLayout();
        } else {
          return _buildVerticalLayout();
        }
      },
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildDataColumn('Arrival', arrivalTime ?? '-'),
        ),
        _buildDivider(isVertical: true),
        Expanded(
          child: _buildDataColumn('Departure', departueTime ?? '-'),
        ),
        _buildDivider(isVertical: true),
        Expanded(
          child: _buildDataColumn('Working Time', workingTime ?? '-'),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        _buildDataRow('Arrival', arrivalTime ?? '-'),
        _buildDivider(isVertical: false),
        _buildDataRow('Departure', departueTime ?? '-'),
        _buildDivider(isVertical: false),
        _buildDataRow('Working Time', workingTime ?? '-'),
      ],
    );
  }

  Widget _buildDataColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider({required bool isVertical}) {
    if (isVertical) {
      return const SizedBox(
        height: 30,
        child: VerticalDivider(
          thickness: 1,
          color: Colors.grey,
        ),
      );
    } else {
      return const Divider(
        thickness: 1,
        color: Colors.grey,
        height: 20,
      );
    }
  }
}
