class AuthState {
  final String uid;
  final String role;
  final bool isLoading;
  final String errorMessage;

  AuthState({
    this.uid = '',
    this.role = '',
    this.isLoading = false,
    this.errorMessage = '',
  });

  factory AuthState.initial() => AuthState();

  AuthState copyWith({
    String? uid,
    String? role,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
