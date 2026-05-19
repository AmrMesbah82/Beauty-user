/// ******************* FILE INFO *******************
/// File Name: main_state.dart
/// Description: States for MasterCmsCubit.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import '../../data/model/main_model.dart';

abstract class MasterCmsState {}

class MasterCmsInitial extends MasterCmsState {}

class MasterCmsLoading extends MasterCmsState {}

class MasterCmsLoaded extends MasterCmsState {
  final MasterPageModel data;
  MasterCmsLoaded(this.data);
}

class MasterCmsSaved extends MasterCmsState {
  final MasterPageModel data;
  MasterCmsSaved(this.data);
}

class MasterCmsError extends MasterCmsState {
  final String message;
  MasterCmsError(this.message);
}