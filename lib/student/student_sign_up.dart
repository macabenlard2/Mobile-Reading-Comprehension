import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reading_comprehension/widgets/background.dart';

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
  String? _selectedGender; // Added gender field
  bool _isButtonDisabled = true;
  String? _errorMessage;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _addListeners();
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
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final teacherDoc = await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(_selectedTeacherId)
          .get();

      if (teacherDoc.exists && teacherDoc['teacherCode'] == _teacherCodeController.text) {
        await FirebaseFirestore.instance.collection('Students').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'gradeLevel': _selectedGradeLevel,
          'gender': _selectedGender, // Added gender field to Firestore
          'score': _scoreController.text,
          'teacherId': _selectedTeacherId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Invalid teacher code.';
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
          _selectedGender != null && // Check if gender is selected
          _scoreController.text.isNotEmpty;

      bool isTeacherCodeValid = _teacherCodeController.text.length >= 6;
      bool arePasswordsMatching = _passwordController.text == _confirmPasswordController.text;

      if (isFieldsNotEmpty && isTeacherCodeValid && arePasswordsMatching) {
        _isButtonDisabled = false;
        _errorMessage = null;
      } else {
        _isButtonDisabled = true;
        if (!isTeacherCodeValid) {
          _errorMessage = 'Teacher code must be at least 6 characters long.';
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
                  fontSize: 30,
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
              DropdownButtonFormField<String>(
                hint: const Text("Select Gender"), // Gender dropdown
                items: <String>['Male', 'Female',].map((String value) {
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
                controller: _teacherCodeController,
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
