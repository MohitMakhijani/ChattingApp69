import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:untitled2/model/chatroommodel.dart';
import 'package:untitled2/model/user%20data%20model.dart';

import 'chatRoom_page.dart';

class SearchPage extends StatefulWidget {
  final UserModel? userModel;
  final User? FirebaseUser;
  const SearchPage({Key? key, required this.userModel, required this.FirebaseUser}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController search = TextEditingController();

  Future<ChatRoomId?> getChatroomModel(UserModel targetUser) async {
    const uuid =Uuid();
    ChatRoomId chatroom;

QuerySnapshot snapshot=await FirebaseFirestore.instance.collection
  ("chatrooms").where("Participants.${widget.userModel!.uid}"
    ,isEqualTo: true).where("Participants.${targetUser.uid}",isEqualTo: true).get();

if(snapshot.docs.length>0){
log("chatroom already exists");

var docdata =snapshot.docs[0].data();
ChatRoomId existingChatrrom= ChatRoomId.fromMap(docdata as Map<String,dynamic>);
chatroom=existingChatrrom;
}
else
  {
    ChatRoomId NewChatRoom = ChatRoomId(
      chatroomid: uuid.v1(),
    Lastmsg: "",
    Participants: {
         widget.userModel!.uid.toString():true,
      targetUser.uid.toString():true
    }
    );

    await FirebaseFirestore.instance.collection("chatrooms").doc(NewChatRoom.chatroomid).set(NewChatRoom.toMap());
    chatroom=NewChatRoom;
    log("new chatroom created");

  }
return chatroom;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.orange,),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: SearchBar(
                backgroundColor: MaterialStatePropertyAll(Colors.grey.shade300),
                controller: search,
                hintText: "Username",
                elevation: MaterialStatePropertyAll(2),
                shape: MaterialStatePropertyAll(LinearBorder.start(size: 1)),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("fullname", isEqualTo: search.text ?? "")
                  .where("fullname", isNotEqualTo: widget.userModel?.fullname ?? "")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data! as QuerySnapshot;

                    if (dataSnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);

                      return ListTile(
                        onTap: () async {
                          // Get or create the chatroom
                          ChatRoomId? chatroommodel =
                          await getChatroomModel(searchedUser);

                          if (chatroommodel != null) {
                            // Navigate to the chatroom page with the obtained chatroom ID
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomPage(
                                  tergetuser: searchedUser,
                                  FirebaseUser: widget.FirebaseUser,
                                  userModel: widget.userModel,
                                  chatroom: chatroommodel,
                                ),
                              ),
                            );
                          }
                        },
                        title: Text(searchedUser.email ?? ""),
                        subtitle: Text(searchedUser.fullname

                            ?? ""),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange,
                          foregroundImage:
                          NetworkImage(searchedUser.profilepicture.toString()?? ""),
                        ),
                      );
                    } else {
                      return Text('No users found');
                    }
                  }
                } else if (snapshot.hasError) {
                  return const Text(
                    "Unknown error occurred",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Handle the case where snapshot.data is null
                return const Center(child: Text('No users found'));
              },
            )
          ],
        ),
      ),
    );
  }
}
