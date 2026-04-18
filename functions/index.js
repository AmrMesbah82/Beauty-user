const {setGlobalOptions} = require("firebase-functions");
const {onCall} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const sgMail = require("@sendgrid/mail");

setGlobalOptions({maxInstances: 10});

// ── Secrets ─────────────────────────────────────────────
const SENDGRID_API_KEY = defineSecret("SENDGRID_API_KEY");
const TWILIO_ACCOUNT_SID = defineSecret("TWILIO_ACCOUNT_SID");
const TWILIO_AUTH_TOKEN = defineSecret("TWILIO_AUTH_TOKEN");
const TWILIO_VERIFY_SID = defineSecret("TWILIO_VERIFY_SERVICE_SID");

// ═════════════════════════════════════════════════════════
// 1) sendContactEmail
// ═════════════════════════════════════════════════════════
exports.sendContactEmail = onCall(
    {secrets: [SENDGRID_API_KEY]},
    async (request) => {
      const {
        toEmail,
        submitterName,
        submitterEmail,
        submitterPhone,
        subject,
        message,
        isArabic,
      } = request.data;

      console.log("📧 [sendContactEmail] Called with:", {
        toEmail,
        submitterName,
        submitterEmail,
        submitterPhone,
        subject,
        isArabic,
      });

      if (!toEmail || !submitterName ||
        !submitterEmail || !subject || !message) {
        console.error(
            "❌ [sendContactEmail] Missing required fields",
        );
        throw new Error("Missing required fields");
      }

      sgMail.setApiKey(SENDGRID_API_KEY.value());

      const dir = isArabic ? "rtl" : "ltr";
      const fontFam = isArabic ?
        "'Segoe UI', Tahoma, Arial, sans-serif" :
        "'Segoe UI', Arial, sans-serif";

      const labels = isArabic ?
        {
          title: "رسالة تواصل جديدة",
          name: "الاسم",
          email: "البريد الإلكتروني",
          phone: "رقم الهاتف",
          subject: "الموضوع",
          message: "الرسالة",
          footer:
            "تم الإرسال من نموذج التواصل على الموقع الإلكتروني",
        } :
        {
          title: "New Contact Form Submission",
          name: "Name",
          email: "Email",
          phone: "Phone",
          subject: "Subject",
          message: "Message",
          footer: "Sent from the website contact form",
        };

      const html = `
<!DOCTYPE html>
<html lang="${isArabic ? "ar" : "en"}" dir="${dir}">
<head>
<meta charset="UTF-8"/>
<meta name="viewport"
  content="width=device-width, initial-scale=1.0"/>
<title>${labels.title}</title>
</head>
<body style="margin:0;padding:0;background:#F5F5F5;
  font-family:${fontFam};direction:${dir};">

<table width="100%" cellpadding="0" cellspacing="0"
  style="background:#F5F5F5;padding:40px 0;">
<tr>
<td align="center">
<table width="600" cellpadding="0" cellspacing="0"
  style="background:#FFFFFF;border-radius:12px;
  overflow:hidden;
  box-shadow:0 2px 12px rgba(0,0,0,0.08);
  max-width:600px;width:100%;">

<!-- HEADER -->
<tr>
<td style="background:#BE6A7A;padding:32px 40px;
  text-align:center;">
<h1 style="margin:0;color:#FFFFFF;font-size:22px;
  font-weight:600;letter-spacing:0.5px;">
${labels.title}
</h1>
</td>
</tr>

<!-- BODY -->
<tr>
<td style="padding:36px 40px;">

<!-- Name -->
<table width="100%" cellpadding="0" cellspacing="0"
  style="margin-bottom:16px;border-radius:8px;
  background:#FDF2F4;overflow:hidden;">
<tr>
<td style="padding:14px 18px;
  border-left:4px solid #BE6A7A;">
<p style="margin:0 0 4px;font-size:11px;
  font-weight:600;color:#BE6A7A;
  text-transform:uppercase;
  letter-spacing:0.8px;">
${labels.name}
</p>
<p style="margin:0;font-size:15px;
  color:#1A1A1A;font-weight:500;">
${submitterName}
</p>
</td>
</tr>
</table>

<!-- Email -->
<table width="100%" cellpadding="0" cellspacing="0"
  style="margin-bottom:16px;border-radius:8px;
  background:#FDF2F4;overflow:hidden;">
<tr>
<td style="padding:14px 18px;
  border-left:4px solid #BE6A7A;">
<p style="margin:0 0 4px;font-size:11px;
  font-weight:600;color:#BE6A7A;
  text-transform:uppercase;
  letter-spacing:0.8px;">
${labels.email}
</p>
<p style="margin:0;font-size:15px;
  color:#1A1A1A;font-weight:500;">
<a href="mailto:${submitterEmail}"
  style="color:#BE6A7A;text-decoration:none;">
${submitterEmail}
</a>
</p>
</td>
</tr>
</table>

<!-- Phone -->
<table width="100%" cellpadding="0" cellspacing="0"
  style="margin-bottom:16px;border-radius:8px;
  background:#FDF2F4;overflow:hidden;">
<tr>
<td style="padding:14px 18px;
  border-left:4px solid #BE6A7A;">
<p style="margin:0 0 4px;font-size:11px;
  font-weight:600;color:#BE6A7A;
  text-transform:uppercase;
  letter-spacing:0.8px;">
${labels.phone}
</p>
<p style="margin:0;font-size:15px;
  color:#1A1A1A;font-weight:500;">
${submitterPhone}
</p>
</td>
</tr>
</table>

<!-- Subject -->
<table width="100%" cellpadding="0" cellspacing="0"
  style="margin-bottom:16px;border-radius:8px;
  background:#FDF2F4;overflow:hidden;">
<tr>
<td style="padding:14px 18px;
  border-left:4px solid #BE6A7A;">
<p style="margin:0 0 4px;font-size:11px;
  font-weight:600;color:#BE6A7A;
  text-transform:uppercase;
  letter-spacing:0.8px;">
${labels.subject}
</p>
<p style="margin:0;font-size:15px;
  color:#1A1A1A;font-weight:500;">
${subject}
</p>
</td>
</tr>
</table>

<!-- Message -->
<table width="100%" cellpadding="0" cellspacing="0"
  style="margin-bottom:8px;border-radius:8px;
  background:#FDF2F4;overflow:hidden;">
<tr>
<td style="padding:14px 18px;
  border-left:4px solid #BE6A7A;">
<p style="margin:0 0 8px;font-size:11px;
  font-weight:600;color:#BE6A7A;
  text-transform:uppercase;
  letter-spacing:0.8px;">
${labels.message}
</p>
<p style="margin:0;font-size:15px;color:#1A1A1A;
  line-height:1.7;white-space:pre-wrap;">
${message}
</p>
</td>
</tr>
</table>

</td>
</tr>

<!-- FOOTER -->
<tr>
<td style="background:#F9F0F2;padding:20px 40px;
  text-align:center;border-top:1px solid #F0D9DE;">
<p style="margin:0;font-size:12px;color:#999999;">
${labels.footer}
</p>
</td>
</tr>

</table>
</td>
</tr>
</table>

</body>
</html>`;

      const msg = {
        to: toEmail,
        from: "a.mesbah@bayanatz.com",
        replyTo: submitterEmail,
        subject: `${labels.title}: ${subject}`,
        html,
      };

      try {
        await sgMail.send(msg);
        console.log(
            "✅ [sendContactEmail] Email sent to:", toEmail,
        );
        return {success: true};
      } catch (error) {
        console.error(
            "❌ [sendContactEmail] SendGrid error:", error,
        );
        if (error.response) {
          console.error(
              "❌ SendGrid response body:",
              error.response.body,
          );
        }
        throw new Error(
            "Failed to send email: " + error.message,
        );
      }
    },
);

