import 'package:cloud_firestore/cloud_firestore.dart';

class BigInfoProvider {
  static String? code;
  static String? codeInFireStore;
  static String? id;
  static String? idInFireStore;
  static String? title;
  static String? titleInFireStore;
  static String? mission;
  static String? missionInFireStore;
  static String? job;
  static String? jobInFireStore;
  static String? roomImage;
  static String? roomImageInFireStore;
  static String? registerTime;
  static String? registerTimeInFireStore;
}

class BigInfo {
  final String? code;
  final String? id;
  final String? title;
  final String? mission;
  final String? roomImage;
  final Timestamp? registerTime;

  BigInfo({
    required this.code,
    required this.id,
    required this.title,
    required this.mission,
    required this.roomImage,
    required this.registerTime,
  });
}

const String codeFieldName = 'code';
const String idFieldName = 'id';
const String titleFieldName = "title";
const String missionFieldName = "mission";
const String roomImageFieldName = 'roomImage';
const String registerTimeFieldName = "register-time";
