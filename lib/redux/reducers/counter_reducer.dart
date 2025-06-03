import '../../models/app_state.dart';
import '../actions/counter_action.dart';

AppState counterReducer(AppState state, dynamic action) {
  if (action is IncrementAction) {
    return AppState(counter: state.counter + 1);
  } else if (action is DecrementAction) {
    return AppState(counter: state.counter - 1);
  }
  return state;
}
