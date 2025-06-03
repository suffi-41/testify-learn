import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../models/root_state.dart';
import '../redux/actions/counter_action.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Redux Counter')),
      body: StoreConnector<RootState, int>(
        converter: (store) => store.state.appState.counter,
        builder: (context, counter) => Center(
          child: Text('Count: $counter', style: TextStyle(fontSize: 24)),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StoreConnector<RootState, VoidCallback>(
            converter: (store) =>
                () => store.dispatch(IncrementAction()),
            builder: (context, callback) => FloatingActionButton(
              onPressed: callback,
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(height: 10),
          StoreConnector<RootState, VoidCallback>(
            converter: (store) =>
                () => store.dispatch(DecrementAction()),
            builder: (context, callback) => FloatingActionButton(
              onPressed: callback,
              child: Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }
}
