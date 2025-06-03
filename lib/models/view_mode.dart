import '../../models/root_state.dart';
import 'package:redux/redux.dart';

class LoginViewModel {
  final bool isLoading;
  final String? errorMessage;
  final String? role;

  LoginViewModel({
    required this.isLoading,
    required this.errorMessage,
    required this.role,
  });

  static LoginViewModel fromStore(Store<RootState> store) {
    final auth = store.state.authState;
    return LoginViewModel(
      isLoading: auth.isLoading,
      errorMessage: auth.errorMessage,
      role: auth.role,
    );
  }
}
