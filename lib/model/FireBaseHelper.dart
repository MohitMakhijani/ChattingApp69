import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/model/user%20data%20model.dart';
class FireBaseHelper{
  static Future<UserModel?>getUserModelId(String uid)async{UserModel? userModel;

  DocumentSnapshot docSnap= await FirebaseFirestore.instance.collection("users").doc(uid).get();

  if(docSnap.data()!=null){
    userModel=UserModel.fromMap(docSnap.data() as Map<String,dynamic>);
  }
  return userModel;
  }
}