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
  double minOpacity = 0.7;
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
        }));

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    animationController.addListener(() => setState(() {
          opacities[0] = (1 - animationController.value);
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

  var opacities = [0.7, 0.7, 0.7];
  var frontOpacity = 0.0;
  var everest = Mountain(
    scale: 3.0,
    translateX: -40.0,
    translateY: -30.0,
    name: 'everest.png',
    color: Colors.cyan.withOpacity(0.9),
  );

  var k2 = Mountain(
    scale: 2.0,
    translateX: -40.0,
    translateY: -50.0,
    name: 'k2.png',
    color: Colors.indigo.withOpacity(0.9),
  );

  var fuji = Mountain(
    scale: 2.5,
    translateX: -50.0,
    translateY: -50.0,
    name: 'fuji.png',
    color: Colors.yellow.withOpacity(0.9),
  );

  int index = 0;
  @override
  Widget build(BuildContext context) {
    var mountains = [everest, k2, fuji];
    double maxSlide = -200;
    double maxScale = 0.5;
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
                  Opacity(
                    opacity: 1,
                    child: Container(
                        color: mountains[(2 + index) % 3]
                            .color
                            .withOpacity(minOpacity),
                        child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(
                                  slideX - reverseSlideX + -2 * maxSlide, 0)
                              ..scale(1.0),
                            child: mountains[(2 + index) % 3])),
                  ),
                  Opacity(
                    opacity: 1,
                    child: Container(
                        color: mountains[(1 + index) % 3]
                            .color
                            .withOpacity(opacities[1]),
                        child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(slideX - reverseSlideX - maxSlide, 0)
                              ..scale(1.0),
                            child: mountains[(1 + index) % 3])),
                  ),
                  Opacity(
                    opacity: opacities[0],
                    child: Container(
                      color: mountains[index % 3]
                          .color
                          .withOpacity(opacities[0] * minOpacity),
                      child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translate(slideX - reverseSlideX, 0)
                            ..scale(scale),
                          child: mountains[index % 3]),
                    ),
                  ),

                  //onebackelement
                  Opacity(
                    opacity: frontOpacity,
                    child: Container(
                      color: mountains[(index - 1) % 3]
                          .color
                          .withOpacity(frontOpacity * minOpacity),
                      child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translate(maxSlide - reverseSlideX, 0)
                            ..scale(reverseScale),
                          child: mountains[(index - 1) % 3]),
                    ),
                  ),
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
        print(
            'object ${details.primaryDelta}  ${animationController.value} ${reverseController.value}');
        reverseController.value += details.primaryDelta! / 250;
      }
      if ((reverseController.value == 0.0 && animationController.value > 0.0) ||
          (animationController.value == 0.0 &&
              reverseController.value == 0.0 &&
              details.primaryDelta! < 0.0)) {
        print('siema ${details.primaryDelta}');
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
    if (animationController.value > 0.5 && animationController.value > 0.0)
      animationController.forward();
    else
      animationController.reverse();
    if (reverseController.value > 0.5 && reverseController.value > 0.0)
      reverseController.forward();
    else
      reverseController.reverse();
  }
}

class Mountain extends StatelessWidget {
  final double scale;
  final double translateX;
  final double translateY;
  final String name;
  final Color color;
  const Mountain(
      {Key? key,
      required this.scale,
      required this.translateX,
      required this.translateY,
      required this.name,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale)
              ..translate(translateX, translateY),
            child: Image(image: AssetImage(name))),
      ],
    );
  }
}
