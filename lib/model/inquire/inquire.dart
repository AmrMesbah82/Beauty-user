// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_model.dart (UPDATED)
// Path: lib/model/inquiry_model.dart
// UPDATED: Replaced entity/location fields with salon-specific fields
//          to match new ContactSubmission model (Client/Owner design).
//          Backward compat preserved for old Firestore docs.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../contact_us/contact_us_model.dart';

enum InquiryStatus {
  newInquiry,
  replied,
  closed;

  String get label {
    switch (this) {
      case InquiryStatus.newInquiry:
        return 'New';
      case InquiryStatus.replied:
        return 'Replied';
      case InquiryStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case InquiryStatus.newInquiry:
        return const Color(0xFF008037);
      case InquiryStatus.replied:
        return const Color(0xFFFF9800);
      case InquiryStatus.closed:
        return const Color(0xFFE53935);
    }
  }

  static InquiryStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return InquiryStatus.newInquiry;
      case 'replied':
        return InquiryStatus.replied;
      case 'closed':
        return InquiryStatus.closed;
      default:
        return InquiryStatus.newInquiry;
    }
  }
}

class InquiryModel {
  final String id;
  final String userType;           // 'client' | 'owner'
  final String preferredLanguage;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phone;

  // ── Salon info (Owner) ──
  final String salonNameEn;
  final String salonNameAr;
  final String targetAudience;
  final String salonCountry;
  final String salonCity;
  final String noBranches;
  final String services;
  final String atLocation;

  // ── Message info ──
  final String subject;
  final String reason;
  final String message;

  // ── Admin fields ──
  final String note;
  final InquiryStatus status;
  final DateTime? submissionDate;

  const InquiryModel({
    required this.id,
    this.userType = 'client',
    required this.preferredLanguage,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phone,
    this.salonNameEn    = '',
    this.salonNameAr    = '',
    this.targetAudience = '',
    this.salonCountry   = '',
    this.salonCity      = '',
    this.noBranches     = '',
    this.services       = '',
    this.atLocation     = '',
    required this.subject,
    this.reason         = '',
    required this.message,
    required this.note,
    required this.status,
    this.submissionDate,
  });

  String get fullName => '$firstName $lastName'.trim();

  // ── Factory: Create from ContactSubmission ──────────────────────────────
  factory InquiryModel.fromContactSubmission(ContactSubmission contact) {
    return InquiryModel(
      id:                contact.id,
      userType:          contact.userType,
      preferredLanguage: contact.preferredLanguage,
      firstName:         contact.firstName,
      lastName:          contact.lastName,
      email:             contact.email,
      countryCode:       contact.countryCode,
      phone:             contact.phoneNumber,
      salonNameEn:       contact.salonNameEn,
      salonNameAr:       contact.salonNameAr,
      targetAudience:    contact.targetAudience,
      salonCountry:      contact.salonCountry,
      salonCity:         contact.salonCity,
      noBranches:        contact.noBranches,
      services:          contact.services,
      atLocation:        contact.atLocation,
      subject:           contact.subject,
      reason:            contact.reason,
      message:           contact.message,
      note:              contact.note,
      status:            InquiryStatus.fromString(contact.status),
      submissionDate:    contact.submissionDate,
    );
  }

  // ── Factory: From Firestore Map ─────────────────────────────────────────
  factory InquiryModel.fromMap(String id, Map<String, dynamic> map) {
    // Handle backward compatibility with old 'fullName' field
    String firstName = (map['firstName'] as String?) ?? '';
    String lastName  = (map['lastName']  as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map['fullName'] as String?) ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    // Backward compat: old entityName → salonNameEn, old location → salonCountry
    String salonNameEn = (map['salonNameEn'] as String?) ?? '';
    if (salonNameEn.isEmpty) {
      salonNameEn = (map['entityName'] as String?) ?? '';
    }

    String salonCountry = (map['salonCountry'] as String?) ?? '';
    if (salonCountry.isEmpty) {
      salonCountry = (map['location'] as String?) ?? '';
    }

    return InquiryModel(
      id:                id,
      userType:          (map['userType']          as String?) ?? 'client',
      preferredLanguage: (map['preferredLanguage'] as String?) ?? 'en',
      firstName:         firstName,
      lastName:          lastName,
      email:             (map['email']             as String?) ?? '',
      countryCode:       (map['countryCode']       as String?) ?? '',
      phone:             (map['phoneNumber']       as String?) ?? '',
      salonNameEn:       salonNameEn,
      salonNameAr:       (map['salonNameAr']       as String?) ?? '',
      targetAudience:    (map['targetAudience']    as String?) ?? '',
      salonCountry:      salonCountry,
      salonCity:         (map['salonCity']         as String?) ?? '',
      noBranches:        (map['noBranches']        as String?) ?? '',
      services:          (map['services']          as String?) ?? '',
      atLocation:        (map['atLocation']        as String?) ?? '',
      subject:           (map['subject']           as String?) ?? '',
      reason:            (map['reason']            as String?) ?? '',
      message:           (map['message']           as String?) ?? '',
      note:              (map['note']              as String?) ?? '',
      status: InquiryStatus.fromString((map['status'] as String?) ?? 'New'),
      submissionDate: map['submissionDate'] != null
          ? DateTime.parse(map['submissionDate'] as String)
          : null,
    );
  }

  // ── To Firestore Map ────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'userType':          userType,
    'firstName':         firstName,
    'lastName':          lastName,
    'fullName':          fullName,
    'email':             email,
    'countryCode':       countryCode,
    'phoneNumber':       phone,
    'preferredLanguage': preferredLanguage,
    'salonNameEn':       salonNameEn,
    'salonNameAr':       salonNameAr,
    'targetAudience':    targetAudience,
    'salonCountry':      salonCountry,
    'salonCity':         salonCity,
    'noBranches':        noBranches,
    'services':          services,
    'atLocation':        atLocation,
    'subject':           subject,
    'reason':            reason,
    'message':           message,
    'note':              note,
    'status':            status.label,
    'submissionDate':    submissionDate?.toIso8601String(),
  };

  InquiryModel copyWith({
    String? id,
    String? userType,
    String? preferredLanguage,
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    String? phone,
    String? salonNameEn,
    String? salonNameAr,
    String? targetAudience,
    String? salonCountry,
    String? salonCity,
    String? noBranches,
    String? services,
    String? atLocation,
    String? subject,
    String? reason,
    String? message,
    String? note,
    InquiryStatus? status,
    DateTime? submissionDate,
  }) =>
      InquiryModel(
        id:                id                ?? this.id,
        userType:          userType          ?? this.userType,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        firstName:         firstName         ?? this.firstName,
        lastName:          lastName          ?? this.lastName,
        email:             email             ?? this.email,
        countryCode:       countryCode       ?? this.countryCode,
        phone:             phone             ?? this.phone,
        salonNameEn:       salonNameEn       ?? this.salonNameEn,
        salonNameAr:       salonNameAr       ?? this.salonNameAr,
        targetAudience:    targetAudience    ?? this.targetAudience,
        salonCountry:      salonCountry      ?? this.salonCountry,
        salonCity:         salonCity         ?? this.salonCity,
        noBranches:        noBranches        ?? this.noBranches,
        services:          services          ?? this.services,
        atLocation:        atLocation        ?? this.atLocation,
        subject:           subject           ?? this.subject,
        reason:            reason            ?? this.reason,
        message:           message           ?? this.message,
        note:              note              ?? this.note,
        status:            status            ?? this.status,
        submissionDate:    submissionDate    ?? this.submissionDate,
      );
}