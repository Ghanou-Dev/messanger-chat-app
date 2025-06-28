abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileGo extends ProfileState {
  final String pageRoute;
  ProfileGo({required this.pageRoute});
}

class ProfilePickImageSuccess extends ProfileState {}

class ProfileFailurePickImage extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}
