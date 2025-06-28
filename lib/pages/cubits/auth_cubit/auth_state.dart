abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoaded extends AuthState {}

class AuthGo extends AuthState {
  final String pageRoute;
  AuthGo({required this.pageRoute});
}

class LoginSuccess extends AuthState {}

class LoginFialur extends AuthState {
  final String messageError;
  LoginFialur({required this.messageError});
}

class SingupSuccess extends AuthState {}

class SingupFailure extends AuthState {
  final String messageError;
  SingupFailure({required this.messageError});
}
