part of '../../pages/contact_us_page.dart';

class _OtpDialog extends StatefulWidget {
  final String phoneNumber;
  final bool isRtl;
  final Color primaryColor;
  final VoidCallback onVerified;
  const _OtpDialog({
    required this.phoneNumber,
    required this.isRtl,
    required this.primaryColor,
    required this.onVerified,
  });
  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final List<TextEditingController> _digitCtrls = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _hasError = false;
  int _countdown = 30;
  bool _canResend = false;
  StreamSubscription? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .take(30)
        .listen((_) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digitCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _digitCtrls.map((c) => c.text).join();

  void _verifyOtp() {
    setState(() => _hasError = false);
    final code = _otpCode.trim();
    if (code.length < 6) return;
    context.read<ContactOtpCubit>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      code: code,
    );
  }

  void _resendOtp() {
    for (final c in _digitCtrls) c.clear();
    setState(() => _hasError = false);
    _startTimer();
    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: widget.phoneNumber,
      locale: widget.isRtl ? 'ar' : 'en',
    );
  }

  void _onDigitChanged(String value, int index) {
    setState(() => _hasError = false);
    if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.length == 1 && index == 5 && _otpCode.length == 6) _verifyOtp();
  }

  void _onDigitKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitCtrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')} Sec';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    return Directionality(
      textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<ContactOtpCubit, ContactOtpState>(
        listener: (context, state) {
          if (state is OtpVerified) widget.onVerified();
          if (state is OtpError) setState(() => _hasError = true);
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 36.w,
            vertical: isMobile ? 40 : 36.h,
          ),
          child: SizedBox(
            width: isMobile ? double.infinity : 480.w,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32.w,
                vertical: isMobile ? 28 : 32.h,
              ),
              child: BlocBuilder<ContactOtpCubit, ContactOtpState>(
                builder: (context, state) {
                  final isVerifying = state is OtpVerifying;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/mobile_code_dialog.svg',
                        width: isMobile ? 120 : 140.w,
                        height: isMobile ? 100 : 120.h,
                      ),
                      SizedBox(height: isMobile ? 20 : 24.h),
                      Text(
                        widget.isRtl ? 'رمز التحقق' : 'VERIFICATION CODE',
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize22Weight700.copyWith(
                          fontSize: isMobile ? 18.0 : 20.sp,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 10.h),
                      Text(
                        widget.isRtl
                            ? 'لقد أرسلنا رمز التحقق إلى هاتفك لإتمام عملية التحقق'
                            : 'We have sent the OTP code to your Phone For the verification process',
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize13Weight400.copyWith(
                          fontSize: isMobile ? 12.0 : 13.sp,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 28.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            final bool filled = _digitCtrls[i].text.isNotEmpty;
                            return Container(
                              width: isMobile ? 44 : 48.w,
                              height: isMobile ? 50 : 54.h,
                              margin: EdgeInsets.symmetric(
                                horizontal: isMobile ? 3 : 4.w,
                              ),
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) => _onDigitKey(i, e),
                                child: TextField(
                                  controller: _digitCtrls[i],
                                  focusNode: _focusNodes[i],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: StyleText.fontSize22Weight700.copyWith(
                                    fontSize: isMobile ? 18.0 : 20.sp,
                                    color: _hasError
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: _hasError
                                        ? Colors.red.withOpacity(0.05)
                                        : filled
                                        ? widget.primaryColor.withOpacity(0.05)
                                        : Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 12 : 14.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : filled
                                            ? widget.primaryColor
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : widget.primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) => _onDigitChanged(v, i),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: isMobile ? 14 : 16.h),
                      if (_hasError)
                        Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 8 : 10.h),
                          child: Text(
                            widget.isRtl
                                ? 'رمز غير صحيح، يرجى التحقق والمحاولة مرة أخرى'
                                : 'Incorrect code, please check and try again',
                            textAlign: TextAlign.center,
                            style: StyleText.fontSize12Weight400.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (!_canResend)
                        Text(
                          _formatTime(_countdown),
                          style: StyleText.fontSize13Weight400.copyWith(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      SizedBox(height: isMobile ? 18 : 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 46 : 44.h,
                        child: ElevatedButton(
                          onPressed: _canResend
                              ? _resendOtp
                              : (isVerifying ? null : _verifyOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            disabledBackgroundColor: widget.primaryColor
                                .withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: _canResend
                              ? Text(
                            widget.isRtl
                                ? 'إعادة إرسال الرمز'
                                : 'Resend Code',
                            style: StyleText.fontSize16Weight600.copyWith(
                              color: Colors.white,
                            ),
                          )
                              : isVerifying
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : Text(
                            widget.isRtl ? 'تحقق الآن' : 'Verify Now',
                            style: StyleText.fontSize16Weight600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUCCESS DIALOG
// ═══════════════════════════════════════════════════════════════════════════════
