/// ******************* FILE INFO *******************
/// File Name: gender_cubit.dart
/// Description: Cubit that holds the active gender selection.
///              When toggled, notifies all listeners so page cubits
///              can re-fetch gender-specific data from Firebase.
/// Created by: Amr Mesbah
/// Last Update: 16/04/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'gender_state.dart';

class GenderCubit extends Cubit<GenderState> {
  GenderCubit() : super(const GenderState(gender: 'female'));

  String get current => state.gender;

  void setGender(String gender) {
    if (gender == state.gender) return;
    print('🔄 [GenderCubit] setGender: ${state.gender} → $gender');
    emit(GenderState(gender: gender));
  }

  void toggle() {
    final next = state.isMale ? 'female' : 'male';
    print('🔄 [GenderCubit] toggle: ${state.gender} → $next');
    emit(GenderState(gender: next));
  }
}