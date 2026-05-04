import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constant/keys.dart';

class TwilioRepository {
  Future<void> sendOTP(String to, String channel, String locale) async {
    // Build credentials
    final credentials =
        '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    // Build URL
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/Verifications',
    );

    // Build headers
    final headers = {
      'Authorization': 'Basic $encodedCredentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    print('\n📋 [TWILIO_REPO] Request Headers:');
    headers.forEach((key, value) {
      print('   - $key: $value');
    });

    // Build body
    final body = {'To': to, 'Channel': channel, 'Locale': locale};
    print('\n📦 [TWILIO_REPO] Request Body:');
    body.forEach((key, value) {
      print('   - $key: $value');
    });

    print('\n📤 [TWILIO_REPO] Sending HTTP POST request...');

    try {
      final response = await http.post(url, headers: headers, body: body);

      response.headers.forEach((key, value) {
        print('     - $key: $value');
      });
      print('   - Response Body:');
      print('${response.body}');

      if (response.statusCode == 201) {
        print('\n✅ [TWILIO_REPO] OTP sent successfully!');

        // Try to parse response for more details
        try {
          final jsonResponse = jsonDecode(response.body);

          jsonResponse.forEach((key, value) {
            print('   - $key: $value');
          });
        } catch (e) {
          print('⚠️ [TWILIO_REPO] Could not parse JSON response: $e');
        }
      } else {
        // Try to parse error response
        try {
          final jsonError = jsonDecode(response.body);
          print('   - Parsed error:');
          jsonError.forEach((key, value) {
            print('     - $key: $value');
          });
        } catch (e) {
          print('   - Could not parse error JSON: $e');
        }

        throw Exception(
          'Twilio API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<bool> verifyOTP(String to, String code) async {
    // Build URL
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/VerificationCheck',
    );

    // Build credentials
    final credentials =
        '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    // Build headers
    final headers = {
      'Authorization': 'Basic $encodedCredentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    headers.forEach((key, value) {
      print('   - $key: $value');
    });

    // Build body
    final body = {'To': to, 'Code': code};
    print('\n📦 [TWILIO_REPO] Request Body:');
    body.forEach((key, value) {
      print('   - $key: $value');
    });

    print('\n📤 [TWILIO_REPO] Sending HTTP POST request...');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('\n📥 [TWILIO_REPO] Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body:');
      print('${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('\n📊 [TWILIO_REPO] Parsed response data:');
        data.forEach((key, value) {
          print('   - $key: $value');
        });

        final status = data['status'] as String?;
        final isApproved = status == 'approved';

        if (isApproved) {
          return true;
        } else {
          return false;
        }
      } else {
        // Try to parse error response
        try {
          final jsonError = jsonDecode(response.body);
          print('   - Parsed error:');
          jsonError.forEach((key, value) {
            print('     - $key: $value');
          });
        } catch (e) {
          print('   - Could not parse error JSON: $e');
        }

        return false;
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
