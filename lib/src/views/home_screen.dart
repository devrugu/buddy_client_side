import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required Key key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildGuideCards(),
          _buildFindGuideButton(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text("Tourist Name"),
            accountEmail: Text("tourist@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("T", style: TextStyle(fontSize: 40.0)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Navigate to Profile Screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to Settings Screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              // Sign out user
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCards() {
    return ListView.builder(
      itemCount: 5, // Number of guides
      itemBuilder: (context, index) {
        return _buildGuideCard();
      },
    );
  }

  Widget _buildGuideCard() {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(
            height: 200.0,
            child: PageView(
              controller: _pageController,
              children: [
                Image.network('https://via.placeholder.com/400',
                    fit: BoxFit.cover),
                Image.network('https://via.placeholder.com/400',
                    fit: BoxFit.cover),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          SmoothPageIndicator(
            controller: _pageController,
            count: 2,
            effect: const ExpandingDotsEffect(
              dotHeight: 8.0,
              dotWidth: 8.0,
              activeDotColor: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Guide Name, Age",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: 4.5,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8.0),
                    const Text("30 reviews"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildFindGuideButton() {
    return Positioned(
      bottom: 20.0,
      right: 20.0,
      child: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Filter Screen
        },
        label: const Text("Find Your Guide"),
        icon: const Icon(Icons.search),
      ),
    );
  }
}
