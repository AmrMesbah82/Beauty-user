// ******************* FILE INFO *******************
// File Name: contact_us_cms_repo_impl.dart
// UPDATED: Rewritten for new Contact CMS model
//          - Headings (SVG, Title, Short Description)
//          - Client Description + Owner Description (with Reasons)
//          - Social Media Links
//          - Removed old officeLocations, confirmMessage, email

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/contact_us/contact_model_location.dart';
import 'contact_us_location.dart';

class ContactUsCmsRepoImpl implements ContactUsCmsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage   _storage   = FirebaseStorage.instance;

  static const String _collectionName = 'contact_us_cms';
  static const String _docId          = 'main';

  @override
  Future<ContactUsCmsModel> load() async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_docId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return _defaultModel();
      }

      final model = ContactUsCmsModel.fromJson(doc.data()!);

      // ── Extract Firestore Timestamp ──
      final raw = doc.data()!['lastUpdatedAt'];
      final lastUpdatedAt = raw is Timestamp ? raw.toDate() : null;

      return model.copyWith(lastUpdatedAt: lastUpdatedAt);
    } catch (e) {
      print('❌ ContactUsCmsRepo.load error: $e');
      rethrow;
    }
  }

  @override
  Future<void> save({
    required ContactUsCmsModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    try {
      Map<String, String> uploadedUrls = {};
      if (imageUploads != null && imageUploads.isNotEmpty) {
        uploadedUrls = await _uploadImages(imageUploads);
      }

      final updatedModel = _updateModelWithUrls(model, uploadedUrls);

      final json = updatedModel.toJson();
      json['lastUpdatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(_docId)
          .set(json, SetOptions(merge: true));

      print('✅ ContactUsCmsRepo.save: saved successfully');
    } catch (e) {
      print('❌ ContactUsCmsRepo.save error: $e');
      rethrow;
    }
  }

  // ── Upload images ─────────────────────────────────────────────────────────

  Future<Map<String, String>> _uploadImages(Map<String, Uint8List> uploads) async {
    final Map<String, String> urls = {};

    for (final entry in uploads.entries) {
      final path  = entry.key;
      final bytes = entry.value;

      try {
        final contentType = _detectContentType(bytes);
        final ref      = _storage.ref().child(path);
        final metadata = SettableMetadata(contentType: contentType);

        await ref.putData(bytes, metadata);
        final downloadUrl = await ref.getDownloadURL();

        urls[path] = downloadUrl;
        print('✅ Uploaded: $path → $downloadUrl');
      } catch (e) {
        print('❌ Failed to upload $path: $e');
      }
    }

    return urls;
  }

  // ── Update model with uploaded URLs ───────────────────────────────────────

  ContactUsCmsModel _updateModelWithUrls(
      ContactUsCmsModel model,
      Map<String, String> uploadedUrls,
      ) {
    // Update headings SVG
    String headingSvgUrl = model.headings.svgUrl;
    const headingSvgPath = 'contact_cms/headings/svg';
    if (uploadedUrls.containsKey(headingSvgPath)) {
      headingSvgUrl = uploadedUrls[headingSvgPath]!;
    }

    // Update social icons
    final updatedSocialIcons = model.socialIcons.map((icon) {
      final iconPath = 'contact_cms/social_icons/${icon.id}/icon';
      if (uploadedUrls.containsKey(iconPath)) {
        return icon.copyWith(iconUrl: uploadedUrls[iconPath]!);
      }
      return icon;
    }).toList();

    return model.copyWith(
      headings:    model.headings.copyWith(svgUrl: headingSvgUrl),
      socialIcons: updatedSocialIcons,
    );
  }

  // ── Detect content type ───────────────────────────────────────────────────

  String _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) return 'application/octet-stream';

    if (bytes[0] == 0x89 && bytes[1] == 0x50 &&
        bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    final header = String.fromCharCodes(
        bytes.sublist(0, bytes.length > 100 ? 100 : bytes.length));
    if (header.trim().startsWith('<svg') || header.trim().startsWith('<?xml')) {
      return 'image/svg+xml';
    }

    return 'application/octet-stream';
  }

  // ── Default model ─────────────────────────────────────────────────────────

  ContactUsCmsModel _defaultModel() {
    return ContactUsCmsModel(
      publishStatus: 'draft',
      headings: ContactHeadings(
        svgUrl: '',
        title: ContactBilingualText(en: '', ar: ''),
        shortDescription: ContactBilingualText(en: '', ar: ''),
      ),
      clientDescription: ContactDescriptionSection(
        description: ContactBilingualText(en: '', ar: ''),
        reasons: [
          ContactReasonItem(
            id:         'reason_client_1',
            label:      ContactBilingualText(en: '', ar: ''),
            isRequired: true,
          ),
        ],
      ),
      ownerDescription: ContactDescriptionSection(
        description: ContactBilingualText(en: '', ar: ''),
        reasons: [
          ContactReasonItem(
            id:         'reason_owner_1',
            label:      ContactBilingualText(en: '', ar: ''),
            isRequired: false,
          ),
        ],
      ),
      socialIcons: [
        ContactSocialIcon(id: 'social_1', iconUrl: '', link: ''),
        ContactSocialIcon(id: 'social_2', iconUrl: '', link: ''),
        ContactSocialIcon(id: 'social_3', iconUrl: '', link: ''),
        ContactSocialIcon(id: 'social_4', iconUrl: '', link: ''),
      ],
    );
  }
}