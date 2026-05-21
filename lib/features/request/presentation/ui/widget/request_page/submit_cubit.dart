part of '../../pages/request_page.dart';

class _SubmitCubit extends Cubit<_SubmitState> {
  _SubmitCubit() : super(_SubmitInitial());

  Future<void> submit({
    required String salonName,
    required String country,
    required String city,
    required String noBranches,
    required String noEmployees,
    required String firstName,
    required String lastName,
    required String phoneCode,
    required String phoneNumber,
    required String email,
    required Map<String, dynamic> dynamicAnswers,
    required String gender,
  }) async {
    emit(_SubmitLoading());
    try {
      final col = FirebaseFirestore.instance.collection('requestDemo');
      final doc = col.doc();
      await doc.set({
        'salonName':            salonName,
        'country':              country,
        'city':                 city,
        'noBranches':           noBranches,
        'noEmployees':          noEmployees,
        'firstName':            firstName,
        'lastName':             lastName,
        'countryCode':          phoneCode,
        'phone':                phoneNumber,
        'email':                email,
        'entityType':           gender,
        'status':               'New',
        'submissionDate':       FieldValue.serverTimestamp(),
        'primaryReason':        '',
        'howDidYouHearAboutUs': '',
        'note':                 '',
        'questionAnswers':      dynamicAnswers,
      });
      emit(_SubmitSuccess());
    } catch (e) {
      emit(_SubmitError(e.toString()));
    }
  }

  void reset() => emit(_SubmitInitial());
}

// ════════════════════════════════════════════════════════════════════════════
// PALETTE — fallback only, real colors come from HomeCmsCubit
// ════════════════════════════════════════════════════════════════════════════
