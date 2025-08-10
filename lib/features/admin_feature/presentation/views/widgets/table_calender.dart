import 'package:attend_system/core/calendar_notifier.dart';
import 'package:flutter/material.dart';

class CustomTableCalender extends StatefulWidget {
  const CustomTableCalender({super.key});

  @override
  State<CustomTableCalender> createState() => _CustomTableCalenderState();
}

class _CustomTableCalenderState extends State<CustomTableCalender> {
  DateTime focusedDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  bool showMonthYearPicker = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with month/year selector and navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _previousMonth,
                ),
                GestureDetector(
                  onTap: () => _showMonthYearSelector(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getHeaderText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // Week days
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _buildWeekDays(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getHeaderText() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[focusedDate.month - 1]} ${focusedDate.year}';
  }

  List<Widget> _buildWeekDays() {
    // Get current week containing the focused date
    final startOfWeek = _getStartOfWeek(focusedDate);
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return weekDays.map((day) {
      final isSelected = _isSameDay(day, selectedDate);
      final isToday = _isSameDay(day, DateTime.now());
      final isCurrentMonth = day.month == focusedDate.month;
      
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = day;
              focusedDate = day; // Update focused date to follow selection
              CustomNotifier.selectDate(day);
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : isToday
                      ? Colors.orange
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getDayName(day.weekday)[0],
                  style: TextStyle(
                    color: isSelected 
                        ? const Color(0xFF667eea) 
                        : isCurrentMonth 
                            ? Colors.white 
                            : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF667eea)
                        : isToday
                            ? Colors.white
                            : isCurrentMonth 
                                ? Colors.white
                                : Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  String _getDayName(int weekday) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _previousMonth() {
    setState(() {
      focusedDate = DateTime(focusedDate.year, focusedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      focusedDate = DateTime(focusedDate.year, focusedDate.month + 1, 1);
    });
  }

  void _showMonthYearSelector() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: focusedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        focusedDate = picked;
        // If selected date is not in the new month, reset to first day of month
        if (selectedDate.month != picked.month || selectedDate.year != picked.year) {
          selectedDate = DateTime(picked.year, picked.month, 1);
          CustomNotifier.selectDate(selectedDate);
        }
      });
    }
  }
}
