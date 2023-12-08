import 'package:cloud_firestore/cloud_firestore.dart';

class RoomProvider {
  static String? id;
  static String? title;
  static String? price;
  static String? context;
  static String? image;
  static String? registerTime;
  static String? users_id;
  static String? modifiedTime;
}

class Product {
  final String? context;
  final String? id;
  final String? title;
  final String? price;
  final String? image;
  final Timestamp? registerTime;
  final String? users_id;
  final String? modifiedTime;

  Product(
      {required this.id,
      required this.title,
      required this.price,
      required this.image,
      required this.registerTime,
      required this.users_id,
      required this.modifiedTime,
      required this.context});

  factory Product.fromFirebase(
      QueryDocumentSnapshot<Map<String, dynamic>> docSnap) {
    final snapshotData = docSnap.data();
    return Product(
      context: snapshotData[contextFieldName],
      id: snapshotData[idFieldName],
      title: snapshotData[titleFieldName],
      price: snapshotData[priceFieldName],
      image: snapshotData[imageFieldName],
      registerTime: snapshotData[registerTimeFieldName],
      users_id: snapshotData[users_idFieldName],
      modifiedTime: snapshotData[modifiedTimeFieldName],
    );
  }
}

const String contextFieldName = 'code';
const String idFieldName = 'id';
const String titleFieldName = "title";
const String priceFieldName = "price";
const String imageFieldName = 'image';
const String registerTimeFieldName = "register-time";
const String users_idFieldName = "users_id";
const String modifiedTimeFieldName = "modifiedTime";
