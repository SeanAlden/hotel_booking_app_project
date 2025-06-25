import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _FaqItem(
              question: 'How do I book a hotel?',
              answer:
                  'You can book a hotel by Browse through the available hotels, selecting your desired dates, and following the on-screen prompts to complete the reservation process. You\'ll need to provide your personal details and payment information.',
            ),
            _FaqItem(
              question: 'Can I modify or cancel my reservation?',
              answer:
                  'Yes, you can usually modify or cancel your reservation through the "My Bookings" section of your profile. Please note that cancellation policies and modification options vary by hotel and booking type, and some may incur fees.',
            ),
            _FaqItem(
              question: 'What payment methods are accepted?',
              answer:
                  'We typically accept major credit cards (Visa, MasterCard, American Express) and sometimes other payment options like PayPal or local payment gateways. The exact methods available will be displayed during the checkout process.',
            ),
            _FaqItem(
              question: 'How do I know my booking is confirmed?',
              answer:
                  'After a successful booking, you will receive a confirmation email with all the details of your reservation, including a booking reference number. You can also view your confirmed bookings in the "My Bookings" section of the app.',
            ),
            _FaqItem(
              question: 'Is it safe to pay online?',
              answer:
                  'Yes, we prioritize your security. Our payment gateway uses industry-standard encryption and security protocols to protect your personal and financial information. Look for the "https://" in the URL and a padlock icon for secure connections.',
            ),
            _FaqItem(
              question: 'What if I encounter an issue during my stay?',
              answer:
                  'If you have any issues during your stay, please contact the hotel directly first. If the issue persists or you need further assistance, you can contact our customer support team through the app or the provided contact details.',
            ),
            SizedBox(height: 20),
            Text(
              'Account & Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _FaqItem(
              question: 'How do I update my profile information?',
              answer:
                  'You can update your profile information, such as your name, email, and address, in the "Edit Profile" section under "Settings" in your profile page.',
            ),
            _FaqItem(
              question: 'How can I change my password?',
              answer:
                  'To change your password, go to the "Change Password" section under "Settings" in your profile page and follow the instructions.',
            ),
            _FaqItem(
              question: 'What if I forget my password?',
              answer:
                  'If you forget your password, you can use the "Forgot Password" option on the login screen to reset it. A password reset link will be sent to your registered email address.',
            ),
            _FaqItem(
              question: 'Can I upload a profile picture?',
              answer:
                  'Yes, you can tap on the circular image placeholder on your profile page to select and upload a profile picture from your gallery.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}