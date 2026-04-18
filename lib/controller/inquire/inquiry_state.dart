// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_state.dart
// Path: lib/controller/inquiry/inquiry_state.dart
// UPDATED: Migrated to use new salon-specific fields from InquiryModel
// ═══════════════════════════════════════════════════════════════════

import '../../model/inquire/inquire.dart';

abstract class InquiryState {}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiryLoaded extends InquiryState {
  final List<InquiryModel> inquiries;
  final String searchQuery;
  final String? statusFilter;
  final String? userTypeFilter;      // Changed from entityTypeFilter
  final String? countryFilter;       // Changed from locationFilter
  final int? monthFilter;

  InquiryLoaded({
    required this.inquiries,
    this.searchQuery = '',
    this.statusFilter,
    this.userTypeFilter,
    this.countryFilter,
    this.monthFilter,
  });

  List<InquiryModel> get filtered {
    var list = inquiries.toList();

    // ── Status filter ──
    if (statusFilter != null && statusFilter!.isNotEmpty) {
      list = list.where((i) => i.status.label == statusFilter).toList();
    }

    // ── User type filter (client/owner) ──
    if (userTypeFilter != null && userTypeFilter!.isNotEmpty) {
      list = list.where((i) => i.userType == userTypeFilter).toList();
    }

    // ── Country filter ──
    if (countryFilter != null && countryFilter!.isNotEmpty) {
      list = list.where((i) => i.salonCountry == countryFilter).toList();
    }

    // ── Month filter ──
    if (monthFilter != null) {
      list = list.where((i) =>
      i.submissionDate != null && i.submissionDate!.month == monthFilter,
      ).toList();
    }

    // ── Search filter ──
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((i) {
        return i.fullName.toLowerCase().contains(q) ||
            i.email.toLowerCase().contains(q) ||
            i.subject.toLowerCase().contains(q) ||
            i.salonNameEn.toLowerCase().contains(q) ||
            i.salonNameAr.toLowerCase().contains(q) ||
            i.phone.toLowerCase().contains(q) ||
            i.salonCountry.toLowerCase().contains(q) ||
            i.salonCity.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  int get totalCount   => filtered.length;
  int get newCount     => filtered.where((i) => i.status == InquiryStatus.newInquiry).length;
  int get repliedCount => filtered.where((i) => i.status == InquiryStatus.replied).length;
  int get closedCount  => filtered.where((i) => i.status == InquiryStatus.closed).length;

  // ── Unique values for dropdown items ──
  List<String> get uniqueStatuses =>
      inquiries.map((i) => i.status.label).toSet().toList()..sort();

  List<String> get uniqueUserTypes =>
      inquiries.map((i) => i.userType).where((e) => e.isNotEmpty).toSet().toList()..sort();

  List<String> get uniqueCountries =>
      inquiries.map((i) => i.salonCountry).where((e) => e.isNotEmpty).toSet().toList()..sort();

  List<int> get uniqueMonths {
    final months = inquiries
        .where((i) => i.submissionDate != null)
        .map((i) => i.submissionDate!.month)
        .toSet()
        .toList()
      ..sort();
    return months;
  }

  // ── Chart data (uses ALL inquiries, not filtered) ──
  Map<String, int> get userTypeCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.userType.isNotEmpty) map[i.userType] = (map[i.userType] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get targetAudienceCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.targetAudience.isNotEmpty) {
        map[i.targetAudience] = (map[i.targetAudience] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get countryCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.salonCountry.isNotEmpty) {
        map[i.salonCountry] = (map[i.salonCountry] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get cityCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.salonCity.isNotEmpty) {
        map[i.salonCity] = (map[i.salonCity] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<int, int> get monthlySubmissions {
    final map = <int, int>{};
    for (final i in inquiries) {
      if (i.submissionDate != null) {
        map[i.submissionDate!.month] = (map[i.submissionDate!.month] ?? 0) + 1;
      }
    }
    return map;
  }
}

class InquiryDetailLoaded extends InquiryState {
  final InquiryModel inquiry;
  InquiryDetailLoaded(this.inquiry);
}

class InquiryUpdated extends InquiryState {
  final InquiryModel inquiry;
  InquiryUpdated(this.inquiry);
}

class InquiryError extends InquiryState {
  final String message;
  final List<InquiryModel>? lastInquiries;
  InquiryError(this.message, {this.lastInquiries});
}