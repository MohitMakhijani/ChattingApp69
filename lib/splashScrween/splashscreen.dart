import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/FireBaseHelper.dart';
import '../pages/Home.dart';
import '../model/user data model.dart';
import '../pages/lo0ginpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  User? CurrentUser=  FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {

    if(CurrentUser!=null){
      UserModel? thisUserModel= await FireBaseHelper.getUserModelId(CurrentUser!.uid);
      if(thisUserModel!=null){ runApp(Loggedin(userModel: thisUserModel, firebaseUser: CurrentUser!));}
      else{
        runApp(NotLoggedin());
      }

    }

    if(CurrentUser==null){
runApp(NotLoggedin());
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mechat.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
class Loggedin extends StatelessWidget {
  Loggedin({super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      home: Home(userModel:userModel ,firebaseUser:firebaseUser ),
    );
  }
}

class NotLoggedin extends StatelessWidget {
  NotLoggedin({super.key, });
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}