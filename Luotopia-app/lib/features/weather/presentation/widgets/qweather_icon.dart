import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QWeatherIcon extends StatelessWidget {
  const QWeatherIcon({
    super.key,
    required this.code,
    required this.size,
    this.color,
  });

  static const _assetRoot = 'assets/qweather_icons/icons';
  static const _fallbackCode = '999';

  final String? code;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color;
    final colorFilter = effectiveColor == null
        ? null
        : ColorFilter.mode(effectiveColor, BlendMode.srcIn);
    final fallback = SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        '$_assetRoot/$_fallbackCode.svg',
        width: size,
        height: size,
        colorFilter: colorFilter,
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        '$_assetRoot/${_normalizedCode(code)}.svg',
        width: size,
        height: size,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => SizedBox.square(dimension: size),
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

String _normalizedCode(String? code) {
  final trimmed = code?.trim();
  if (trimmed == null || trimmed.isEmpty) return QWeatherIcon._fallbackCode;
  return RegExp(r'^\d+$').hasMatch(trimmed)
      ? trimmed
      : QWeatherIcon._fallbackCode;
}
