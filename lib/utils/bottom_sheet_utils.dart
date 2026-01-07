import 'package:flutter/material.dart';

/// Utility class for displaying bottom sheets with proper system UI padding
/// to prevent intersection with system navigation buttons
class BottomSheetUtils {
  /// Shows a custom bottom sheet with automatic SafeArea padding
  /// 
  /// [context] - BuildContext
  /// [builder] - Widget builder function for the content
  /// [isScrollable] - Whether the content is scrollable (default: false)
  /// [enableDrag] - Whether the sheet can be dragged (default: true)
  /// [backgroundColor] - Background color (default: from theme)
  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollable = false,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Get bottom padding for system UI (navigation bar, etc.)
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        
        return SafeArea(
          minimum: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 16),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                isScrollable
                    ? Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: builder(context),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: builder(context),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows a scrollable bottom sheet for longer content
  static Future<T?> showScrollableBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showAppBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollable: true,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
    );
  }

  /// Shows a bottom sheet with custom max height
  static Future<T?> showCustomHeightBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    double? maxHeight,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        final calculatedMaxHeight = maxHeight ?? screenHeight * 0.75;
        
        return SafeArea(
          minimum: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: calculatedMaxHeight,
            ),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: builder(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
