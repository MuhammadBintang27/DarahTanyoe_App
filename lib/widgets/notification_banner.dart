import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/main.dart';

class NotificationBanner extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            onDismiss?.call();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // App icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.brand_01.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: AppTheme.brand_01,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Overlay helper untuk show/hide banner
class NotificationBannerOverlay {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String title,
    required String body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Dismiss existing banner if any
    dismiss();

    _isShowing = true;

    // Use root overlay context if available
    BuildContext? overlayContext;
    try {
      overlayContext = MyApp.navigatorKey.currentState?.overlay?.context;
    } catch (_) {}
    overlayContext ??= context;

    // Create overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, offset, child) {
            return Transform.translate(
              offset: Offset(0, offset.dy * 100),
              child: child,
            );
          },
          child: NotificationBanner(
            title: title,
            body: body,
            onTap: onTap,
            onDismiss: dismiss,
          ),
        ),
      ),
    );

    // Add to overlay
    final overlay = MyApp.navigatorKey.currentState?.overlay;
    if (overlay != null) {
      overlay.insert(_currentOverlay!);
    }

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (_isShowing) {
        dismiss();
      }
    });
  }

  static void dismiss() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
    }
  }
}
