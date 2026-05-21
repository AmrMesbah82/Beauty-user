// ******************* FILE INFO *******************
// File Name: sendgrid_repository.dart
// Created by: Amr Mesbah
// UPDATED: preferredLanguage + gender added for language-gated & gender-aware templates

import 'package:cloud_functions/cloud_functions.dart';

class SendGridRepository {

  // ── Company notification ───────────────────────────────────────────────────

  Future<void> sendContactNotification({
    required String toEmail,
    required String submitterName,
    required String submitterEmail,
    required String submitterPhone,
    required String subject,
    required String message,
    required bool   isArabic,
    required String preferredLanguage,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sendContactEmail');
      final result   = await callable.call({
        'toEmail':           toEmail,
        'submitterName':     submitterName,
        'submitterEmail':    submitterEmail,
        'submitterPhone':    submitterPhone,
        'subject':           subject,
        'message':           message,
        'isArabic':          isArabic,
        'preferredLanguage': preferredLanguage,
      });
    } on FirebaseFunctionsException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // ── Submitter confirmation ─────────────────────────────────────────────────

  Future<void> sendContactConfirmation({
    required String toEmail,
    required String submitterName,
    required String subject,
    required String message,
    required bool   isArabic,
    required String preferredLanguage,
    required String gender,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sendContactConfirmation');
      final result   = await callable.call({
        'toEmail':           toEmail,
        'submitterName':     submitterName,
        'subject':           subject,
        'message':           message,
        'isArabic':          isArabic,
        'preferredLanguage': preferredLanguage,
        'gender':            gender,
      });
    } on FirebaseFunctionsException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}