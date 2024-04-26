// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

@pragma("vm:entry-point")
void showOverlay() {
  BuildContext? context;
  OverlayEntry _overlayEntry = OverlayEntry(builder: (context) {
    context = context;
    Overlay.of(context).initState();
    return Material(child: PopupWidgetGlass());
  });
  Overlay.of(context!).insert(_overlayEntry);
}

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      //later use obx
      height: controller.screenHeight,
      width: controller.screenWidth,
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                print('hello');
              },
              child: Text('popup or popdown')),

          // Text('User : ${controller.userDialogue.value}',
          //     style: TextStyle(fontSize: 16)),
          // Container(height: 20),
          // Text('Gemini : ${controller.geminiDialogue.value}',
          //     style: TextStyle(fontSize: 16)),
          // Container(height: 20),
          // Text(
          //     'Gemini response generated: ${controller.responseGenerated.value}',
          //     style: TextStyle(fontSize: 16)),
        ],
      ),
    ));
  }
}

class PopupWidgetGlass extends GetWidget<HomeController> {
  const PopupWidgetGlass({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: controller.screenHeight * 0.24,
      width: controller.screenWidth,
      child: Stack(alignment: Alignment.bottomCenter, children: [
        Container(
          padding: const EdgeInsets.all(20),
          height: controller.screenHeight * .18,
          width: controller.screenWidth,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.grey.shade600.withOpacity(0.5),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Text(
                  'Hey there leon.. Busy right now??',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: controller.screenHeight * 0.15,
              left: controller.screenWidth * 0.6),
          width: 130,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "https://s3-alpha-sig.figma.com/img/ef5b/d75b/c60443321f5757f21fc07b5a4c644b42?Expires=1714953600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=UKF57oKUQ3sKzUKwLqeIglrava7mx62qhZzTqMSnQqouG5Ag4d56GpMdfkug4SxYyBEHy6~tV6QqLKXbdIYbHRwmi6Jot41oxjQt8iPTMaQO40Cuzu~DRA1fqNgvj7N4ZcWk6fYVXUavreppAc3zYlxZWjCnfYw6ZcH231U03s98aEokeofXh1lDdMX2t01HRvPDsWljWMz9WPq1lpjKXXX6Q1-5DVusP0KxicWSx008Nl69dXhFmrQ~YlgCp76boO2R8xTexVehj5us~Pz4qmSyk-doozmzTwCP~qOZ~pZiJql3SX2a9mx5d9uFoZPp4BxpK8B244F2lwRfWqA2WA__"),
                  fit: BoxFit.cover)),
        ),
      ]),
    );
  }
}

// class SlideUpOverlay extends StatefulWidget {
//   final Widget child;

//   const SlideUpOverlay({required this.child});

//   @override
//   _SlideUpOverlayState createState() => _SlideUpOverlayState();
// }

// class _SlideUpOverlayState extends State<SlideUpOverlay>
//     with SingleTickerProviderStateMixin {
//   AnimationController? _controller;
//   Animation<Offset>? _animation;
//   OverlayEntry? _overlayEntry;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300), // Adjust animation duration
//     );
//     _animation = Tween<Offset>(
//       begin: Offset(0, 1), // Starts completely hidden (shifted upwards)
//       end: Offset(0, 0), // Slides down to be visible
//     ).animate(_controller!);
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _overlayEntry?.remove(); // Remove the overlay when disposed
//     super.dispose();
//   }

//   void showOverlay() {
//     _overlayEntry = OverlayEntry(
//       builder: (context) => SlideTransition(
//         position: _animation!,
//         child: widget.child,
//       ),
//     );
//     overlay.initState(context); // Initialize the overlay for this context
//     overlay.insert(_overlayEntry!);
//     _controller!.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(); // This widget doesn't build anything visually
//   }
// }

