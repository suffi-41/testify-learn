import 'package:redux/redux.dart';
import 'package:testify_learn_application/redux/middleware/auth_middleware.dart';
import '../../models/root_state.dart';
import '../reducers/root_reducer.dart';

final Store<RootState> appStore = Store<RootState>(
  rootReducer,
  initialState: RootState.initial(),
  middleware: [authMiddleware],
);
