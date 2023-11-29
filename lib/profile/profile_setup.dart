import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:untitled2/model/user%20data%20model.dart';
import 'package:untitled2/Widgets/toast.dart';

import '../pages/Home.dart';

class ProfileSetup extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  ProfileSetup({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  TextEditingController _profileNameController = TextEditingController();
  String code = "+91";
  File? imgFile;

  void checkValues() {
    String name = _profileNameController.text.trim();
    if (name == "") {
      toast().toastmsg("Please Enter Your Name");
      print("object");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask =
    FirebaseStorage.instance.ref("profilepicture").child(widget.userModel!.uid.toString()).putFile(imgFile!);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = _profileNameController.text.trim();
    widget.userModel!.fullname = fullname;
    widget.userModel!.profilepicture = imageUrl;

    try {
      await FirebaseFirestore.instance.collection("users").doc(widget.userModel!.uid).set(widget.userModel!.toMap());
      toast().toastmsg("Updated");
      print("Data uploaded successfully");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Home(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
      }));
    } catch (error) {
      print("Error uploading data: $error");
      toast().toastmsg("Error uploading data");
    }
  }

  Widget _buildProfileImage() {
    if (imgFile != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(imgFile!),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundImage: AssetImage('assets/images/user.png'),
      );
    }
  }

  Future<void> _chooseImg(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imgFile = File(pickedFile.path);
      });
    }
  }

  void _chooseFile() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.orange,
          height: 120,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black, size: 30),
                title: Text("Camera", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  await _chooseImg(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album_outlined, color: Colors.black, size: 30),
                title: Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  await _chooseImg(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectCountryCode() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 120,
          color: Colors.orange,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "INDIA +91",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _updateCountryCode("+91");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  "NHI PTA +1",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _updateCountryCode("+1");
                  Navigator.pop(context);
                },
                // Add more country code options as needed
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateCountryCode(String newCode) {
    setState(() {
      code = newCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Setup",
          style: TextStyle(
            color: Colors.red,
            fontFamily: 'mohit',
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Container(
                  color: Colors.grey.shade200,
                  width: 200,
                  height: 200,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _chooseFile();
                      },
                      child: _buildProfileImage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //   decoration: BoxDecoration(color: Colors.grey, border: Border.all(width: 1)),
                  //   width: 40,
                  //   height: 42,
                  //   child: Center(
                  //     child: GestureDetector(
                  //       onTap: () {
                  //         _selectCountryCode();
                  //       },
                  //       child: Text(code),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    width: 320,
                    height: 42,
                    child: TextField(
                      controller: _profileNameController,
                      decoration: const InputDecoration(hintText: 'Enter Your FullName'),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    elevation: MaterialStateProperty.all(10),
                    fixedSize: MaterialStateProperty.all(Size(100, 0)),
                    side: MaterialStateProperty.all(BorderSide(width: 1)),
                  ),
                  onPressed: () {
                    checkValues();
                  },
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}