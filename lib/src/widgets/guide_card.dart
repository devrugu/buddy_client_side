import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

class GuideCard extends StatelessWidget {
  final List<String> imageUrls;
  final String name;
  final int age;
  final double rating;
  final int reviewCount;

  GuideCard({
    required this.imageUrls,
    required this.name,
    required this.age,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Image.network(imageUrls[index], fit: BoxFit.cover);
              },
              itemCount: imageUrls.length,
              pagination: const SwiperPagination(),
              control: const SwiperControl(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("$name, $age"),
              subtitle: Row(
                children: [
                  ...List.generate(
                      5,
                      (index) => Icon(
                            Icons.star,
                            color: index < rating ? Colors.amber : Colors.grey,
                          )),
                  const SizedBox(width: 10),
                  Text("$reviewCount reviews"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
