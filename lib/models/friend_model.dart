import 'package:star_chat/const.dart';

class FriendModel {
  final String friendUID;
  final String friendSearchID;
  final String friendName;
  final String friendProfileImage;
  final dynamic addAt;
  final dynamic lastSend;
  final String lastMessage;
  FriendModel({
    required this.friendUID,
    required this.friendSearchID,
    required this.friendName,
    required this.friendProfileImage,
    required this.addAt,
    required this.lastSend,
    required this.lastMessage
  });

  factory FriendModel.fromjson(friendSnapshot) {
    return FriendModel(
      friendUID: friendSnapshot[kFriendUID],
      friendSearchID: friendSnapshot[kFriendSearchID],
      friendName: friendSnapshot[kFriendName],
      friendProfileImage: friendSnapshot[kFriendProfileImage],
      addAt: friendSnapshot[kAddAt],
      lastSend: friendSnapshot[kLastSend],
      lastMessage: friendSnapshot[kLastMessage],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kFriendUID: friendUID,
      kFriendSearchID: friendSearchID,
      kFriendName: friendName,
      kFriendProfileImage: friendProfileImage,
      kAddAt: addAt,
      kLastSend: lastSend,
      kLastMessage: lastMessage,
    };
  }
}
