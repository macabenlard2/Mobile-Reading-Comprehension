import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final String aboutApp =
      'CISC Mobile Reading Comprehension is a student-centered digital learning platform designed to strengthen reading skills among Grade 5 and Grade 6 learners. '
      'Built upon the Philippine Informal Reading Inventory (Phil-IRI) framework, the app allows teachers to assess students through pretests and posttests activities.\n\n'
      'With intuitive tools to manage passages, assign quizzes, and monitor progress, the app fosters both silent and oral reading development in a structured yet engaging way.';

  final String collaborationDetails =
       'Our excellent professors, Kent Levi Bonifacio,  Gladys S. Ayunar, Nathalie Joy G. Casildo and Jinky G. Marcelo, led this collaborative endeavor. Their knowledge and input were crucial throughout the projects development.\n\n'
      'We especially thank Leah Culaste Angana, Ph.D., for her invaluable expertise in the Philippine Informal Reading Inventory (Phil-IRI), which significantly guided the development of this app.\n\n'
      'We also extend our gratitude to Weenkie Jhon A. Marcelo Ph.D, School Principal of Musuan Integrated School, for his continued support and encouragement throughout the development of this app.';


  final String counterparts =
      'The CISC Mobile Reading Comprehension is part of the CISC KIDS series, which includes the following complementary educational apps:\n';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF15A323),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(fontFamily: 'LexendDeca', color: Colors.white ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CISC Mobile Reading Comprehension',
                        style: TextStyle(
                          fontFamily: 'LexendDeca',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'About the App',
                  style: TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  aboutApp,
                  style: const TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Collaboration',
                  style: TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  collaborationDetails,
                  style: const TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Developers',
                  style: TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/developer1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Dan Ephraim R. Macabenlar\n Developer',
                            style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/developer2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Angelou C. Lapad\n Developer',
                            style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Counterpart Apps in the Series',
                  style: TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  counterparts,
                  style: const TextStyle(
                    fontFamily: 'LexendDeca',
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    _buildCounterpartItem(
                      'assets/images/applogo1.2.png',
                      '1. CISC KIDS: Beginning Reading English Fuller – integrates phonics, vocabulary building, and alphabet mastery.',
                    ),
                    const SizedBox(height: 10),
                    _buildCounterpartItem(
                      'assets/images/applogo1.2.png',
                      '2. CISC KIDS: Marungko Approach Simula sa Pagbasa – emphasizes sound recognition through the Marungko method.',
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterpartItem(String imagePath, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(imagePath, height: 70, width: 70),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}