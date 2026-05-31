part of '../../pages/overview_page.dart';

class _TestimonialsSection extends StatefulWidget {
  final Color primaryColor;
  final String sectionTitle;
  final List<OverviewClientCommentModel> comments;
  final bool isAr;
  final Color backgroundColor; // ← ADD


  const _TestimonialsSection({
    required this.primaryColor,
    required this.sectionTitle,
    required this.comments,
    required this.isAr,
    required this.backgroundColor, // ← ADD


  });

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  int _currentPage = 0;

  int _cardsPerPage(bool isWide) => isWide ? 2 : 1;

  int _totalPages(bool isWide) {
    final perPage = _cardsPerPage(isWide);
    return (widget.comments.length / perPage).ceil();
  }

  void _next(bool isWide) {
    if (_currentPage < _totalPages(isWide) - 1) {
      setState(() => _currentPage++);
    }
  }

  void _prev(bool isWide) {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  Widget _buildTitle() {
    final title = widget.sectionTitle;
    final highlightWord = widget.isAr ? 'عملائنا' : 'Clients';

    final idx = title.toLowerCase().indexOf(highlightWord.toLowerCase());
    if (idx == -1) {
      return Text(
        FormatHelper.capitalize(title),
        style: AppTextStyles.font23BlackSemiBoldCairo.copyWith(
          color: AppColors.secondaryBlack,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      );
    }

    final before = title.substring(0, idx);
    final keyword = title.substring(idx, idx + highlightWord.length);
    final after = title.substring(idx + highlightWord.length);

    return Text.rich(
      TextSpan(
        style: AppTextStyles.font23BlackSemiBoldCairo.copyWith(
          color: AppColors.secondaryBlack,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: keyword,
            style: TextStyle(color: widget.primaryColor),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final perPage = _cardsPerPage(isWide);
        final totalPages = _totalPages(isWide);

        final startIdx = _currentPage * perPage;
        final endIdx =
        (startIdx + perPage).clamp(0, widget.comments.length);
        final visibleComments = widget.comments.sublist(startIdx, endIdx);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Title & Arrows
              SizedBox(
                width: 220.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16.h),
                    _buildTitle(),
                    SizedBox(height: 28.h),
                    SizedBox(
                      height: 60.h,
                      child: Row(
                        children: [
                          _ArrowBtn(
                            onTap: _currentPage > 0
                                ? () => _prev(true)
                                : null,
                            icon: Icons.arrow_back,
                            filled: false,
                            primaryColor: widget.primaryColor,
                          ),
                          SizedBox(width: 12.w),
                          _ArrowBtn(
                            onTap: _currentPage < totalPages - 1
                                ? () => _next(true)
                                : null,
                            icon: Icons.arrow_forward,
                            filled: true,
                            primaryColor: widget.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              // Right side - Cards with equal height
              Expanded(
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: visibleComments
                        .map((comment) => Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 8.w),
                        child: _TestimonialCard(
                          comment: comment,
                          backgroundColor: widget.backgroundColor,
                          primaryColor: widget.primaryColor,
                          isAr: widget.isAr,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        }

        // Mobile layout
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: 20.h),
            ...visibleComments.map((comment) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _TestimonialCard(
                comment: comment,
                backgroundColor: widget.backgroundColor, // ← ADD
                primaryColor: widget.primaryColor,
                isAr: widget.isAr,
              ),
            )),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ArrowBtn(
                  onTap: _currentPage > 0 ? () => _prev(false) : null,
                  icon: Icons.arrow_back,
                  filled: false,
                  primaryColor: widget.primaryColor,
                ),
                SizedBox(width: 12.w),
                _ArrowBtn(
                  onTap: _currentPage < totalPages - 1
                      ? () => _next(false)
                      : null,
                  icon: Icons.arrow_forward,
                  filled: true,
                  primaryColor: widget.primaryColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
