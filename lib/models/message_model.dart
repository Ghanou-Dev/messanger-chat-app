import 'package:star_chat/const.dart';

class MessageModel {
  final String message;
  final String senderUID;
  final String receiverUID;
  final String type;
  final dynamic sendAt;
  MessageModel({
    required this.message,
    required this.senderUID,
    required this.receiverUID,
    required this.sendAt,
    required this.type,
  });

  factory MessageModel.fromJson(snapshot) {
    return MessageModel(
      message: snapshot[kMessage],
      senderUID: snapshot[kSenderUID],
      receiverUID: snapshot[kReceiverUID],
      sendAt: snapshot[kSendAt],
      type: snapshot[kType],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kMessage: message,
      kSenderUID: senderUID,
      kReceiverUID: receiverUID,
      kSendAt: sendAt,
      kType: type,
    };
  }
}
