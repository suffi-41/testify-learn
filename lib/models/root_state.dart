import './app_state.dart';
import './auth_state.dart';

class RootState {
  final AppState appState;
  final AuthState authState;

  RootState({required this.appState, required this.authState});

  factory RootState.initial() => RootState(
    appState: AppState.initialState(),
    authState: AuthState.initial(),
  );
}
