/// ******************* FILE INFO *******************
/// File Name: client_services_state.dart
/// Description: States for ClientServicesCubit.
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import '../../data/models/client_services_model.dart';

abstract class ClientServicesState {}

class ClientServicesInitial extends ClientServicesState {}

class ClientServicesLoading extends ClientServicesState {}

class ClientServicesLoaded extends ClientServicesState {
  final ClientServicesPageModel data;
  ClientServicesLoaded(this.data);
}

class ClientServicesSaved extends ClientServicesState {
  final ClientServicesPageModel data;
  ClientServicesSaved(this.data);
}

class ClientServicesError extends ClientServicesState {
  final String message;
  ClientServicesError(this.message);
}