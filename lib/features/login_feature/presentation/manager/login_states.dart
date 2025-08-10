class LoginStates {}

class LoginInitialState extends LoginStates {}

class LoginLoading extends LoginStates {}

class LoginFailed extends LoginStates {
  final String errorMessage;

  LoginFailed({required this.errorMessage});
}

class LoginSuccess extends LoginStates {
  final String userRole;
  final String userID;

  LoginSuccess({required this.userID, required this.userRole});
}
