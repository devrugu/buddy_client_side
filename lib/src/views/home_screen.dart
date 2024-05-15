import 'package:flutter/material.dart';
import '../widgets/guide_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> guides = [
    {
      'name': 'Uğurcan Yılmaz',
      'age': 24,
      'rating': 4.0,
      'reviewCount': 30,
      'imageUrls': [
        'https://picsum.photos/200/300',
        'https://picsum.photos/200/300'
      ],
      'hourlyRate': 55,
    },
    {
      'name': 'Senoş Engin',
      'age': 24,
      'rating': 4.5,
      'reviewCount': 45,
      'imageUrls': [
        'https://picsum.photos/400/400',
        'https://picsum.photos/200/300'
      ],
      'hourlyRate': 75,
    },
    {
      'name': 'ahmet mehmet',
      'age': 24,
      'rating': 3,
      'reviewCount': 11,
      'imageUrls': [
        'https://picsum.photos/200/300',
        'https://picsum.photos/200/300',
        'https://picsum.photos/200/300'
      ],
      'hourlyRate': 75,
    },
  ];

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open drawer
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        NetworkImage('https://example.com/user.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text('User Name', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                // Navigate to profile screen
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings screen
              },
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                // Sign out
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: guides.length,
        itemBuilder: (context, index) {
          final guide = guides[index];
          return GuideCard(
            key: ValueKey(guide['name']),
            guideName: guide['name'],
            age: guide['age'],
            rating: guide['rating'],
            reviewCount: guide['reviewCount'],
            imageUrls: guide['imageUrls'],
            hourlyRate: guide['hourlyRate'],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to filter screen
        },
        label: const Text('Find Your Guide'),
        icon: const Icon(Icons.search),
      ),
    );
  }
}
