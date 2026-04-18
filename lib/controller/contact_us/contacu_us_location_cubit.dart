// ******************* FILE INFO *******************
// File Name: contact_us_cms_cubit.dart
// Created by: Claude Assistant

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beauty_user/controller/contact_us/contacu_us_location_state.dart';

import 'package:beauty_user/repo/contact_us/contact_us_location.dart';
import 'package:beauty_user/repo/contact_us/contacu_us_repo_im.dart';

import '../../model/contact_us/contact_model_location.dart';


class ContactUsCmsCubit extends Cubit<ContactUsCmsState> {
  final ContactUsCmsRepo _repo;

  ContactUsCmsCubit({ContactUsCmsRepo? repo})
      : _repo = repo ?? ContactUsCmsRepoImpl(),
        super(ContactUsCmsInitial());

  // ── Load contact us CMS data ──────────────────────────────────────────────

  Future<void> load() async {
    print('🔵 [ContactUsCmsCubit] load() called');
    try {
      emit(ContactUsCmsLoading());
      final data = await _repo.load();
      print('🔵 [ContactUsCmsCubit] fetch success → publishStatus=${data.publishStatus}');
      print('🔵 [ContactUsCmsCubit] title.en=${data.headings.title.en}');
      print('🔵 [ContactUsCmsCubit] clientReasons=${data.clientDescription.reasons.length}');
      print('🔵 [ContactUsCmsCubit] socialIcons=${data.socialIcons.length}');
      emit(ContactUsCmsLoaded(data));
    } catch (e, stack) {
      print('🔴 [ContactUsCmsCubit] LOAD ERROR: $e');
      print('🔴 [ContactUsCmsCubit] STACK: $stack');
      emit(ContactUsCmsError('Failed to load contact us data: ${e.toString()}'));
    }
  }

  // ── Save contact us CMS data ──────────────────────────────────────────────

  Future<void> save({
    required ContactUsCmsModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    try {
      await _repo.save(model: model, imageUploads: imageUploads);


      // ✅ Reload to get updated URLs and emit with data
      final updatedData = await _repo.load();
      emit(ContactUsCmsSaved(updatedData));
    } catch (e) {
      emit(ContactUsCmsError('Failed to save contact us data: ${e.toString()}'));
    }
  }
}