import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/pages/Home.dart';
import 'package:untitled2/pages/signup.dart';
import 'package:untitled2/Widgets/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  void login() async {
    try {
      setState(() {
        loading = true;
      });

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text.toString(),
      );


      toast().toastmsg(userCredential.user!.email.toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Home()),
      );
    } on FirebaseException catch (error) {
      toast().toastmsg(error.message.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/newlogo.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 230, right: 50),
              child: RichText(
                textAlign: TextAlign.start,
                text: const TextSpan(children: [
                  TextSpan(
                    text: "Welcome ",
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
                    text: "Back",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.normal,
                      fontSize: 22,
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
                      Container(height:50 ,child: buildTextFormField("Enter Your Email", Icons.email, email, TextInputType.emailAddress, false)),
                      SizedBox(height: 10),
                      Container(height: 50,child: buildTextFormField("Enter Your Password", Icons.lock, password, TextInputType.visiblePassword, true)),
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
                  SizedBox(width: 27),
                  buildButton("Login", () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  }),
                  Text('    New On MeChat.....',style: TextStyle(fontSize: 12),),
              GestureDetector(onTap: () {

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const Signin(),
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


              },child: Text("Register",style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,fontSize: 15),)
              )],
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

  Widget buildButton(String text, VoidCallback onPressed) {
    return Container(
      height: 25,
      width: 70,
      decoration: BoxDecoration(
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

  Widget buildTextFormField(String hintText, IconData iconData, TextEditingController controller, TextInputType inputType, bool obscureText) {
    return TextFormField(
      validator: (value) {
        return value!.isEmpty ? "$hintText cannot be empty" : null;
      },
      style: TextStyle(color: Colors.black),
      decoration: buildInputDecoration(hintText, iconData),
      keyboardType: inputType,
      controller: controller,
      obscureText: obscureText,
    );
  }
}
