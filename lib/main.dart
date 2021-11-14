import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI challenge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController reverseController;
  double minOpacity = 0.9;
  double slideXInformation = 1;
  @override
  void initState() {
    super.initState();

    reverseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    reverseController.addListener(() => setState(() {
          frontOpacity = (reverseController.value);
          if (reverseController.isCompleted) {
            index -= 1;
            reverseController.reset();
          }
          actualCardTextOpacities = (1 - frontOpacity) * (1 - frontOpacity);
          slideXInformation = reverseController.value;
        }));

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    animationController.addListener(() => setState(() {
          opacities[0] = (1 - animationController.value);
          actualCardTextOpacities = opacities[0] * opacities[0];
          slideXInformation = animationController.value;
          if (animationController.isCompleted) {
            index += 1;
            animationController.reset();
          }
        }));

    //setState(() {});
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();
  var actualCardTextOpacities = 1.0;
  var opacities = [1.0, 0.9, 0.9];
  var frontOpacity = 0.0;
  var everest = Mountain(
    scale: 3.0,
    translateX: -40.0,
    translateY: 50.0,
    name: 'everest.png',
    color: Colors.cyan.withOpacity(0.9),
    text: 'EVE\nREST',
    coordinate: '27\u210959\'17\'\'N 86\u210955\'31\'\'E',
    elevation: '29,029 ft/Ranked 1st',
  );

  var k2 = Mountain(
    scale: 2.2,
    translateX: -40.0,
    translateY: 70.0,
    name: 'k2.png',
    color: Colors.indigo.withOpacity(0.9),
    text: 'K2',
    coordinate: '35\u210952\'57\'\'N 76\u210930\'48\'\'E',
    elevation: '28,251 ft/Ranked 2nd',
  );

  var fuji = Mountain(
    scale: 2.5,
    translateX: -50.0,
    translateY: 50.0,
    name: 'fuji.png',
    color: Colors.orange.withOpacity(0.9),
    text: 'Mt.\nFUJI',
    coordinate: '35\u210921\'29\'\'N 138\u210943\'52\'\'E',
    elevation: '12,388 ft/Ranked 35th',
  );

  int index = 0;
  @override
  Widget build(BuildContext context) {
    var mountains = [everest, k2, fuji];
    double maxSlide = -200;
    double maxScale = 1.0;
    var slideX = maxSlide * animationController.value;
    var scale = maxScale * animationController.value + 1.0;

    var reverseSlideX = maxSlide * (reverseController.value);
    var reverseScale = 1 + maxScale * (1 - reverseController.value);
    return GestureDetector(
      //onTap: toggle,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return Scaffold(
              body: Stack(
                children: [
                  MountainCard(
                    opacity: 1,
                    backgroundColor: mountains[(2 + index) % 3]
                        .color
                        .withOpacity(minOpacity),
                    slideX: slideX - reverseSlideX + -2 * maxSlide,
                    scale: 1.0,
                    mountain: mountains[(2 + index) % 3],
                    textOpacity: 0.0,
                    text: mountains[(2 + index) % 3].text,
                  ),
                  //next mountain
                  MountainCard(
                    opacity: 1,
                    backgroundColor: mountains[(1 + index) % 3]
                        .color
                        .withOpacity(opacities[1]),
                    slideX: slideX - reverseSlideX - maxSlide,
                    scale: 1.0,
                    mountain: mountains[(1 + index) % 3],
                    textOpacity: animationController.value,
                    text: mountains[(1 + index) % 3].text,
                  ),
                  //actual front page
                  MountainCard(
                    opacity: opacities[0],
                    backgroundColor: mountains[index % 3]
                        .color
                        .withOpacity(opacities[0] * minOpacity),
                    slideX: slideX - reverseSlideX,
                    scale: scale,
                    mountain: mountains[index % 3],
                    textOpacity: 1.0,
                    text: mountains[index % 3].text,
                  ),
                  //onebackelement
                  MountainCard(
                    opacity: frontOpacity,
                    backgroundColor: mountains[(index - 1) % 3]
                        .color
                        .withOpacity(frontOpacity * minOpacity),
                    slideX: maxSlide - reverseSlideX,
                    scale: reverseScale,
                    mountain: mountains[(index - 1) % 3],
                    textOpacity: frontOpacity * minOpacity,
                    text: mountains[(index - 1) % 3].text,
                  ),
                  //right corner texts

                  //actual
                  CoordinateAndElevation(
                    xSlide: ((slideX - reverseSlideX) / 200) * 50,
                    opacity: actualCardTextOpacities,
                    coordinate: mountains[index % 3].coordinate,
                    elevation: mountains[index % 3].elevation,
                  ),
                  //next
                  CoordinateAndElevation(
                    xSlide: ((slideX - reverseSlideX - maxSlide) / 200) * 40,
                    opacity: animationController.value,
                    coordinate: mountains[(1 + index) % 3].coordinate,
                    elevation: mountains[(1 + index) % 3].elevation,
                  ),
                  //previous
                  CoordinateAndElevation(
                    xSlide: ((maxSlide - reverseSlideX) / 200) * 30,
                    opacity: frontOpacity * minOpacity,
                    coordinate: mountains[(index - 1) % 3].coordinate,
                    elevation: mountains[(index - 1) % 3].elevation,
                  ),
                  Transform(
                    transform: Matrix4.identity()
                      ..translate(
                          340.0 +
                              sin(slideXInformation * 2 * pi - 0.5 * pi) * 60,
                          220.0),
                    child: Container(
                      color: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(18.0, 5.0, 60.0, 4.0),
                        child: Text(
                          'INFORMATION >>',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      //print(details.primaryDelta);

      //reverseController.value = 1 - animationController.value;
      if ((animationController.value == 0 && reverseController.value > 0.0) ||
          (animationController.value == 0.0 &&
              reverseController.value == 0.0 &&
              details.primaryDelta! > 0.0)) {
        reverseController.value += details.primaryDelta! / 250;
      }
      if ((reverseController.value == 0.0 && animationController.value > 0.0) ||
          (animationController.value == 0.0 &&
              reverseController.value == 0.0 &&
              details.primaryDelta! < 0.0)) {
        animationController.value -= details.primaryDelta! / 250;
      }
    }
  }

  double controlOpacity(double opacity) {
    if (opacity < 0.0)
      return 0.0;
    else if (opacity > 1.0) return 1.0;
    return opacity;
  }

  void _handleDragEnd(DragEndDetails details) {
//    if (animationController.isAnimating ||
    //      animationController.status == AnimationStatus.completed) return;
    if (animationController.value > 0.3 && animationController.value > 0.0)
      animationController.forward();
    else
      animationController.reverse();
    if (reverseController.value > 0.3 && reverseController.value > 0.0)
      reverseController.forward();
    else
      reverseController.reverse();
  }
}

class CoordinateAndElevation extends StatelessWidget {
  final String coordinate;
  final String elevation;
  final double opacity;
  final double xSlide;
  const CoordinateAndElevation({
    Key? key,
    required this.coordinate,
    required this.elevation,
    required this.opacity,
    required this.xSlide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: Alignment.topRight,
        transform: Matrix4.identity()..translate(250.0 + xSlide, 130.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elevation',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              elevation,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coordinates',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              coordinate,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class Mountain extends StatelessWidget {
  final double scale;
  final double translateX;
  final double translateY;
  final String name;
  final Color color;
  final String text;
  final String coordinate;
  final String elevation;
  const Mountain(
      {Key? key,
      required this.scale,
      required this.translateX,
      required this.translateY,
      required this.name,
      required this.color,
      required this.text,
      required this.coordinate,
      required this.elevation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(scale)
          ..translate(translateX, translateY),
        child: Image(image: AssetImage(name)));
  }
}

class MountainCard extends StatelessWidget {
  final double opacity;
  final Color backgroundColor;
  final double slideX;
  final double scale;
  final Mountain mountain;
  final double textOpacity;
  final String text;
  const MountainCard(
      {Key? key,
      required this.opacity,
      required this.backgroundColor,
      required this.slideX,
      required this.scale,
      required this.mountain,
      required this.textOpacity,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(slideX, 0)
                ..scale(scale),
              child: Center(child: mountain),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(20.0 + slideX / 2, 60.0)
                ..scale(scale),
              child: Opacity(
                opacity: textOpacity,
                child: Text(
                  text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 50.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
