import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_sign_up.dart';
import 'student_home_page.dart';
import 'package:reading_comprehension/widgets/background.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class LogInStudent extends StatefulWidget {
  const LogInStudent({super.key});

  @override
  State<LogInStudent> createState() => _LogInStudentState();
}

class _LogInStudentState extends State<LogInStudent> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _obscureText = true;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _generalErrorMessage;
  bool _loading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _emailErrorMessage = null;
        _passwordErrorMessage = null;
        _generalErrorMessage = null;
        _loading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text,
          password: _pwd.text,
        );

        // Check the Students collection instead of Users collection
        var studentDoc = await FirebaseFirestore.instance.collection('Students').doc(userCredential.user!.uid).get();

        if (studentDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentHomePage(),
            ),
          );
        } else {
          setState(() {
            _generalErrorMessage = 'Not authorized as a student or account not found.';
          });
          await FirebaseAuth.instance.signOut();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _loading = false;

          if (e.code == 'user-not-found') {
            _emailErrorMessage = 'No user found with this email.';
          } else if (e.code == 'wrong-password') {
            _passwordErrorMessage = 'Incorrect password. Please try again.';
          } else if (e.code == 'invalid-email') {
            _emailErrorMessage = 'Invalid email format.';
          } else {
            _generalErrorMessage = 'Login failed. Please check your email and password.';
          }
        });
      } catch (e) {
        setState(() {
          _loading = false;
          _generalErrorMessage = 'Login failed. Please check your email and password.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 50),
                  height: 50,
                  child: const Text(
                    "Welcome Back, Student!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                  validator: (email) => email!.isNotEmpty ? null : 'Please enter your email',
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email Address",
                    hintText: "Please Enter Your Email",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_emailErrorMessage != null) ...[
                  Text(
                    _emailErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 10),
                TextFormField(
                  controller: _pwd,
                  obscureText: _obscureText,
                  validator: (pwd) => pwd!.length >= 6 ? null : 'Password must be at least 6 characters',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    labelText: "Password",
                    hintText: "Please Enter Your Password",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_passwordErrorMessage != null) ...[
                  Text(
                    _passwordErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 10),
                if (_generalErrorMessage != null) ...[
                  Text(
                    _generalErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Handle forgot password
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Form(
                            child: Container(
                              height: 100,
                              alignment: Alignment.center,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(),
                                  ),
                                  prefixIcon: Icon(Icons.email),
                                  hintText: "Enter Your Email",
                                  label: Text("Email"),
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Send!"),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 61, 58, 58),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                if (_loading) ...[
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 20),
                ],
                if (!_loading)
                  SizedBox(
                    height: 55,
                    width: 500,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15A323),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "Log In as Student",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const SignUpStudent();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up Now!",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
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
}
