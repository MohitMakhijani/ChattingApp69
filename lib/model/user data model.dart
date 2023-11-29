

class UserModel{

  String? uid;
  String? email;
  String? profilepicture;
  String? fullname;

UserModel({
  this.uid,
  this.email,
  this.fullname,
  this.profilepicture
}
    );

UserModel.fromMap(Map<String,dynamic>map){
   uid=map["uid"];
   email=map["email"];
   fullname=map["fullname"];
   profilepicture=map["profilepicture"];
}
Map<String,dynamic>toMap(){
  return {
    "uid":uid,
    "fullname":fullname,
    "profilepicture":profilepicture,
    "email":email

  };
}

}