// Date Format Package Reference Guide
// This prevents common mistakes with date/time formatting

/*
Common date_format patterns:

TIME PATTERNS:
- hh = hour (01-12)
- HH = hour (01-24) 
- nn = minutes (00-59)  ⭐ USE THIS FOR MINUTES
- mm = month (01-12)    ⚠️ NOT FOR MINUTES!
- ss = seconds (00-59)
- am = AM/PM

DATE PATTERNS:
- yyyy = year (2025)
- mm = month (01-12)
- dd = day (01-31)
- M = month name (January)
- D = day name (Monday)

EXAMPLES:
✅ CORRECT for time: formatDate(dateTime, [hh, ':', nn, ' ', am])  // 02:45 PM
❌ WRONG for time:   formatDate(dateTime, [hh, ':', mm, ' ', am])  // 02:08 PM (shows month!)

✅ CORRECT for date: formatDate(dateTime, [dd, '/', mm, '/', yyyy])  // 07/08/2025
✅ CORRECT for full: formatDate(dateTime, [M, ' ', dd, ', ', yyyy, ' ', hh, ':', nn, ' ', am])  // August 07, 2025 02:45 PM
*/

import 'package:date_format/date_format.dart';

class DateTimeFormatterHelper {
  // Format time only (12-hour with AM/PM)
  static String formatTime12Hour(DateTime dateTime) {
    return formatDate(dateTime.toLocal(), [hh, ':', nn, ' ', am]);
  }
  
  // Format time only (24-hour)
  static String formatTime24Hour(DateTime dateTime) {
    return formatDate(dateTime.toLocal(), [HH, ':', nn, ':', ss]);
  }
  
  // Format date only
  static String formatDateOnly(DateTime dateTime) {
    return formatDate(dateTime.toLocal(), [dd, '/', mm, '/', yyyy]);
  }
  
  // Format full date and time
  static String formatFullDateTime(DateTime dateTime) {
    return formatDate(dateTime.toLocal(), [
      M, ' ', dd, ', ', yyyy, ' at ', hh, ':', nn, ' ', am
    ]);
  }
}

/*
COMMON MISTAKE EXPLANATION:
- You were using 'mm' for minutes, but 'mm' means MONTH
- That's why you always got '08' (August is the 8th month)
- The correct pattern for minutes is 'nn'

FIXED PATTERN:
Before: formatDate(timestamp.toDate(), [hh, ':', mm, ' ', am])  // ❌ Shows month
After:  formatDate(timestamp.toDate().toLocal(), [hh, ':', nn, ' ', am])  // ✅ Shows minutes

BENEFITS of .toLocal():
- Converts UTC time from Firebase to your local timezone
- Ensures users see the correct time for their location
*/
