import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/pages/Searchpage.dart';
import 'package:untitled2/model/user%20data%20model.dart';

import '../profile/profileupdate.dart';
import 'Contacts.dart';
import 'lo0ginpage.dart';

class Home extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  Home({Key? key, this.userModel, this.firebaseUser}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late IconData fabIcon;

FirebaseAuth _auth= FirebaseAuth.instance;
FirebaseFirestore _firebaseFirestore=FirebaseFirestore.instance;



  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this,initialIndex: 1);
    tabController.addListener(() {
      setState(() {
        switch (tabController.index) {
          case 1:
            fabIcon = Icons.camera;
            break;
          case 0:
            fabIcon = Icons.chat;
            break;
          case 2:
            fabIcon = Icons.post_add_outlined;
            break;
        }
      });
    });
    // Initialize the initial icon
    fabIcon = Icons.chat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 10,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.camera_alt, color: Colors.white),
            ),
            Tab(
              child: Text("Chats",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
            Tab(
              icon: Icon(Icons.post_add, color: Colors.white),
            ),
          ],
        ),
        actions: [

         IconButton(onPressed: () {

           Navigator.push(
             context,
             PageRouteBuilder(
               pageBuilder: (context, animation, secondaryAnimation) =>
                   ProfileUpdate(userModel: widget.userModel, FirebaseUser: widget.firebaseUser),
               transitionsBuilder: (context, animation, secondaryAnimation, child) {
                 const begin = Offset(1.0, 0.0);
                 const end = Offset.zero;
                 const curve = Curves.easeInOutQuart;

                 var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                 var offsetAnimation = animation.drive(tween);

                 return SlideTransition(
                   position: offsetAnimation,
                   child: FadeTransition(
                     opacity: animation,
                     child: child,
                   ),
                 );
               },
             ),
           );
         },



             icon: Icon(Icons.account_circle_rounded,size: 30,)),
          SizedBox(width: 10,),
          IconButton(
              onPressed: () {
                final _auth = FirebaseAuth.instance;
               _auth.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              )),
        ],
        elevation: 10,
        backgroundColor: Colors.orange,
        title: Text(
          "Me Chat",
          style: TextStyle(
            color: Colors.red.shade900,
            fontWeight: FontWeight.w700,
            fontSize: 30,
            fontFamily: 'mohit',
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [Icon(Icons.camera), chatlistview(userModel: widget.userModel, FirebaseUser: widget.firebaseUser,), Icon(Icons.post_add)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation,
                  secondaryAnimation) =>
               SearchPage(userModel: widget.userModel, FirebaseUser: widget.firebaseUser),
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
        backgroundColor: Colors.orange,
        child: Icon(Icons.add_circle, color: Colors.white),
      ),
    );
  }
}
