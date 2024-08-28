  import 'package:flutter/material.dart';
  import 'package:reading_comprehension/student/student_sign_up.dart';
  import 'package:reading_comprehension/teacher/teacher_sign_up.dart';
  import 'package:reading_comprehension/widgets/background.dart';

  class SignUp extends StatefulWidget {
    const SignUp({super.key});

    @override
    State<SignUp> createState() => _SignUpState();
  }

  class _SignUpState extends State<SignUp> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Background(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 1.0),
              const Text(
                "Welcome Onboard!",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Teacher.png"),
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: const BoxDecoration(
                      color: Color(0xFF15A323),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpTeacher()),
                        );
                      },
                      child: const Text(
                        "Sign Up as a Teacher",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Align(
               alignment: Alignment.centerRight, // Move "OR" to the right
               child: Padding(
               padding: EdgeInsets.only(right:145.0), // Optional: Add some padding for spacing
               child: Text(
                          "OR",
               style: TextStyle(
               fontSize: 30,
               fontWeight: FontWeight.bold,
              ),
           ),
         ),
       ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Image.asset(
                      "assets/images/Person.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: const BoxDecoration(
                      color: Color(0xFF15A323),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpStudent()),
                        );
                      },
                      child: const Text(
                        "Sign Up as a Student",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sign In!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
