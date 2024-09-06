import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Restaurant {
  final String name;

  Restaurant({required this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(name: json['name']);
  }
}

final restaurantProvider = FutureProvider<List<Restaurant>>((ref) async {
  final data = await rootBundle.loadString('assets/restaurants.json');
  final List<dynamic> jsonList = json.decode(data);
  return jsonList.map((json) => Restaurant.fromJson(json)).toList();
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fate Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RestaurantListScreen(),
    );
  }
}

class RestaurantListScreen extends ConsumerStatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends ConsumerState<RestaurantListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant List'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground Content
          restaurants.when(
            data: (data) {
              final filteredRestaurants = data
                  .where((restaurant) => restaurant.name
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList();
              return ListView.builder(
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = filteredRestaurants[index];
                  return ListTile(
                    title: Text(restaurant.name),
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }
}
