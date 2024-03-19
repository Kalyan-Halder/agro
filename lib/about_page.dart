import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About US'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Empowering Farmers, Nourishing Communities',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset('assets/images/harvest.png'), // Make sure to add an appropriate image in your assets
              const SizedBox(height: 16),
              const Text(
                'Founded in [2024], Agro-Farm Market System is dedicated to transforming the agricultural supply chain by directly connecting farmers to the market, enhancing transparency, and promoting sustainable farming practices. Our digital platform serves as a bridge between rural farmers and urban consumers, enabling fair trade and supporting local economies.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Key Features:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildFeatureTile('Direct Farmer to Consumer Sales'),
              buildFeatureTile('Verified Agriculture Officer Support'),
              buildFeatureTile('Digital Payment Integration'),
              buildFeatureTile('Real-time Market Prices'),
              buildFeatureTile('Efficient Crop Growing Instructions'),
              const Text(
                'Why Choose Us?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              buildFeatureTile('Direct sales from farm to table ensure freshness and quality.'),
              buildFeatureTile('Real-time market data empowers farmers to get fair prices.'),
              buildFeatureTile('A wide range of organic and sustainable products.'),
              const SizedBox(height: 16),
              const Text(
                'Testimonials',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              buildTestimonial('Md. Jishan Talukdar', 'Thanks to Agro-Farm, my products reach the market faster and at better prices.'),
              buildTestimonial('Shapno', 'We found organic, locally-sourced vegetables for my restaurant. Great quality and service!'),
              const SizedBox(height: 16),
              const Text(
                'Meet Our Team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildTeamMember('assets/avatars/kalyan.jpg', 'Kalyan Kanti Halder', 'Founder & CEO'),
              buildTeamMember('assets/avatars/joy.jpg', 'Joy Debnath', 'CTO'),
              // Add more team members as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeatureTile(String feature) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline, color: Colors.green),
      title: Text(feature, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget buildTestimonial(String name, String testimonial) {
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListTile(
        title: Text(testimonial),
        subtitle: Text('- $name'),
      ),
    );
  }

  Widget buildTeamMember(String imagePath, String name, String role) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath), // Replace with actual image paths
      ),
      title: Text(name),
      subtitle: Text(role),
    );
  }
}
