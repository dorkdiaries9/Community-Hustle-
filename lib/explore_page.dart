import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchEvents();
  }

  Future<List<EventModel>> fetchEvents() async {
    final snapshot = await _firestore.collection('events').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add doc ID to event data
      return EventModel.fromMap(data);
    }).toList();
  }

  Future<bool> checkIfApplied(String eventId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final snapshot = await _firestore
        .collection('applications')
        .where('user_id', isEqualTo: currentUser.uid)
        .where('event_id', isEqualTo: eventId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> applyToEvent(String eventId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final alreadyApplied = await checkIfApplied(eventId);
    if (alreadyApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already applied')),
      );
      return;
    }

    try {
      await _firestore.collection('applications').add({
        'user_id': currentUser.uid,
        'event_id': eventId,
        'application_status': 'Applied',
        'applied_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully')),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore Events")),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return FutureBuilder<bool>(
                future: checkIfApplied(event.id),
                builder: (context, snapshot) {
                  final isApplied = snapshot.data ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (event.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                event.imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(event.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('By ${event.ngoName}'),
                          const SizedBox(height: 8),
                          Text(event.description),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("📍 ${event.location}"),
                              Text("🗓️ ${event.date}"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: isApplied
                                ? null
                                : () => applyToEvent(event.id),
                            icon: Icon(isApplied
                                ? Icons.check_circle
                                : Icons.how_to_reg),
                            label: Text(isApplied ? 'Applied' : 'Apply Now'),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
