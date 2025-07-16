import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final pages = [
    OnboardPage(
      image: Icons.cake,
      title: "Welcome to Celebray 🎉",
      desc: "Never miss a birthday or anniversary again.",
    ),
    OnboardPage(
      image: Icons.auto_awesome,
      title: "Smart Messages 🤖",
      desc: "Generate beautiful, personalized greetings with AI.",
    ),
    OnboardPage(
      image: Icons.notifications_active,
      title: "Timely Reminders ⏰",
      desc: "Get notified ahead of special days.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (_, index) => pages[index],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentIndex == pages.length - 1
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 32.0,
                ), // Add padding to move the button up
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: Text("Get Started"),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(pages.length - 1),
                    child: Text("Skip"),
                  ),
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == i ? Colors.pink : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final IconData image;
  final String title;
  final String desc;

  const OnboardPage({
    required this.image,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(image, size: 100, color: Colors.pink),
            SizedBox(height: 40),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
