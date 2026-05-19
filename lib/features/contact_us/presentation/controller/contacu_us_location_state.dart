// ******************* FILE INFO *******************
// File Name: contacu_us_location_state.dart
// Created by: Amr Mesbah

import '../../data/model/contact_us_location_model.dart';

abstract class ContactUsCmsState {}

class ContactUsCmsInitial extends ContactUsCmsState {}

class ContactUsCmsLoading extends ContactUsCmsState {}

class ContactUsCmsLoaded extends ContactUsCmsState {
  final ContactUsCmsModel data;
  ContactUsCmsLoaded(this.data);
}

class ContactUsCmsSaved extends ContactUsCmsState {
  final ContactUsCmsModel data;
  ContactUsCmsSaved(this.data);
}

class ContactUsCmsError extends ContactUsCmsState {
  final String message;
  ContactUsCmsError(this.message);
}