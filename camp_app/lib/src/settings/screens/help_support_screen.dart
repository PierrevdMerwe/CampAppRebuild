// lib/src/settings/screens/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../home/widgets/social_footer.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // Track which questions are expanded
  final List<bool> _expandedList = List.generate(5, (_) => false);

  // FAQs data
  final List<Map<String, dynamic>> _faqs = [
    {
      'icon': FontAwesomeIcons.circleUser,
      'question': 'How do I create an account?',
      'answer': 'Creating an account is easy! Simply tap the "Sign me up" button on the welcome screen and follow the instructions. You\'ll need to provide an email address, create a password, and fill in some basic information.'
    },
    {
      'icon': FontAwesomeIcons.campground,
      'question': 'How do I find campsites near me?',
      'answer': 'You can find campsites near your location by allowing location permissions and using the search feature. Alternatively, you can browse campsites by province or filter by various amenities and features like "Pet Friendly" or "Braai Place".'
    },
    {
      'icon': FontAwesomeIcons.creditCard,
      'question': 'How do payments work on Campp?',
      'answer': 'We offer secure payment options for booking campsites. Currently, our payment system is under development and will be available soon. In the meantime, campsite bookings are handled directly with the campsite owners.'
    },
    {
      'icon': FontAwesomeIcons.tent,
      'question': 'I own a campsite. How can I list it on Campp?',
      'answer': 'As a campsite owner, you can create a "Site Owner" account by selecting the appropriate option during registration. Your listing will need to be verified by our team before it becomes visible to users. For more assistance, please contact our support team.'
    },
    {
      'icon': FontAwesomeIcons.mobileScreenButton,
      'question': 'Which devices is Campp available on?',
      'answer': 'The Campp App is currently available for both Android and iOS devices. We\'re continually working to improve our app and expand our platform availability. Stay tuned for updates!'
    },
  ];

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support.thecampp@gmail.com',
      query: 'subject=Campp Support Inquiry',
    );
    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Subtitle with chat link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'These are the most commonly asked questions about The Campp App.\n'),
                        const TextSpan(text: 'Can\'t find what you\'re looking for? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _launchEmail,
                            child: Text(
                              'Chat to our friendly team!',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: const Color(0xff2e6f40),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // FAQ Accordions
                ...List.generate(_faqs.length, (index) => _buildFaqItem(index)),
              ],
            ),
          ),
          const SocialFooter(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    // Using the light gray background color consistent with the app
    const backgroundColor = Color(0xffF5F8F5);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _expandedList[index],
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedList[index] = expanded;
            });
          },
          leading: FaIcon(
            _faqs[index]['icon'],
            color: const Color(0xff2e6f40),
            size: 20,
          ),
          title: Text(
            _faqs[index]['question'],
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              child: Text(
                _faqs[index]['answer'],
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}