import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

class GuideCard extends StatefulWidget {
  final String guideName;
  final int age;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final double hourlyRate;

  GuideCard({
    Key? key,
    required this.guideName,
    required this.age,
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.hourlyRate,
  }) : super(key: key);

  @override
  _GuideCardState createState() => _GuideCardState();
}

class _GuideCardState extends State<GuideCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 200, // Constrain the height of the PageView
                child: PageView.builder(
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(widget.imageUrls[index],
                        fit: BoxFit.cover);
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  color: Colors.black54,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    '${widget.hourlyRate}\$/h',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          DotsIndicator(
            dotsCount: widget.imageUrls.length,
            position: _currentImageIndex.toDouble(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.guideName}, ${widget.age}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.star,
                    color: widget.rating >= 1 ? Colors.amber : Colors.grey),
                Icon(Icons.star,
                    color: widget.rating >= 2 ? Colors.amber : Colors.grey),
                Icon(Icons.star,
                    color: widget.rating >= 3 ? Colors.amber : Colors.grey),
                Icon(Icons.star_half,
                    color: widget.rating > 3 && widget.rating < 4
                        ? Colors.amber
                        : Colors.grey),
                Icon(Icons.star,
                    color: widget.rating >= 4 ? Colors.amber : Colors.grey),
                Icon(Icons.star,
                    color: widget.rating >= 5 ? Colors.amber : Colors.grey),
                Text(' ${widget.reviewCount} reviews'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
