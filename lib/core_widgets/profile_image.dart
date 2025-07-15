import 'package:flutter/material.dart';
// Keep Lottie if you intend to use Lottie assets for generic placeholders

// --- Locally Defined UI Constants/Placeholders ---
// These replace any imports from 'constants/colors.dart' or 'utils/assets.dart'
const Color grey = Colors.grey;
const Color black = Colors.black; // Adding black if it's used elsewhere for consistency
const Color white = Colors.white; // Adding white if it's used elsewhere for consistency

// Dummy Assets class with generic placeholder paths.
// Ensure these paths point to actual, generic assets if you want them to display.
class Assets {
  static const String image_loader = 'assets/lottie/generic_loader.json'; // Use a generic Lottie loader if you have one
  static const String user_filled = 'assets/icons/generic_user_icon.svg'; // Use a generic user SVG icon
}

// Dummy/Placeholder for SvgImage.
// If you don't have a generic SVG rendering library you want to keep,
// you might replace this with a simple Icon or Image.asset.
class SvgImage extends StatelessWidget {
  final String image; // This will now refer to a static, generic asset path
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;

  const SvgImage({super.key, required this.image, this.width, this.height, this.color, this.fit});

  @override
  Widget build(BuildContext context) {
    // In a fully stripped app, you would replace actual SVG rendering
    // with a placeholder, unless `flutter_svg` is a core UI dependency
    // you choose to keep and you have generic SVGs.
    // For maximal stripping, we'll use a basic Icon as a fallback.
    return Icon(
      Icons.person, // A generic person icon
      size: (width ?? 24).clamp(16, 64), // Scale icon size appropriately
      color: color ?? Colors.grey, // Use the provided color or a default grey
    );
    // If you do keep `flutter_svg` and have a generic SVG:
    // return SvgPicture.asset(
    //   image, // This `image` should now point to a generic SVG, e.g., Assets.user_filled
    //   width: width,
    //   height: height,
    //   colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    //   fit: fit ?? BoxFit.contain,
    // );
  }
}

// OnlineImage widget is now completely removed as it implies network fetching (business data).
// Any usage of ProfileImage will now directly use static icons or assets.

class ProfileImage extends StatelessWidget {
  // The 'image' parameter is now purely decorative or for compatibility,
  // as no dynamic image fetching based on it will occur.
  // We're displaying a static placeholder regardless.
  final String? image; // This parameter is effectively ignored now
  final double box_size;
  final double image_size;

  const ProfileImage({
    super.key,
    this.image, // Made optional, as it's no longer used for dynamic loading
    required this.box_size,
    required this.image_size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: box_size,
      height: box_size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      // Replaced OnlineImage with a static, generic placeholder.
      // This ensures no network calls or reliance on business-specific image URLs.
      child: SvgImage(
        // Always use a generic user icon, ignore the 'image' parameter
        image: Assets.user_filled,
        width: image_size,
        height: image_size,
        color: grey.withOpacity(0.65),
      ),
      // If you want a Lottie loader as the *main* content, you could use:
      // child: Lottie.asset(Assets.image_loader, height: image_size, width: image_size),
      // Or simply a static Flutter Icon:
      // child: Icon(Icons.person, size: image_size * 0.8, color: grey.withOpacity(0.65)),
    );
  }
}