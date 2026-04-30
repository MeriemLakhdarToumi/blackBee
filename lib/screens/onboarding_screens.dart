import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/onboarding1.png',
      'title': 'Real-Time Threat Monitoring',
      'subtitle': 'Track threats globally with adaptive dashboards',
    },
    {
      'image': 'assets/onboarding2.png',
      'title': 'Smart Threat Identification',
      'subtitle': 'Detect intruders via digital patterns and attack signatures',
    },
    {
      'image': 'assets/onboarding3.png',
      'title': 'Real-time Insights',
      'subtitle':
          'Monitor attacks, visualize behavior, and respond faster than ever.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌑 Dark Overlay (THIS is what you wanted)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.99)),
          ),

          // 📱 Main UI
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xFFE5AC07),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Title & Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              onboardingData[currentPage]['title']!,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE5AC07),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              onboardingData[currentPage]['subtitle']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[300],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Image Slider
                      SizedBox(
                        height: 260,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: onboardingData.length,
                          onPageChanged: (index) {
                            setState(() => currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return Center(
                              child: Image.asset(
                                onboardingData[index]['image']!,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),

                      // Dots Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(onboardingData.length, (index) {
                          bool isActive = index == currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: isActive ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE5AC07)
                                  : Colors.grey[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),

                      // Next Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFE5AC07),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              if (currentPage < onboardingData.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/signup',
                                );
                              }
                            },
                            child: Text(
                              currentPage == onboardingData.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFFE5AC07),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
