import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reading_comprehension/widgets/background.dart';
import 'package:reading_comprehension/student/student_login.dart'; // Import the StudentLogin page
import 'package:flutter/services.dart'; // Import for TextInputFormatter

class SignUpStudent extends StatefulWidget {
  const SignUpStudent({super.key});

  @override
  State<SignUpStudent> createState() => _SignUpStudentState();
}

class _SignUpStudentState extends State<SignUpStudent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _teacherCodeController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  String? _selectedTeacherId;
  String? _selectedGradeLevel;
  String? _selectedGender;
  bool _isButtonDisabled = true;
  String? _errorMessage;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _addListeners();

    // Capitalize first letter in first and last names
    _firstNameController.addListener(() {
      String text = _firstNameController.text;
      if (text.isNotEmpty && text[0] != text[0].toUpperCase()) {
        _firstNameController.value = _firstNameController.value.copyWith(
          text: text[0].toUpperCase() + text.substring(1),
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    _lastNameController.addListener(() {
      String text = _lastNameController.text;
      if (text.isNotEmpty && text[0] != text[0].toUpperCase()) {
        _lastNameController.value = _lastNameController.value.copyWith(
          text: text[0].toUpperCase() + text.substring(1),
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _teacherCodeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _addListeners() {
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
    _confirmPasswordController.addListener(_validateInputs);
    _firstNameController.addListener(_validateInputs);
    _lastNameController.addListener(_validateInputs);
    _teacherCodeController.addListener(_validateInputs);
    _scoreController.addListener(_validateInputs);
  }

  Future<void> signUp() async {
  setState(() {
    _loading = true;
  });

  try {
    // Validate teacher code before creating the user
    final teacherDoc = await FirebaseFirestore.instance
        .collection('Teachers')
        .doc(_selectedTeacherId)
        .get();

    if (teacherDoc.exists && teacherDoc['teacherCode'] == _teacherCodeController.text) {
      // Proceed with user creation only if the teacher code is valid
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Register the student in Firestore
      await FirebaseFirestore.instance.collection('Students').doc(userCredential.user!.uid).set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'gradeLevel': _selectedGradeLevel,
        'gender': _selectedGender,
        'score': _scoreController.text,
        'teacherId': _selectedTeacherId,
      });

      // Automatically assign an assessment (Story and Quiz) based on screening score
      int screeningScore = int.tryParse(_scoreController.text) ?? 0;
      int gradeLevel = int.tryParse(_selectedGradeLevel ?? "0") ?? 0;

      if (gradeLevel > 0) {
        String assignedGradeLevel;

        if (screeningScore >= 0 && screeningScore <= 7) {
          assignedGradeLevel = (gradeLevel - 3).toString(); // 3 levels lower
        } else if (screeningScore >= 8 && screeningScore <= 13) {
          assignedGradeLevel = (gradeLevel - 2).toString(); // 2 levels lower
        } else {
          assignedGradeLevel = '';
        }

        if (assignedGradeLevel.isNotEmpty) {
          // Fetch the corresponding story and quiz from Firestore
          QuerySnapshot storySnapshot = await FirebaseFirestore.instance
              .collection('Stories')
              .where('gradeLevel', isEqualTo: assignedGradeLevel)
              .get(); // Removed limit(1) to fetch all stories

          QuerySnapshot quizSnapshot = await FirebaseFirestore.instance
              .collection('Quizzes')
              .where('gradeLevel', isEqualTo: assignedGradeLevel)
              .get(); // Removed limit(1) to fetch all quizzes

          // Check if there are any stories and quizzes available
          if (storySnapshot.docs.isNotEmpty && quizSnapshot.docs.isNotEmpty) {
            // Randomly select a story and quiz or loop back to assign if all are used
            int storyIndex = userCredential.user!.uid.hashCode % storySnapshot.docs.length;
            int quizIndex = userCredential.user!.uid.hashCode % quizSnapshot.docs.length;

            DocumentSnapshot assignedStory = storySnapshot.docs[storyIndex];
            DocumentSnapshot assignedQuiz = quizSnapshot.docs[quizIndex];

            // Assign both story and quiz to the student
            await FirebaseFirestore.instance
                .collection('Students')
                .doc(userCredential.user!.uid)
                .collection('AssignedAssessments')
                .add({
              'storyId': assignedStory.id,
              'storyTitle': assignedStory['title'],
              'quizId': assignedQuiz.id,
              'quizTitle': assignedQuiz['title'],
              'assignedGradeLevel': assignedGradeLevel,
              'assignedAt': Timestamp.now(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully registered and assigned assessment!')),
            );
          } else {
            // If no stories or quizzes available, reassign previous stories and quizzes
            QuerySnapshot allStories = await FirebaseFirestore.instance.collection('Stories').get();
            QuerySnapshot allQuizzes = await FirebaseFirestore.instance.collection('Quizzes').get();

            if (allStories.docs.isNotEmpty && allQuizzes.docs.isNotEmpty) {
              int storyIndex = userCredential.user!.uid.hashCode % allStories.docs.length;
              int quizIndex = userCredential.user!.uid.hashCode % allQuizzes.docs.length;

              DocumentSnapshot assignedStory = allStories.docs[storyIndex];
              DocumentSnapshot assignedQuiz = allQuizzes.docs[quizIndex];

              // Assign the reused story and quiz to the student
              await FirebaseFirestore.instance
                  .collection('Students')
                  .doc(userCredential.user!.uid)
                  .collection('AssignedAssessments')
                  .add({
                'storyId': assignedStory.id,
                'storyTitle': assignedStory['title'],
                'quizId': assignedQuiz.id,
                'quizTitle': assignedQuiz['title'],
                'assignedGradeLevel': assignedGradeLevel,
                'assignedAt': Timestamp.now(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Successfully registered and assigned reused assessment!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No suitable story or quiz found for this grade level.')),
              );
            }
          }
        }
      }

      // Show success message and redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully registered! Redirecting to login...')),
      );

      await Future.delayed(const Duration(seconds: 2));

      // Redirect to StudentLogin page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LogInStudent()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid teacher code. Please check and try again.';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Registration failed: ${e.toString()}';
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}



  void _validateInputs() {
    setState(() {
      bool isFieldsNotEmpty = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _teacherCodeController.text.isNotEmpty &&
          _selectedTeacherId != null &&
          _selectedGradeLevel != null &&
          _selectedGender != null &&
          _scoreController.text.isNotEmpty;

      bool isTeacherCodeValid = _teacherCodeController.text.length == 6;
      bool arePasswordsMatching = _passwordController.text == _confirmPasswordController.text;

      if (isFieldsNotEmpty && isTeacherCodeValid && arePasswordsMatching) {
        _isButtonDisabled = false;
        _errorMessage = null;
      } else {
        _isButtonDisabled = true;
        if (!isTeacherCodeValid) {
          _errorMessage = 'Teacher code must be exactly 6 characters long.';
        } else if (!arePasswordsMatching) {
          _errorMessage = 'Passwords do not match.';
        } else {
          _errorMessage = 'Please fill in all fields correctly.';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Background(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                hint: const Text("Select Gender"),
                items: <String>['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                    _validateInputs();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Teachers').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var teachers = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    hint: const Text("Select Teacher"),
                    items: teachers.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text('${doc['firstname']} ${doc['lastname']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTeacherId = value;
                        _validateInputs();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _teacherCodeController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(6),
                  UpperCaseTextFormatter(), // Custom TextInputFormatter to automatically convert to uppercase
                ],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.code),
                  labelText: "Teacher Code",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _validateInputs(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                hint: const Text("Select Grade Level"),
                items: <String>['5', '6'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Grade $value'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGradeLevel = value;
                    _validateInputs();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _scoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school),
                  labelText: "Screening Score",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _validateInputs(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: (_) => _validateInputs(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                onChanged: (_) => _validateInputs(),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              if (_loading)
                const CircularProgressIndicator(
                  color: Colors.green,
                ),
              if (!_loading)
                ElevatedButton(
                  onPressed: _isButtonDisabled ? null : signUp,
                  child: const Text("Sign Up"),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom UpperCase TextInputFormatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
