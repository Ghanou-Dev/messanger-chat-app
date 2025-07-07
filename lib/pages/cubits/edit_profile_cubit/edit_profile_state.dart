import 'package:star_chat/models/user_model.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {
  final UserModel currentUserEditing;
  EditProfileInitial({required this.currentUserEditing});
}

class EditProfileSuccess extends EditProfileState {
  final UserModel currentUserEditing;
  EditProfileSuccess({required this.currentUserEditing});
}
