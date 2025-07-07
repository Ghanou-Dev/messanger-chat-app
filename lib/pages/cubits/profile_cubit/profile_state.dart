import 'package:star_chat/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {
  ProfileInitial();
}

class ProfileGo extends ProfileState {
  final String pageRoute;
  ProfileGo({required this.pageRoute});
}

class ProfilePickImageSuccess extends ProfileState {}

class ProfileFailurePickImage extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final UserModel currentUserUpdate;
  ProfileUpdateSuccess({required this.currentUserUpdate});
}
