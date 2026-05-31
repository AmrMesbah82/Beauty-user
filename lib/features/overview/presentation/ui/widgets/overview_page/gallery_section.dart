part of '../../pages/overview_page.dart';

class _GallerySection extends StatefulWidget {
  final Color primaryColor;
  final String title;
  final List<OverviewGalleryImageModel> images;
  final Color backgroundColor; // ← ADD


  const _GallerySection({
    required this.primaryColor,
    required this.title,
    required this.images,
    required this.backgroundColor, // ← ADD

  });

  @override
  State<_GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<_GallerySection> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.images.length >= 3) _activeIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    // ✅ half-size on mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final double inactiveSize = isMobile ? 110.w : 200.w;
    final double activeSize = isMobile ? 160.w : 284.w;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(.8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FormatHelper.capitalize(widget.title),
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: widget.primaryColor,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 24.h),

          SizedBox(
            height: activeSize + 16.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final bool isActive = _activeIndex == i;
                  final double size = isActive ? activeSize : inactiveSize;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeIndex = i),
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                          color: widget.backgroundColor, // ← was: backgroundColor
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        width: size,
                        height: size,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: _netImg(
                            url: widget.images[i].imageUrl,
                            width: size,
                            height: size,
                            fit: BoxFit.scaleDown,
                            placeholder: Container(
                              color: widget.primaryColor.withOpacity(0.12),
                              child: Icon(
                                Icons.image_outlined,
                                color: widget.primaryColor.withOpacity(0.4),
                                size: 36.sp,
                              ),
                            ),
                            errorWidget: Container(
                              color: widget.primaryColor.withOpacity(0.08),
                              child: Icon(Icons.broken_image_outlined,
                                  color:
                                  widget.primaryColor.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final bool active = _activeIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _activeIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 24.w : 8.w,
                  height: 8.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: active
                        ? widget.primaryColor
                        : widget.primaryColor.withOpacity(0.3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — CLIENT TESTIMONIALS
// ══════════════════════════════════════════════════════════════════════════════
