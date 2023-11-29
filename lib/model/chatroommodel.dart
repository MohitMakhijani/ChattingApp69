class ChatRoomId{
  String? chatroomid;
  Map<String,dynamic>? Participants;
  String? Lastmsg;

  ChatRoomId({
    this.chatroomid,this.Participants,this.Lastmsg

});
  ChatRoomId.fromMap(Map<String,dynamic>map){
    chatroomid=map["chatroomid"];
    Participants=map["Participants"];
    Lastmsg=map["Lastmsg"];
  }
  Map<String,dynamic> toMap(){
    return{
      "chatroomid":  chatroomid,
      "Participants":Participants,
      "Lastmsg":Lastmsg
  };
}

}