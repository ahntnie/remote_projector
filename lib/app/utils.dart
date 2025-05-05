import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_constants.dart';

String convertToMD5(String input) {
  var bytes = utf8.encode(input);
  var digest = md5.convert(bytes);

  return digest.toString();
}

bool validatePassword(String password) {
  password.replaceAll(' ', '');
  final regex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  return regex.hasMatch(password);
}

String convertTimeString(String timeString) {
  DateFormat initialFormat = DateFormat('dd/MM/yyyy');
  DateFormat newFormat = DateFormat('yyyy-MM-dd');

  DateTime dateTime = initialFormat.parse(timeString);
  String newTimeString = newFormat.format(dateTime);

  return newTimeString;
}

String convertDateTimeString(DateTime dateTime) {
  DateFormat newFormat = DateFormat('yyyy-MM-dd');

  String newTimeString = newFormat.format(dateTime);

  return newTimeString;
}

String? convertTimeString2(String? timeString) {
  if (timeString == null || timeString.contains('0000-00-00')) return null;

  DateFormat initialFormat = DateFormat('yyyy-MM-dd');
  DateFormat newFormat = DateFormat('dd/MM/yyyy');

  DateTime dateTime = initialFormat.parse(timeString);
  String newTimeString = newFormat.format(dateTime);

  return newTimeString;
}

String? convertDateTimeString2(String? timeString) {
  if (timeString == null || timeString.contains('0000-00-00')) return null;

  DateFormat initialFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  DateFormat newFormat = DateFormat('dd/MM/yyyy hh:mm:ss');

  DateTime dateTime = initialFormat.parse(timeString);
  String newTimeString = newFormat.format(dateTime);

  return newTimeString;
}

String formatDateToString(DateTime time) {
  return DateFormat('dd/MM/yyyy').format(time);
}

String formatTimeToString(DateTime time) {
  return DateFormat('hh:mm:ss').format(time);
}

DateTime stringToDateTime(String time) {
  return DateFormat('dd/MM/yyyy').parse(time);
}

DateTime? stringToFullDateTime(String? dateStr) {
  if (dateStr == null) {
    return null;
  }

  DateTime? dateTime = DateTime.tryParse(dateStr);

  return dateTime;
}

String convertStringTime(String? time) {
  if (time == null) return '';

  if (time.length > 5 && time.contains(':')) {
    return time.substring(0, 5);
  }
  return time;
}

DateTime parseDateString(String dateString) {
  return DateFormat('yyyy-MM-dd').parse(dateString);
}

int calculateDaysDifference(DateTime fromDate, DateTime toDate) {
  return toDate.difference(fromDate).inDays.abs();
}

Color randomHexColor() {
  Random random = Random();
  const hexDigits = '0123456789ABCDEF';
  String colorCode = '';
  for (int i = 0; i < 6; i++) {
    colorCode += hexDigits[random.nextInt(16)];
  }
  return Color(int.parse(colorCode, radix: 16) + 0xFF000000);
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String convertTime(TimeOfDay time) {
  int hour = time.hour;
  int minute = time.minute;

  String hourString = hour < 10 ? '0$hour' : '$hour';
  String minuteString = minute < 10 ? '0$minute' : '$minute';

  return '$hourString:$minuteString';
}

bool compareTwoTime(TimeOfDay time1, TimeOfDay time2) {
  bool t2Later = false;
  if (time1.hour < time2.hour) {
    t2Later = true;
  } else if (time1.hour == time2.hour) {
    if (time1.minute < time2.minute) {
      t2Later = true;
    }
  }
  return t2Later;
}

TimeOfDay? stringToTimeOfDay(String? timeString) {
  if (timeString == null) return null;

  final format = timeString.split(':');

  if (format.length < 2) return null;

  final hour = int.parse(format[0]);
  final minute = int.parse(format[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}

String getFormattedDate(DateTime date) {
  DateTime now = DateTime.now();
  DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));

  if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  } else {
    return DateFormat('dd/MM').format(date);
  }
}

void copyToClipboard(String? text, BuildContext context) {
  if (text == null) return;

  Clipboard.setData(ClipboardData(text: text));
  if (!(Platform.isAndroid || Platform.isIOS)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép vào bộ nhớ tạm!')),
    );
  }
}

int compareWeekdays(String a, String b) {
  int indexA = AppConstants.days.indexOf(a);
  if (indexA == -1) indexA = AppConstants.days.length;

  int indexB = AppConstants.days.indexOf(b);
  if (indexB == -1) indexB = AppConstants.days.length;

  return indexA.compareTo(indexB);
}

