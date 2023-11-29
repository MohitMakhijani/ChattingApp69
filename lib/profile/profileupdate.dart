import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:untitled2/model/user%20data%20model.dart';
import 'package:untitled2/Widgets/toast.dart';
import '../pages/Home.dart';

class ProfileUpdate extends StatefulWidget {
  final UserModel? userModel;
  final User? FirebaseUser;

  ProfileUpdate({Key? key, required this.userModel, required this.FirebaseUser}) : super(key: key);

  @override
  State<ProfileUpdate> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileUpdate> {
  TextEditingController _profileNameController = TextEditingController();
  File? imgFile;

  void cheakValues() {
    String name = _profileNameController.text.trim();
    if (name == "") {
      toast().toastmsg("Please Enter Your Name");
      print("object");
    } else {
      uplodData();
    }
  }

  void editName() {
    TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: Container(
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Enter your new name'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = _nameController.text.trim();
                UploadTask uploadTask = FirebaseStorage.instance.ref("fullname").child(widget.userModel!.uid.toString()).putString(newName);
                TaskSnapshot snapshot = await uploadTask;
                widget.userModel!.fullname = newName;

                try {
                  await FirebaseFirestore.instance.collection("users").doc(widget.userModel!.uid).set(widget.userModel!.toMap());
                  toast().toastmsg("Updated");
                  print("Name updated successfully");
                } catch (error) {
                  print("Error updating name: $error");
                  toast().toastmsg("Error updating name");
                }
                setState(() {});

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void uplodData() async {
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepicture").child(widget.userModel!.uid.toString()).putFile(imgFile!);
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
        return Home(userModel: widget.userModel, firebaseUser: widget.FirebaseUser);
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
        radius: 200,
        backgroundImage: NetworkImage(widget.userModel!.profilepicture.toString()),
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
                  SizedBox(width: 5),
                  Container(
                    width: 320,
                    height: 42,
                    child: Row(
                      children: [
                        Text("Name :", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange)),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(widget.userModel?.fullname ?? "", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            onPressed: () {
                              editName();
                            },
                            icon: Icon(Icons.edit, size: 25, color: Colors.deepOrange),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Text("email : ${widget.userModel!.email.toString()}",style: const TextStyle(color: Colors.black,fontSize: 15,),),
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
                    cheakValues();
                  },
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
