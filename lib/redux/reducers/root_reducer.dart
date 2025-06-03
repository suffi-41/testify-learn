import '../../models/root_state.dart';
// import '../../models/app_state.dart';
// import '../../models/auth_state.dart';
import 'counter_reducer.dart';
import 'auth_reducer.dart';

RootState rootReducer(RootState state, dynamic action) {
  return RootState(
    appState: counterReducer(state.appState, action),
    authState: authReducer(state.authState, action),
  );
}
