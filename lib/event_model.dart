import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String NGO;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime date;

  EventModel({
    required this.id,
    required this.title,
    required this.NGO,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.date,
  });

  //This method is crucial for Firestore data conversion
  factory EventModel.fromMap(String id, Map<String, dynamic> data) {
  return EventModel(
    id: id,
    title: data['title'] ?? '',
    NGO: data['NGO'] ?? '',
    description: data['description'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    location: data['location'] ?? '',
    date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),

  );
}

  // Optional: Useful if you're writing back to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'NGO': NGO,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'date': Timestamp.fromDate(date),
    };
  }
}  
