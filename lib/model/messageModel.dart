class MessageModel{
String? messageId;
  String? sender;
  String? text;
  String?createdon;
  bool? seen;

  MessageModel({this.text, this.createdon, this.seen, this.sender,this.messageId});
  MessageModel.fromMap(Map<String,dynamic>map){

    sender=map["sender"];
    text=map["text"];
    createdon=map["createdon"];
    seen=map['seen'];
    messageId=map['messageId'];


  }

  Map<String,dynamic>toMap(){
    return{

      "sender":sender,
      "text":text,
      "createdon":createdon,
      "seen":seen,
      "messageId":messageId

    };
  }

}