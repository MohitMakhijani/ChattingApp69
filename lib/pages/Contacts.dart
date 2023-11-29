import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled2/model/chatroommodel.dart';

import '../model/FireBaseHelper.dart';
import '../model/user data model.dart';
import 'chatRoom_page.dart';
class chatlistview extends StatefulWidget {
  final UserModel? userModel;
  final User? FirebaseUser;
  const chatlistview({Key? key, required this.userModel, required this.FirebaseUser}) : super(key: key);

  @override
  State<chatlistview> createState() => _chatlistviewState();
}

class _chatlistviewState extends State<chatlistview> {
  // Function to open the profile image dialog
  Future openProfileImg(UserModel targetUser,) {
   return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 10,
          backgroundColor: Colors.black,
          child: Container(
            width: 600,
            height: 500,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(targetUser.profilepicture.toString()),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("Participants.${widget.userModel!.uid}", isEqualTo: true)
              .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot ChatroomSnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      ChatRoomId chatRoomModel =
                      ChatRoomId.fromMap(ChatroomSnapshot.docs[index].data() as Map<String, dynamic>);

                      Map<String, dynamic> Participants = chatRoomModel.Participants!;
                      List<String> Participantskeys = Participants.keys.toList();
                      Participantskeys.remove(widget.userModel!.uid);

                      if (Participantskeys.isNotEmpty) {
                        return FutureBuilder(
                          future: FireBaseHelper.getUserModelId(Participantskeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState == ConnectionState.done) {
                              UserModel targetUser = userData.data as UserModel;
                              return buildChatListTile(targetUser, chatRoomModel);
                            } else {
                              return Container();
                            }
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                    itemCount: ChatroomSnapshot.docs.length,
                  );
                } else if (snapshot.hasError) {
                  // Handle error state
                } else {
                  return Center(child: Text("No Chats"));
                }
              } else {
                return buildShimmerEffect();
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  // Function to build ListTile for each chat room
  Widget buildChatListTile(UserModel targetUser, ChatRoomId chatRoomModel) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return ChatRoomPage(
                tergetuser: targetUser,
                chatroom: chatRoomModel,
                userModel: widget.userModel,
                FirebaseUser: widget.FirebaseUser,
              );
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      leading: GestureDetector(
        onTap: () {
          openProfileImg(targetUser.uid as UserModel);
        },
        child: CircleAvatar(radius: 30, foregroundImage: NetworkImage(targetUser.profilepicture.toString())),
      ),
      title: Text(targetUser.fullname.toString()),
      subtitle: FutureBuilder(
        future: getLastMessage(chatRoomModel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String lastMsg = snapshot.data.toString();
            return Text(lastMsg);
          } else {
            return Text("Loading...");
          }
        },
      ),
    );
  }

  // Function to build Shimmer effect for loading
  Widget buildShimmerEffect() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Shimmer(
          gradient: LinearGradient(colors: [Colors.red, Colors.green]),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
            ),
            title: Container(
              width: 600,
              color: Colors.white,
              height: 15,
            ),
            subtitle: Container(
              width: 400,
              height: 10,
              color: Colors.white,
            ),
          ),
        );
      },
      itemCount: 1, // Set a fixed number of shimmer items
    );
  }
}

Future<String> getLastMessage(ChatRoomId chatRoom) async {
  QuerySnapshot messages = await FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(chatRoom.chatroomid)
      .collection("messages")
      .orderBy("createdon", descending: true)
      .limit(1)
      .get();

  if (messages.docs.isNotEmpty) {
    return messages.docs[0]["text"];
  } else {
    return "No messages";
  }
}