// ═════════════════════════════════════════════════════════
// 2) sendOTP  –  Twilio Verify → send verification code
// ═════════════════════════════════════════════════════════
exports.sendOTP = onCall(
    {
      secrets: [
        TWILIO_ACCOUNT_SID,
        TWILIO_AUTH_TOKEN,
        TWILIO_VERIFY_SID,
      ],
    },
    async (request) => {
      const {to, channel, locale} = request.data;

      console.log("📞 [sendOTP] Called with:", {
        to, channel, locale,
      });

      if (!to || !channel) {
        throw new Error("Missing required fields: to, channel");
      }

      const accountSid = TWILIO_ACCOUNT_SID.value();
      const authToken = TWILIO_AUTH_TOKEN.value();
      const serviceSid = TWILIO_VERIFY_SID.value();

      const client = require("twilio")(accountSid, authToken);

      try {
        const verification = await client.verify.v2
            .services(serviceSid)
            .verifications.create({
              to: to,
              channel: channel,
              locale: locale || "en",
            });

        console.log(
            "✅ [sendOTP] Verification sent, SID:",
            verification.sid,
        );
        console.log(
            "✅ [sendOTP] Status:", verification.status,
        );

        return {
          success: true,
          status: verification.status,
        };
      } catch (error) {
        console.error("❌ [sendOTP] Error:", error.message);
        throw new Error(
            "Failed to send OTP: " + error.message,
        );
      }
    },
);

// ═════════════════════════════════════════════════════════
// 3) verifyOTP  –  Twilio Verify → check verification code
// ═════════════════════════════════════════════════════════
exports.verifyOTP = onCall(
    {
      secrets: [
        TWILIO_ACCOUNT_SID,
        TWILIO_AUTH_TOKEN,
        TWILIO_VERIFY_SID,
      ],
    },
    async (request) => {
      const {to, code} = request.data;

      console.log("🔍 [verifyOTP] Called with:", {to, code});

      if (!to || !code) {
        throw new Error("Missing required fields: to, code");
      }

      const accountSid = TWILIO_ACCOUNT_SID.value();
      const authToken = TWILIO_AUTH_TOKEN.value();
      const serviceSid = TWILIO_VERIFY_SID.value();

      const client = require("twilio")(accountSid, authToken);

      try {
        const check = await client.verify.v2
            .services(serviceSid)
            .verificationChecks.create({
              to: to,
              code: code,
            });

        console.log(
            "🔍 [verifyOTP] Status:", check.status,
        );

        const approved = check.status === "approved";

        return {
          success: approved,
          status: check.status,
        };
      } catch (error) {
        console.error(
            "❌ [verifyOTP] Error:", error.message,
        );
        throw new Error(
            "Failed to verify OTP: " + error.message,
        );
      }
    },
);
