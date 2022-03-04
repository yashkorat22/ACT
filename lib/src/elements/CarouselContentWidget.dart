import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';

class CarouselContentWidget extends StatefulWidget {
  const CarouselContentWidget({Key? key, required this.items})
      : super(key: key);

  final List<Widget> items;

  @override
  _CarouselContentWidget createState() => _CarouselContentWidget();
}

class _CarouselContentWidget extends StateMVC<CarouselContentWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        children: [
          Container(
            width: 360,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 360,
                aspectRatio: 16 / 8,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: false,
                // autoPlayInterval: Duration(seconds: 10),
                // autoPlayAnimationDuration: Duration(milliseconds: 800),
                // autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() => _current = index);
                },
              ),
              items: widget.items,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.items
                .asMap()
                .entries
                .map((entry) => Container(
              width: 8.0,
              height: 8.0,
              margin:
              EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness ==
                      Brightness.dark
                      ? Colors.white
                      : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4)),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
