// ******************* FILE INFO *******************
// File Name: contact_repo_impl.dart
// Created by: Amr Mesbah
// UPDATED: preferredLanguage + gender passed to SendGrid for language-gated & gender-aware templates

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repo/contact_us_repo.dart';
import '../../domain/repo/sendgrid_repository.dart';
import '../models/contact_us_model.dart';


class ContactRepoImpl implements ContactRepo {
  final _col      = FirebaseFirestore.instance.collection('contact_submissions');
  final _sendGrid = SendGridRepository();

  // ── Submit (public website) ────────────────────────────────────────────────

  @override
  Future<void> submitContact(ContactSubmission submission) async {
    // 1) Save to Firestore
    final doc   = _col.doc();
    final saved = submission.copyWith(id: doc.id);
    await doc.set(saved.toMap());

    final submitterName  = '${saved.firstName} ${saved.lastName}';
    final submitterPhone = '${saved.countryCode}${saved.phoneNumber}';
    final isArabic       = saved.preferredLanguage == 'ar';

    // ── gender: for clients it is stored in targetAudience ────────────
    // For owners targetAudience is the salon's target audience,
    // but the personal gender is stored in the same field for clients.
    // We pass it as-is; the Cloud Function handles all known values.
    final gender = saved.targetAudience;

    // 2) Notify the company
    try {
      await _sendGrid.sendContactNotification(
        toEmail:           'm.handousa@bayanatz.com',
        submitterName:     submitterName,
        submitterEmail:    saved.email,
        submitterPhone:    submitterPhone,
        subject:           saved.subject,
        message:           saved.message,
        isArabic:          isArabic,
        preferredLanguage: saved.preferredLanguage,
      );
    } catch (e) {
    }

    // 3) Send confirmation to the submitter
    try {
      await _sendGrid.sendContactConfirmation(
        toEmail:           saved.email,
        submitterName:     submitterName,
        subject:           saved.subject,
        message:           saved.message,
        isArabic:          isArabic,
        preferredLanguage: saved.preferredLanguage,
        gender:            gender,
      );
    } catch (e) {
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
      'note':   submission.note,
    });
  }
}