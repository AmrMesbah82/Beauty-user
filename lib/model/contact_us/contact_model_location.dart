// ******************* FILE INFO *******************
// File Name: contact_model_location.dart
// UPDATED: Complete rewrite to match new Figma design
//          - Headings section (SVG, Title EN/AR, Short Description EN/AR)
//          - Client Description (Description EN/AR, Reasons list with required toggle)
//          - Owner Description (Description EN/AR, Reasons list with required toggle)
//          - Social Media Links (list of dropdown link selections)
//          - Removed old: email, officeLocations, confirmMessage

class ContactBilingualText {
  final String en;
  final String ar;

  const ContactBilingualText({this.en = '', this.ar = ''});

  factory ContactBilingualText.fromJson(Map<String, dynamic> json) =>
      ContactBilingualText(
        en: (json['en'] as String?) ?? '',
        ar: (json['ar'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};

  ContactBilingualText copyWith({String? en, String? ar}) =>
      ContactBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Reason Item (used in Client & Owner Description) ─────────────────────────

class ContactReasonItem {
  final String id;
  final ContactBilingualText label;
  final bool isRequired;

  const ContactReasonItem({
    required this.id,
    this.label = const ContactBilingualText(),
    this.isRequired = false,
  });

  factory ContactReasonItem.fromJson(Map<String, dynamic> json) =>
      ContactReasonItem(
        id:         (json['id'] as String?) ?? '',
        label:      json['label'] != null
            ? ContactBilingualText.fromJson(json['label'] as Map<String, dynamic>)
            : const ContactBilingualText(),
        isRequired: (json['isRequired'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'label':      label.toJson(),
    'isRequired': isRequired,
  };

  ContactReasonItem copyWith({
    String?               id,
    ContactBilingualText? label,
    bool?                 isRequired,
  }) =>
      ContactReasonItem(
        id:         id         ?? this.id,
        label:      label      ?? this.label,
        isRequired: isRequired ?? this.isRequired,
      );
}

// ── Description Section (shared by Client & Owner) ───────────────────────────

class ContactDescriptionSection {
  final ContactBilingualText description;
  final List<ContactReasonItem> reasons;

  const ContactDescriptionSection({
    this.description = const ContactBilingualText(),
    this.reasons     = const [],
  });

  factory ContactDescriptionSection.fromJson(Map<String, dynamic> json) =>
      ContactDescriptionSection(
        description: json['description'] != null
            ? ContactBilingualText.fromJson(json['description'] as Map<String, dynamic>)
            : const ContactBilingualText(),
        reasons: (json['reasons'] as List<dynamic>?)
            ?.map((e) => ContactReasonItem.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
    'description': description.toJson(),
    'reasons':     reasons.map((r) => r.toJson()).toList(),
  };

  ContactDescriptionSection copyWith({
    ContactBilingualText?     description,
    List<ContactReasonItem>?  reasons,
  }) =>
      ContactDescriptionSection(
        description: description ?? this.description,
        reasons:     reasons     ?? this.reasons,
      );
}

// ── Social Link Item ─────────────────────────────────────────────────────────

class ContactSocialIcon {
  final String id;
  final String iconUrl;
  final String link;

  const ContactSocialIcon({
    required this.id,
    this.iconUrl = '',
    this.link    = '',
  });

  factory ContactSocialIcon.fromJson(Map<String, dynamic> json) =>
      ContactSocialIcon(
        id:      (json['id']      as String?) ?? '',
        iconUrl: (json['iconUrl'] as String?) ?? '',
        link:    (json['link']    as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id':      id,
    'iconUrl': iconUrl,
    'link':    link,
  };

  ContactSocialIcon copyWith({String? id, String? iconUrl, String? link}) =>
      ContactSocialIcon(
        id:      id      ?? this.id,
        iconUrl: iconUrl ?? this.iconUrl,
        link:    link    ?? this.link,
      );
}

// ── Headings Section ─────────────────────────────────────────────────────────

class ContactHeadings {
  final String svgUrl;
  final ContactBilingualText title;
  final ContactBilingualText shortDescription;

  const ContactHeadings({
    this.svgUrl           = '',
    this.title            = const ContactBilingualText(),
    this.shortDescription = const ContactBilingualText(),
  });

  factory ContactHeadings.fromJson(Map<String, dynamic> json) =>
      ContactHeadings(
        svgUrl: (json['svgUrl'] as String?) ?? '',
        title: json['title'] != null
            ? ContactBilingualText.fromJson(json['title'] as Map<String, dynamic>)
            : const ContactBilingualText(),
        shortDescription: json['shortDescription'] != null
            ? ContactBilingualText.fromJson(json['shortDescription'] as Map<String, dynamic>)
            : const ContactBilingualText(),
      );

  Map<String, dynamic> toJson() => {
    'svgUrl':           svgUrl,
    'title':            title.toJson(),
    'shortDescription': shortDescription.toJson(),
  };

  ContactHeadings copyWith({
    String?               svgUrl,
    ContactBilingualText? title,
    ContactBilingualText? shortDescription,
  }) =>
      ContactHeadings(
        svgUrl:           svgUrl           ?? this.svgUrl,
        title:            title            ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN CMS MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class ContactUsCmsModel {
  final String publishStatus;
  final ContactHeadings headings;
  final ContactDescriptionSection clientDescription;
  final ContactDescriptionSection ownerDescription;
  final List<ContactSocialIcon> socialIcons;
  final DateTime? lastUpdatedAt;

  const ContactUsCmsModel({
    this.publishStatus      = 'draft',
    this.headings           = const ContactHeadings(),
    this.clientDescription  = const ContactDescriptionSection(),
    this.ownerDescription   = const ContactDescriptionSection(),
    this.socialIcons        = const [],
    this.lastUpdatedAt,
  });

  factory ContactUsCmsModel.fromJson(Map<String, dynamic> json) =>
      ContactUsCmsModel(
        publishStatus: (json['publishStatus'] as String?) ?? 'draft',
        headings: json['headings'] != null
            ? ContactHeadings.fromJson(json['headings'] as Map<String, dynamic>)
            : const ContactHeadings(),
        clientDescription: json['clientDescription'] != null
            ? ContactDescriptionSection.fromJson(json['clientDescription'] as Map<String, dynamic>)
            : const ContactDescriptionSection(),
        ownerDescription: json['ownerDescription'] != null
            ? ContactDescriptionSection.fromJson(json['ownerDescription'] as Map<String, dynamic>)
            : const ContactDescriptionSection(),
        socialIcons: (json['socialIcons'] as List<dynamic>?)
            ?.map((e) => ContactSocialIcon.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
    'publishStatus':     publishStatus,
    'headings':          headings.toJson(),
    'clientDescription': clientDescription.toJson(),
    'ownerDescription':  ownerDescription.toJson(),
    'socialIcons':       socialIcons.map((s) => s.toJson()).toList(),
  };

  ContactUsCmsModel copyWith({
    String?                     publishStatus,
    ContactHeadings?            headings,
    ContactDescriptionSection?  clientDescription,
    ContactDescriptionSection?  ownerDescription,
    List<ContactSocialIcon>?    socialIcons,
    DateTime?                   lastUpdatedAt,
  }) =>
      ContactUsCmsModel(
        publishStatus:     publishStatus     ?? this.publishStatus,
        headings:          headings          ?? this.headings,
        clientDescription: clientDescription ?? this.clientDescription,
        ownerDescription:  ownerDescription  ?? this.ownerDescription,
        socialIcons:       socialIcons       ?? this.socialIcons,
        lastUpdatedAt:     lastUpdatedAt     ?? this.lastUpdatedAt,
      );
}