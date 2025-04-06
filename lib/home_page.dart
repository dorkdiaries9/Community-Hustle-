import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔑 Needed for Firebase User

import '../models/event_model.dart';
import '../widgets/event_card.dart';

class HomePage extends StatefulWidget {
  final User user; // ✅ Accept user from MainWrapper
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> bannerImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  List<EventModel> events = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date')
          .get();

      final List<EventModel> loaded = snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.id, doc.data());
      }).toList();

      setState(() {
        events = loaded;
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      print("❌ Error fetching events: $e");
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Widget buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchEvents,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 Top Navbar with user info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Community Hustle',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.user.photoURL ??
                                'https://via.placeholder.com/150', // fallback
                          ),
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.notifications_none, color: Colors.grey[700]),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 🔷 Carousel
              CarouselSlider(
                items: bannerImages.map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
              ),

              const SizedBox(height: 20),

              // 🔷 Feed Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.explore, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      "Explore Events",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 🔷 Event Feed
              Expanded(
                child: isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 4,
                        itemBuilder: (_, __) => buildShimmerCard(),
                      )
                    : isError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.error_outline, size: 40, color: Colors.red),
                                SizedBox(height: 8),
                                Text("Failed to load events. Try again!"),
                              ],
                            ),
                          )
                        : events.isEmpty
                            ? const Center(child: Text("No events found!"))
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: events.length,
                                itemBuilder: (context, index) =>
                                    EventCard(event: events[index]),
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
