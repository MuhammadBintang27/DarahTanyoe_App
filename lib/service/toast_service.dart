import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

enum ToastPosition { top, bottom, topRight }

class ToastAction {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const ToastAction({
    required this.label,
    required this.onPressed,
    this.color,
  });
}

class ToastService {
  static final Queue<_ToastRequest> _queue = Queue();
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.topRight,
    ToastAction? action,
    bool dismissible = true,
    bool queueable = true,
  }) {
    final request = _ToastRequest(
      context: context,
      message: message,
      title: title,
      type: type,
      duration: duration,
      position: position,
      action: action,
      dismissible: dismissible,
    );

    if (queueable) {
      _queue.add(request);
      _processQueue();
    } else {
      _showToast(request);
    }
  }

  static void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;
    _isShowing = true;
    final request = _queue.removeFirst();
    _showToast(request);
  }

  static void _showToast(_ToastRequest request) {
    final overlay = Overlay.of(request.context, rootOverlay: true);
    if (overlay == null) {
      _isShowing = false;
      _processQueue();
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: request.message,
        title: request.title,
        type: request.type,
        duration: request.duration,
        position: request.position,
        action: request.action,
        dismissible: request.dismissible,
        onDismiss: () {
          try {
            entry.remove();
          } catch (_) {}
          _isShowing = false;
          _processQueue();
        },
      ),
    );
    overlay.insert(entry);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.topRight,
    ToastAction? action,
    bool dismissible = true,
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: ToastType.success,
        duration: duration,
        position: position,
        action: action,
        dismissible: dismissible,
      );

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    ToastPosition position = ToastPosition.topRight,
    ToastAction? action,
    bool dismissible = true,
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: ToastType.error,
        duration: duration,
        position: position,
        action: action,
        dismissible: dismissible,
      );

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.topRight,
    ToastAction? action,
    bool dismissible = true,
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: ToastType.info,
        duration: duration,
        position: position,
        action: action,
        dismissible: dismissible,
      );

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.topRight,
    ToastAction? action,
    bool dismissible = true,
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: ToastType.warning,
        duration: duration,
        position: position,
        action: action,
        dismissible: dismissible,
      );

  static void clearQueue() {
    _queue.clear();
  }
}

class _ToastRequest {
  final BuildContext context;
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;
  final ToastPosition position;
  final ToastAction? action;
  final bool dismissible;

  _ToastRequest({
    required this.context,
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    required this.position,
    this.action,
    required this.dismissible,
  });
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;
  final ToastPosition position;
  final ToastAction? action;
  final bool dismissible;
  final VoidCallback onDismiss;

  const _ToastWidget({
    super.key,
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    required this.position,
    this.action,
    required this.dismissible,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;
  Timer? _timer;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final slideBegin = widget.position == ToastPosition.bottom
        ? const Offset(0, 0.3)
        : widget.position == ToastPosition.topRight
            ? const Offset(1, 0)
            : const Offset(0, -0.3);

    _offset = Tween<Offset>(begin: slideBegin, end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_controller);

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _hide);
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _hide() async {
    if (!_controller.isAnimating && mounted) {
      await _controller.reverse();
      if (mounted) widget.onDismiss();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.dismissible) return;

    setState(() {
      _dragDistance += details.delta.dy;
      if (widget.position == ToastPosition.bottom) {
        _dragDistance = _dragDistance.clamp(0, 100);
      } else {
        _dragDistance = _dragDistance.clamp(-100, 0);
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.dismissible) return;

    if (_dragDistance.abs() > 50) {
      _hide();
    } else {
      setState(() {
        _dragDistance = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFFECFDF5);
      case ToastType.error:
        return const Color(0xFFFEF2F2);
      case ToastType.warning:
        return const Color(0xFFFFFBEB);
      case ToastType.info:
        return const Color(0xFFFFFFFF);
    }
  }

  Color get _borderColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFFA7F3D0);
      case ToastType.error:
        return const Color(0xFFFECACA);
      case ToastType.warning:
        return const Color(0xFFFDE68A);
      case ToastType.info:
        return const Color(0xFFE5E7EB);
    }
  }

  Color get _textColor => const Color(0xFF1F2937);

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF059669);
      case ToastType.error:
        return const Color(0xFFDC2626);
      case ToastType.warning:
        return const Color(0xFFD97706);
      case ToastType.info:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final padding = widget.position == ToastPosition.bottom
        ? EdgeInsets.only(
            bottom: media.viewInsets.bottom + media.padding.bottom + 16)
        : widget.position == ToastPosition.topRight
            ? EdgeInsets.only(top: media.padding.top + 16, right: 16)
            : EdgeInsets.only(top: media.padding.top + 16);

    final alignment = widget.position == ToastPosition.bottom
        ? Alignment.bottomCenter
        : widget.position == ToastPosition.topRight
            ? Alignment.topRight
            : Alignment.topCenter;

    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: alignment,
          child: GestureDetector(
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            onTap: widget.dismissible ? _hide : null,
            child: MouseRegion(
              onEnter: (_) => _pauseTimer(),
              onExit: (_) => _startTimer(),
              child: SlideTransition(
                position: _offset,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Transform.translate(
                    offset: Offset(0, _dragDistance),
                    child: Container(
                      margin: padding,
                      padding: widget.position == ToastPosition.topRight
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                            constraints: BoxConstraints(
                              maxWidth: widget.position == ToastPosition.topRight ? 360 : 540,
                            ),
                          decoration: BoxDecoration(
                            color: _bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(_icon, color: _iconColor, size: 22),
                                const SizedBox(width: 12),
                                Flexible(
                                  fit: widget.position == ToastPosition.topRight 
                                      ? FlexFit.loose 
                                      : FlexFit.tight,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.title != null &&
                                          widget.title!.isNotEmpty) ...[
                                        Text(
                                          widget.title!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Text(
                                        widget.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: _textColor,
                                          height: 1.5,
                                        ),
                                      ),
                                      if (widget.action != null) ...[
                                        const SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () {
                                            widget.action!.onPressed();
                                            _hide();
                                          },
                                          child: Text(
                                            widget.action!.label,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: widget.action!.color ??
                                                  _iconColor,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (widget.dismissible && widget.position != ToastPosition.topRight) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _hide,
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: _textColor.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}