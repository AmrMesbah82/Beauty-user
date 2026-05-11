// ******************* FILE INFO *******************
// File Name: contact_repo_impl.dart
// Created by: Amr Mesbah

import 'package:beauty_user/repo/contact_us/sendgrid_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/contact_us/contact_us_model.dart';
import 'contact_us_repo.dart';

class ContactRepoImpl implements ContactRepo {
  final _col = FirebaseFirestore.instance.collection('contact_submissions');
  final _sendGrid = SendGridRepository();

  // ── Submit (public website) ────────────────────────────────────────────────

  @override
  Future<void> submitContact(ContactSubmission submission) async {
    // 1) Save to Firestore
    final doc = _col.doc();
    final saved = submission.copyWith(id: doc.id);
    await doc.set(saved.toMap());
    print('🟢 [ContactRepoImpl] Saved to Firestore → ${doc.id}');

    final submitterName = '${saved.firstName} ${saved.lastName}';
    final submitterPhone = '${saved.countryCode}${saved.phoneNumber}';
    final isArabic = saved.preferredLanguage == 'ar';

    // 2) Notify the company
    try {
      print('📧 [ContactRepoImpl] Sending company notification...');
      await _sendGrid.sendContactNotification(
        toEmail: 'm.handousa@bayanatz.com',
        submitterName: submitterName,
        submitterEmail: saved.email,
        submitterPhone: submitterPhone,
        subject: saved.subject,
        message: saved.message,
        isArabic: isArabic,
      );
      print('✅ [ContactRepoImpl] Company email sent successfully');
    } catch (e) {
      print('🔴 [ContactRepoImpl] Company email failed (non-fatal): $e');
    }

    // 3) Send confirmation to the submitter
    try {
      print('📧 [ContactRepoImpl] Sending confirmation to submitter...');
      await _sendGrid.sendContactConfirmation(   // 👈 new method
        toEmail: saved.email,
        submitterName: submitterName,
        subject: saved.subject,
        message: saved.message,
        isArabic: isArabic,
      );
      print('✅ [ContactRepoImpl] Confirmation email sent successfully');
    } catch (e) {
      print('🔴 [ContactRepoImpl] Confirmation email failed (non-fatal): $e');
    }
  }

  // ── Fetch all (admin) ──────────────────────────────────────────────────────

  @override
  Future<List<ContactSubmission>> fetchAll() async {
    final snap = await _col
        .orderBy('submissionDate', descending: true)
        .get();
    return snap.docs
        .map((d) => ContactSubmission.fromMap(d.id, d.data()))
        .toList();
  }

  // ── Update (admin: status / note) ─────────────────────────────────────────

  @override
  Future<void> updateSubmission(ContactSubmission submission) async {
    await _col.doc(submission.id).update({
      'status': submission.status,
      'note': submission.note,
    });
  }
}