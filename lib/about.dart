import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true, // This centers the "About Us" in the AppBar
      ),
      body: Stack(
        children: [
          // Background color or gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade200,
                    Colors.deepPurple.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Main content wrapped in a SingleChildScrollView to allow scrolling
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image and Name Row
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.3, // 30% of screen width
                    height:
                        120, // Increase height to make room for text below the image
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Make the container circular
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/logorestore.png', // Replace with your image path
                            fit: BoxFit.cover,
                            height: 68, // Set image height to match container
                            width: 68, // Ensure the image is square
                          ),
                        ),
                        const SizedBox(
                            height: 8), // Space between image and text
                        const Text(
                          'Restore', // Replace with the name you want to show
                          style: TextStyle(
                            fontSize:
                                24, // Reduced text size to prevent overflow
                            color: Colors.white, // White text color
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                    height: 30), // Space after the image and name box

                // Text content (description, team details, etc.)
                const Text(
                  'We are a passionate and dedicated team working hard to provide excellent services for our users. '
                  'Our goal is to continuously improve the experience of our users and make their journey with us as smooth and enriching as possible. '
                  'We focus on building innovative solutions that meet the needs of our users and help them achieve their goals. Our team members come from diverse backgrounds, '
                  'but we share a common mission: to create an impactful and user-friendly product that users can rely on and enjoy.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify, // Justify the text
                ),
                const SizedBox(height: 30), // Space after the description

                const Text(
                  'Meet the Team:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '• Team Leader: Krishna Sapkota\n\n'
                  '• Team Members: Kabir Thapa, Rajdev Sah, Keshav Sah\n\n',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.justify, // Justify the text
                ),
                const SizedBox(height: 30), // Space after the team section

                const Text(
                  'We are a group of IT Engineering students from NCIT College, working together on this project. '
                  'Through this collaboration, we aim to apply our academic knowledge to create a product that can solve real-world challenges. '
                  'Our journey as a team has been an exciting one, and we are committed to improving our skills and delivering the best possible outcome for our users.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.justify, // Justify the text
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
