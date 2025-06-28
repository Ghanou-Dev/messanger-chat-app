abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoaded extends SearchState {}

class SearchSuccess extends SearchState {}

class SearchFailiare extends SearchState {
  final String errorMessage;
  SearchFailiare({required this.errorMessage});
}

class SearchEmpty extends SearchState {}
