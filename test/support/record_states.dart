import 'package:flutter_bloc/flutter_bloc.dart';

Future<List<S>> recordStates<S>(
  Cubit<S> cubit,
  Future<void> Function() action,
) async {
  final states = <S>[];
  final subscription = cubit.stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await subscription.cancel();
  return states;
}
