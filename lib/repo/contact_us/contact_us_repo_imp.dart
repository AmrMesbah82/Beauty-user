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

    // 2) Send email notification
    try {
      print('📧 [ContactRepoImpl] Calling SendGridRepository...');
      await _sendGrid.sendContactNotification(
        toEmail: 'a.mesbah@bayanatz.com',
        submitterName: '${saved.firstName} ${saved.lastName}',
        submitterEmail: saved.email,
        submitterPhone: '${saved.countryCode}${saved.phoneNumber}',
        subject: saved.subject,
        message: saved.message,
        isArabic: saved.preferredLanguage == 'ar',
      );
      print('✅ [ContactRepoImpl] Email sent successfully');
    } catch (e) {
      // Don't fail the whole submission if email fails
      print('🔴 [ContactRepoImpl] Email failed (non-fatal): $e');
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