import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final String aboutApp =
      'CISC Mobile Reading Comprehension is a student-centered digital learning platform designed to strengthen reading skills among Grade 5 and Grade 6 learners. '
      'Built upon the Philippine Informal Reading Inventory (Phil-IRI) framework, the app allows teachers to assess students through pretests and posttests activities.\n\n'
      'With intuitive tools to manage passages, assign quizzes, and monitor progress, the app fosters both silent and oral reading development in a structured yet engaging way.';

  final String collaborationDetails =
      'This project would not have been possible without the invaluable guidance, dedication, and support of our beloved adviser, Professor Gladys S. Ayunar. Her encouragement, wisdom, and unwavering belief in this initiative inspired us to persevere and continually strive for excellence. Her leadership was truly the heart of this achievement.\n\n'
      'We are also deeply grateful to our esteemed professors—Kent Levi Bonifacio, Nathalie Joy G. Casildo, and Jinky G. Marcelo—for their expert guidance, thoughtful feedback, and continued encouragement throughout this journey.\n\n'
      'Our sincere appreciation goes to Leah Culaste Angana, Ph.D., for her vital expertise in the Philippine Informal Reading Inventory (Phil-IRI), which helped shape the app\'s development. We also thank Weenkie Jhon A. Marcelo, Ph.D., School Principal of Musuan Integrated School, for his generous support and encouragement.';

  final String counterparts =
      'The CISC Mobile Reading Comprehension app is part of the CISC KIDS series, which includes these complementary educational apps:';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15A323),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            fontFamily: 'LexendDeca', 
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoHeader(),
              const SizedBox(height: 25),
              _sectionTitle('About the App'),
              _sectionCard(aboutApp),
              const SizedBox(height: 28),
              _sectionTitle('Acknowledgments & Collaboration'),
              _sectionCard(collaborationDetails),
              const SizedBox(height: 28),
              _sectionTitle('Development Team'),
              _developerSection(context),
              const SizedBox(height: 28),
              _sectionTitle('Counterpart Apps in the Series'),
              _sectionCard(counterparts),
              const SizedBox(height: 12),
              _counterpartAppList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9FBEF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  height: 130,
                  width: 130,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9FBEF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 60,
                        color: Color(0xFF15A323),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'CISC Mobile Reading\nComprehension',
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF15A323),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            'Empowering Young Readers',
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'LexendDeca',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF15A323),
        ),
      ),
    );
  }

  Widget _sectionCard(String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontFamily: 'LexendDeca',
          fontSize: 16,
          color: Colors.black87,
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _developerSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          if (isSmallScreen) 
            Column(
              children: const [
                DeveloperCard(
                  imagePath: 'assets/images/developer1.png',
                  name: 'Dan Ephraim R. Macabenlar',
                  role: 'Developer/Researcher',
                  isPrimary: true,
                ),
                SizedBox(height: 20),
                DeveloperCard(
                  imagePath: 'assets/images/developer2.png',
                  name: 'Angelou C. Lapad',
                  role: 'Researcher',
                  isPrimary: false,
                ),
              ],
            )
          else
            const Row(
              children: [
                Expanded(
                  child: DeveloperCard(
                    imagePath: 'assets/images/developer1.png',
                    name: 'Dan Ephraim R. Macabenlar',
                    role: 'Developer/Research',
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DeveloperCard(
                    imagePath: 'assets/images/developer2.png',
                    name: 'Angelou C. Lapad',
                    role: 'Researcher',
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Both team members contributed significantly to the research, design, '
              'and development of this educational platform, working collaboratively '
              'to create an effective tool for reading comprehension assessment.',
              style: TextStyle(
                fontFamily: 'LexendDeca',
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterpartAppList() {
    final apps = [
      {
        'image': 'assets/images/applogo1.png',
        'title': 'CISC KIDS: Beginning Reading English Fuller',
        'desc': 'Integrates phonics, vocabulary building, and alphabet mastery for foundational English reading skills.',
      },
      {
        'image': 'assets/images/applogo2.png',
        'title': 'CISC KIDS: Marungko Approach Simula sa Pagbasa',
        'desc': 'Emphasizes sound recognition through the Marungko method for early Filipino reading development.',
      },
    ];

    return Column(
      children: apps.map((app) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scaled up logo container
              Container(
                width: 90, // Increased from 70
                height: 90, // Increased from 70
                padding: const EdgeInsets.all(12), // Increased padding
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  app['image'] as String,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.apps,
                        size: 40, // Increased from 30
                        color: Color(0xFF15A323),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20), // Increased spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['title'] as String,
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontSize: 17, // Slightly larger
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8), // Increased spacing
                    Text(
                      app['desc'] as String,
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontSize: 14.5, // Slightly larger
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DeveloperCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String role;
  final bool isPrimary;

  const DeveloperCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.role,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    // Define color schemes for primary (green) and secondary (yellow)
    final primaryGradient = [const Color(0xFF15A323), const Color(0xFF0D8A1A)];
    final secondaryGradient = [const Color(0xFFFFC107), const Color(0xFFFFA000)];
    
    final primaryTextColor = const Color(0xFF15A323);
    final secondaryTextColor = const Color(0xFFF57F17);
    
    final primaryLightColor = const Color(0xFFE9FBEF);
    final secondaryLightColor = const Color(0xFFFFF8E1);
    
    final primaryBadgeText = const Color(0xFF15A323);
    final secondaryBadgeText = const Color(0xFFF57F17);
    
    final primaryRoleColor = const Color(0xFF0D8A1A);
    final secondaryRoleColor = const Color(0xFFF57F17);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isPrimary 
              ? const Color(0xFF15A323).withOpacity(0.3)
              : const Color(0xFFFFC107).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isPrimary
                        ? primaryGradient
                        : secondaryGradient,
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[500],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isPrimary ? primaryTextColor : secondaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            role,
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 14,
              color: isPrimary ? primaryRoleColor : secondaryRoleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isPrimary 
                  ? primaryLightColor
                  : secondaryLightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPrimary ? 'Lead Developer' : 'Research Specialist',
              style: TextStyle(
                fontFamily: 'LexendDeca',
                fontSize: 12,
                color: isPrimary ? primaryBadgeText : secondaryBadgeText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}