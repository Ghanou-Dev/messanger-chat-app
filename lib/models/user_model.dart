import 'package:star_chat/const.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String password;
  final String profileImage;
  final String searchID;
  final dynamic createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.profileImage,
    required this.searchID,
    required this.createdAt,
  });

  factory UserModel.fromJson(snapshot) {
    return UserModel(
      uid: snapshot[kUID],
      name: snapshot[kName],
      email: snapshot[kEmail],
      password: snapshot[kPassword],
      profileImage: snapshot[kProfileImage],
      searchID: snapshot[kSearchID],
      createdAt: snapshot[kCreatedAt],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kUID: uid,
      kName: name,
      kEmail: email,
      kPassword: password,
      kProfileImage: profileImage,
      kSearchID: searchID,
      kCreatedAt: createdAt,
    };
  }
}
