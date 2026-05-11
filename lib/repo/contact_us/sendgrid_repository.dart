// ******************* FILE INFO *******************
// File Name: sendgrid_repository.dart
// Created by: Amr Mesbah

import 'package:cloud_functions/cloud_functions.dart';

class SendGridRepository {
  // ── Company notification (new inquiry arrived) ─────────────────────────────

  Future<void> sendContactNotification({
    required String toEmail,
    required String submitterName,
    required String submitterEmail,
    required String submitterPhone,
    required String subject,
    required String message,
    required bool isArabic,
  }) async {
    print('\n📧 [SENDGRID] Sending company notification...');
    print('📧 [SENDGRID] Payload:');
    print('   toEmail: "$toEmail"');
    print('   submitterName: "$submitterName"');
    print('   submitterEmail: "$submitterEmail"');
    print('   submitterPhone: "$submitterPhone"');
    print('   subject: "$subject"');
    print('   message: "$message"');
    print('   isArabic: $isArabic');

    final result = await FirebaseFunctions.instance
        .httpsCallable('sendContactEmail')
        .call({
      'toEmail': toEmail,
      'submitterName': submitterName,
      'submitterEmail': submitterEmail,
      'submitterPhone': submitterPhone,
      'subject': subject,
      'message': message,
      'isArabic': isArabic,
    });

    print('✅ [SENDGRID] Company notification result: ${result.data}');
  }

  // ── Submitter confirmation (thank you receipt) ─────────────────────────────

  Future<void> sendContactConfirmation({
    required String toEmail,
    required String submitterName,
    required String subject,
    required String message,
    required bool isArabic,
  }) async {
    print('\n📧 [SENDGRID] Sending submitter confirmation...');
    print('📧 [SENDGRID] Payload:');
    print('   toEmail: "$toEmail"');
    print('   submitterName: "$submitterName"');
    print('   subject: "$subject"');
    print('   message: "$message"');
    print('   isArabic: $isArabic');

    final result = await FirebaseFunctions.instance
        .httpsCallable('sendContactConfirmation')  // 👈 separate Cloud Function
        .call({
      'toEmail': toEmail,
      'submitterName': submitterName,
      'subject': subject,
      'message': message,
      'isArabic': isArabic,
    });

    print('✅ [SENDGRID] Confirmation result: ${result.data}');
  }
}