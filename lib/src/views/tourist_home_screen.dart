import 'package:flutter/material.dart';

class TouristHomePage extends StatefulWidget {
  const TouristHomePage({Key? key}) : super(key: key);

  @override
  TouristHomePageState createState() => TouristHomePageState();
}

class TouristHomePageState extends State<TouristHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Guides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search action
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // This would be your dynamic guides list length
        itemBuilder: (context, index) {
          return const GuideCard(
            guideName: 'Guide \$index', // Replace with actual data
            guideLocation: 'Istanbul, Turkey', // Replace with actual data
            guideDescription: 'Travel is curiosity set in motion.', // Replace with actual data
            guideRating: 3, // Replace with actual data
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Locals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour),
            label: 'Tour',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}

class GuideCard extends StatelessWidget {
  final String guideName;
  final String guideLocation;
  final String guideDescription;
  final int guideRating;

  const GuideCard({
    Key? key,
    required this.guideName,
    required this.guideLocation,
    required this.guideDescription,
    required this.guideRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                // Normally NetworkImage should be used for network images
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
              title: Text(guideName),
              subtitle: Text(guideLocation),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    guideDescription,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Row(
                    children: List.generate(
                      guideRating,
                      (index) => const Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
