import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:pharmacy_app/views/homepage.dart';
import 'package:pharmacy_app/views/loginPage.dart';

class Splash1 extends StatefulWidget {
  const Splash1({super.key});

  @override
  State<Splash1> createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Slide from left to right
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start far to the left
      end: Offset.zero,             // End at the original position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fade in animation
    _opacityAnimation = Tween<double>(
      begin: 0.0, // Fully transparent
      end: 1.0,   // Fully visible
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start the animations
    _controller.forward();
       // Navigate to the next screen after a delay
       Future.delayed(const Duration(seconds: 3), () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
       });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset('assets/lottie/greenmed.json'),
            ),
          ),
          const SizedBox(height: 20),

          // Animated text with slide and fade effect
          SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'Pharma',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
