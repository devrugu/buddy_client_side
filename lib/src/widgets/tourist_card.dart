import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../utilities/data_structures.dart'; // Make sure to import this

class TouristCard extends StatefulWidget {
  final int touristId;
  final String name;
  final double? rating;
  final int? reviews;
  final List<String> pictures;
  final VoidCallback onTap;
  final bool serviceFinished;
  final Widget? extraButton;

  const TouristCard({
    Key? key,
    required this.touristId,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.pictures,
    required this.onTap,
    required this.serviceFinished,
    this.extraButton,
  }) : super(key: key);

  @override
  TouristCardState createState() => TouristCardState();
}

class TouristCardState extends State<TouristCard> {
  int _currentImageIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  items: widget.pictures.map((imageUrl) {
                    return Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        image: DecorationImage(
                          image: NetworkImage('$localUri/uploads/tourist/$imageUrl'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  carouselController: _carouselController,
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      widget.rating != null 
                        ? '${widget.rating} ★'
                        : 'Has no reviews',
                      style: TextStyle(
                        color: widget.rating != null ? Colors.white : Colors.red.shade300,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.pictures.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImageIndex == entry.key ? 12.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  widget.serviceFinished
                      ? const Text(
                          'Service Finished',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : widget.extraButton ?? Container(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  widget.rating != null 
                    ? buildRatingStars(widget.rating!)
                    : Container(),
                  const SizedBox(width: 5.0),
                  widget.reviews != null 
                    ? Text('(${widget.reviews} reviews)')
                    : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.yellow, size: 20.0);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.yellow, size: 20.0);
        } else {
          return const Icon(Icons.star_border, color: Colors.yellow, size: 20.0);
        }
      }),
    );
  }
}
