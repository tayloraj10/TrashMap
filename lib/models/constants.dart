import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const appName = 'Trash Map';

const primaryColor = Color.fromARGB(255, 15, 111, 18);

dateToString(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

dateTimeToString(DateTime date) {
  return DateFormat('yyyy-MM-dd hh:mm:ss a').format(date);
}

timestampToString(Timestamp date) {
  return DateFormat('yyyy-MM-dd').format(date.toDate());
}

stringToDate(String date) {
  return DateTime.parse(date);
}

stringToDateTime(String date) {
  return DateFormat('yyyy-MM-dd hh:mm:ss a').parse(date);
}
