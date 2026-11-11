import 'package:flutter/material.dart';

/// Outdoor-friendly high-contrast container with visible 1.2px borders.
class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leadingIcon;
  final Widget? trailingAction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingAction,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Row(
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(
                            180,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingAction != null) trailingAction!,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
        ],
        child,
      ],
    );

    final cardWidget = Card(
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(padding: padding, child: cardContent),
      ),
    );

    if (title != null) {
      return Semantics(
        container: true,
        header: true,
        label: subtitle != null ? '$title: $subtitle' : title!,
        child: cardWidget,
      );
    }
    return cardWidget;
  }
}
