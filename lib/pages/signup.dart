import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/user%20data%20model.dart';
import 'package:untitled2/profile/profile_setup.dart';

import '../Widgets/toast.dart';
import 'lo0ginpage.dart';


class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController newemail = TextEditingController();
  TextEditingController confirmpass = TextEditingController();
  TextEditingController newpassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool loading = false;

  void cheakValue() {
    String email = newemail.text.trim();
    String password = newpassword.text.trim();
    String cpassword = confirmpass.text.trim();
    if (email == "" || password == "" || cpassword == "") {
      toast().toastmsg("please fill all fields");
    } else if (password != cpassword) {
      toast().toastmsg("Password do not Match");
    } else {
      Signup(email, password);
    }
  }

  void Signup(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          loading = true;
        });

        UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: newemail.text.toString(),
          password: newpassword.text.toString(),
        );

        UserModel newUser = UserModel(
          email: email,
          uid: _auth.currentUser!.uid,
          fullname: "",
          profilepicture: "",
        );
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .set(newUser.toMap());

        // Registration successful, you can use userCredential.user here if needed.

        toast().toastmsg("Registration successful");

        setState(() {
          loading = false;

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProfileSetup(
                    userModel: newUser, firebaseUser: userCredential.user,
            ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);

                var fadeAnimation = animation.drive(tween);

                return FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                );
              },
            ),
          );
        });
      } on FirebaseException catch (error) {
        toast().toastmsg(error.message.toString());
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/newlogo.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 200, right: 50),
              child: RichText(
                textAlign: TextAlign.start,
                text: const TextSpan(children: [
                  TextSpan(
                    text: "Register ",
                    style: TextStyle(
                      decorationColor: Colors.black,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.black,
                      fontFamily: 'mohit',
                    ),
                  ),
                  TextSpan(
                    text: "User",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.normal,
                      fontSize: 28,
                      color: Colors.red,
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Center(
                  child: loading
                      ? CircularProgressIndicator(
                    backgroundColor: Colors.orange,
                    color: Colors.white,
                  )
                      : Text(''),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Container(
                width: 320,
                height: 180,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: TextFormField(
                          validator: (value) {
                            return value!.isEmpty
                                ? "Email cannot be empty"
                                : null;
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: buildInputDecoration(
                              "Enter Your Email", Icons.email),
                          keyboardType: TextInputType.text,
                          controller: newemail,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        child: TextFormField(
                          validator: (value) {
                            return value!.isEmpty
                                ? "Password cannot be empty"
                                : null;
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: buildInputDecoration(
                              "Enter Your Password", Icons.lock),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          controller: newpassword,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 50,
                        child: TextFormField(
                          validator: (value) {
                            return value!.isEmpty
                                ? "password cannot be empty"
                                : null;
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: buildInputDecoration(
                              "confirm password ", Icons.email),
                          keyboardType: TextInputType.text,
                          controller: confirmpass,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton(
                    "Sign Up",
                        () {
                      cheakValue();
                    },
                  ),
                  SizedBox(
                    width: 27,
                  ),
                  Row(children: [
                    Text(
                      'Already Registerd ... ',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                secondaryAnimation) =>
                            const LoginPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = 0.0;
                              const end = 1.0;
                              var tween = Tween(begin: begin, end: end);

                              var fadeAnimation =
                              animation.drive(tween);

                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 15),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(String hintText, IconData iconData) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: Icon(
        iconData,
        color: Colors.black,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2),
      ),
    );
  }

  Widget buildButton(String text, onPressed) {
    return Container(
      height: 25,
      width: 99,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 98,
          height: 25,
          color: Colors.white,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