bool isImageUrl(String url) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  final uri = Uri.parse(url);
  final extension = uri.pathSegments.last.split('.').last.toLowerCase();
  return imageExtensions.contains(extension);
}

String formatNumber(String? numberString) {
  if (numberString == null) return '0';

  NumberFormat formatter = NumberFormat('#,###');

  int number = int.parse(numberString);

  return formatter.format(number);
}

bool isDatePast(String? dateString) {
  if (dateString == null) return true;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final DateTime inputDate = dateFormat.parse(dateString);
  final DateTime currentDate = DateTime.now();

  return inputDate.isBefore(currentDate);
}

bool isBeforeNow(String? dateString) {
  if (dateString == null || dateString.isEmpty) return false;

  try {
    DateTime inputDate = DateTime.parse(dateString);
    return DateTime.now().isBefore(inputDate);
  } catch (e) {
    return false;
  }
}

bool isValidDate(String? dateString) {
  if (dateString == null) return true;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final DateTime inputDate = dateFormat.parse(dateString);
  final DateTime currentDate = DateTime.now();

  return inputDate.isBefore(currentDate);
}

String addMonthsAndFormat(
    {String? startDate, String? monthsToAdd, int plusNextDay = 0}) {
  int month = monthsToAdd == null ? 0 : int.parse(monthsToAdd);

  DateTime currentDate =
      startDate == null ? DateTime.now() : parseDateString(startDate);

  DateTime nextDay = currentDate.add(Duration(days: plusNextDay));

  DateTime newDate = DateTime(
    nextDay.year,
    nextDay.month + month,
    nextDay.day,
  );

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  return dateFormat.format(newDate);
}

String getNowTimeString() {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final now = DateTime.now();

  return dateFormat.format(now);
}

bool isCurrentDateBefore30Days(String? targetDateString) {
  if (targetDateString == null) return false;

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateTime targetDate = dateFormat.parse(targetDateString);
  DateTime currentDate = DateTime.now();
  DateTime dateBefore30Days = targetDate.subtract(const Duration(days: 30));

  return currentDate.isAfter(dateBefore30Days);
}

bool isAllDigits(String? input) {
  if (input == null) return false;

  final numericRegex = RegExp(r'^[0-9]+$');
  return numericRegex.hasMatch(input);
}

int compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
  if (a.hour == b.hour) {
    return a.minute.compareTo(b.minute);
  } else {
    return a.hour.compareTo(b.hour);
  }
}

bool checkIfWithinFiveMinutes(String? lastAlive) {
  if (lastAlive.isEmptyOrNull) return false;

  DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateTime lastAliveTime = format.parse(lastAlive!);
  DateTime currentTime = DateTime.now();

  Duration difference = currentTime.difference(lastAliveTime);

  if (difference.inMinutes <= 5 && difference.inSeconds >= 0) {
    return true;
  } else if (difference.isNegative) {
    return true;
  }

  return false;
}

String convertDateTimeFormat(String? originalDateTime) {
  if (originalDateTime.isEmptyOrNull) return '';

  DateFormat originalFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateFormat newFormat = DateFormat('HH:mm:ss - dd/MM/yyyy');

  DateTime dateTime = originalFormat.parse(originalDateTime!);

  return newFormat.format(dateTime);
}

extension DateTimeStringExtension on String {
  bool isBeforeBuildDate(String dateB) {
    DateFormat format = DateFormat("dd/MM/yyyy HH:mm");

    DateTime dateTimeA = format.parse(this);
    DateTime dateTimeB = format.parse(dateB);

    return dateTimeA.isBefore(dateTimeB);
  }
}

Future<bool> isVideoUrlValid(String? url) async {
  if (url == null) return false;

  try {
    final dio = Dio();
    final response = await dio.head(url);

    if (response.statusCode == 200 &&
        response.headers['content-type'] != null) {
      final contentType = response.headers['content-type']!.first;
      return contentType.startsWith('video/');
    }
  } catch (_) {}

  return false;
}

Future<bool> isImageUrlValid(String? url) async {
  if (url == null) return false;

  try {
    final dio = Dio();
    final response = await dio.head(url);

    if (response.statusCode == 200 &&
        response.headers['content-type'] != null) {
      final contentType = response.headers['content-type']!.first;
      return contentType.startsWith('image/');
    }
  } catch (_) {}

  return false;
}

String formatDuration(Duration duration) {
  return duration.toString().split('.').first;
}

bool get isMobile => Platform.isAndroid || Platform.isIOS;

bool isSupportedFile(String path) {
  final ext = path.split('.').last.toLowerCase();
  return ['mp4', 'mov', 'wmv', 'mkv', 'webm', 'avi', 'mpeg', 'mpg']
      .contains(ext);
}
