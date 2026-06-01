import 'dart:io';
import 'package:flutter/material.dart';

class ResponsiveModal extends StatelessWidget {
  final Widget child;
  final bool isScrollable;

  const ResponsiveModal({
    super.key,
    required this.child,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid || Platform.isIOS
        ? isScrollable
              ? DraggableScrollableSheet(
                  expand: false,
                  maxChildSize:0.9,
                  builder: (_, scrollController) => PrimaryScrollController(
                    controller: scrollController,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                )
              : BottomSheet(
                  onClosing: () {},
                  enableDrag: false,
                  builder: (_) => child,
                  backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                )
        : Dialog(
            constraints: BoxConstraints(maxWidth: 400),
            clipBehavior: Clip.antiAlias,
            child: child,
          );
  }
}

extension ResponsiveModalExtension on BuildContext {
  Future<T?> showResponsiveModal<T>({
    required Widget child,
    bool isScrollable = false,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
      return showModalBottomSheet(
        context: this,
        isScrollControlled: isScrollable,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            ResponsiveModal(isScrollable: isScrollable, child: child),
      );
    } else {
      return showDialog(
        context: this,
        builder: (_) => ResponsiveModal(child: child),
      );
    }
  }
}
