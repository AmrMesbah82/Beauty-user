/// ******************* FILE INFO *******************
/// File Name: gender_state.dart
/// Description: State for GenderCubit.
/// Created by: Amr Mesbah
/// Last Update: 16/04/2026

class GenderState {
  final String gender; // 'female' or 'male'

  const GenderState({this.gender = 'female'});

  bool get isMale => gender == 'male';
  bool get isFemale => gender == 'female';
}