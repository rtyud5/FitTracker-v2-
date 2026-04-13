import 'dart:async';
import 'package:flutter/material.dart';
import 'enter_name_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _pages = [
    {
      'image': 'Assets/Images/imagePage2_1.jpg',
      'text':
          'When it comes to nutrition,\nfinding what works for you\nmakes all the difference.',
    },
    {
      'image': 'Assets/Images/imagePage2_2.jpg',
      'text': 'You are unique,\nso is our program.',
    },
    {
      'image': 'Assets/Images/imagePage2_3.jpg',
      'text': 'Let\'s start your journey\ntowards better health!',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Auto move page every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final nextPage = (_controller.page ?? 0).round() + 1;

      if (nextPage < _pages.length) {
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EnterNameScreen()),
        );
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EnterNameScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: const Color(0xFFFDF8F1),
                          padding: const EdgeInsets.all(40),
                          child: Image.asset(
                            page['image']!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Text
                      Text(
                        page['text']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D1E20),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Indicator
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),

            // Next Button
            Positioned(
              bottom: 30,
              right: 24,
              child: _currentIndex == _pages.length - 1
                ? GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
