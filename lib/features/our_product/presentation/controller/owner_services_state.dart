/// ******************* FILE INFO *******************
/// File Name: owner_services_state.dart
/// Description: States for OwnerServicesCubit.
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

import '../../data/models/owner_services_model.dart';

abstract class OwnerServicesState {}

class OwnerServicesInitial extends OwnerServicesState {}

class OwnerServicesLoading extends OwnerServicesState {}

class OwnerServicesLoaded extends OwnerServicesState {
  final OwnerServicesPageModel data;
  OwnerServicesLoaded(this.data);
}

class OwnerServicesSaved extends OwnerServicesState {
  final OwnerServicesPageModel data;
  OwnerServicesSaved(this.data);
}

class OwnerServicesError extends OwnerServicesState {
  final String message;
  OwnerServicesError(this.message);
}