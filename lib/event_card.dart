import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              event.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  event.NGO,
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                const SizedBox(height: 6),
                Text(event.description,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(event.location),
                    const Spacer(),
                    Text(
                      "${event.date.day}/${event.date.month}/${event.date.year}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
