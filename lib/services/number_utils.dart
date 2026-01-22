String formatNumberShort(num? value) {
  if (value == null) return 'N/A';
  final v = value.toDouble().abs();
  const thousand = 1000.0;
  const million = 1000 * thousand;
  const billion = 1000 * million;
  const trillion = 1000 * billion;

  String sign = value < 0 ? '-' : '';

  if (v >= trillion) {
    return '$sign${(v / trillion).toStringAsFixed(1)}T';
  }
  if (v >= billion) {
    return '$sign${(v / billion).toStringAsFixed(1)}B';
  }
  if (v >= million) {
    return '$sign${(v / million).toStringAsFixed(1)}M';
  }
  if (v >= thousand) {
    return '$sign${(v / thousand).toStringAsFixed(1)}K';
  }

  if (v % 1 == 0) return '$sign${v.toInt()}';
  return '$sign${v.toStringAsFixed(2)}';
}

String formatCurrencyShort(num? value, {String symbol = '\$'}) {
  if (value == null) return 'N/A';
  final formatted = formatNumberShort(value);
  if (formatted == 'N/A') return formatted;
  if (formatted.startsWith('-')) {
    return '-$symbol${formatted.substring(1)}';
  }
  return '$symbol$formatted';
}

