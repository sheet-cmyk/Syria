import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';

/// ويدجت صورة مخزّنة مع placeholder وerror builder موحّد.
/// مطلوب في pubspec.yaml: cached_network_image: ^3.3.1
class CachedAdImage extends StatelessWidget {
  /// رابط الصورة - يقبل null أو فاضي
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  /// fallback اختياري: لو الصورة مش موجودة أو فشل تحميلها،
  /// يعرض أيقونة القسم (Category) بدلاً من رمز عام
  final Category? category;

  const CachedAdImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    // لو url فاضي → عرض fallback مباشرة
    if (url == null || url!.trim().isEmpty) {
      return errorWidget ?? _categoryFallback() ?? _defaultError();
    }
    final image = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width != null && width!.isFinite
          ? (width! * MediaQuery.of(context).devicePixelRatio).toInt()
          : null,
      placeholder: (_, __) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (_, __, ___) =>
          errorWidget ?? _categoryFallback() ?? _defaultError(),
      fadeInDuration: const Duration(milliseconds: 200),
    );
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget? _categoryFallback() {
    if (category == null) return null;
    return Container(
      width: width,
      height: height,
      color: category!.color.withOpacity(0.12),
      child: Icon(
        category!.icon,
        color: category!.color,
        size: (height != null && height! < 100) ? 32 : 40,
      ),
    );
  }

  Widget _defaultPlaceholder() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFFD600),
            ),
          ),
        ),
      );

  Widget _defaultError() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey.shade400,
          size: 32,
        ),
      );
}
