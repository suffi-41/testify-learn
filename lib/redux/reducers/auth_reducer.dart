import '../../models/auth_state.dart';
import '../actions/auth_actions.dart';

AuthState authReducer(AuthState state, dynamic action) {
  if (action is AuthSuccess) {
    return state.copyWith(
      uid: action.uid,
      role: action.role,
      isLoading: false,
      errorMessage: '',
    );
  } else if (action is StartLogin) {
    return state.copyWith(isLoading: true, errorMessage: '');
  } else if (action is AuthFailure) {
    return state.copyWith(isLoading: false, errorMessage: action.error);
  } else if (action is SetAuthLoading) {
    return state.copyWith(isLoading: action.isLoading);
  } else if (action is LogoutRequestAction) {
    return state.copyWith(isLoading: true);
  } else if (action is LogoutSuccessAction) {
    return AuthState.initial(); // or reset to logged-out state
  } else if (action is AuthFailure) {
    return state.copyWith(
      isLoading: false,
      errorMessage: action.error.toString(),
    );
  }

  return state;
}
