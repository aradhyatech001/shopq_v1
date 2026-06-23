class Helpers {
  static String formatDeliveryTime(String input) {
    input = input.replaceAll(' ', '');
    final match = RegExp(r'^(\d+)([a-zA-Z]+)').firstMatch(input);
    if (match != null) {
      final number = match.group(1) ?? '';
      final unit = match.group(2)?.substring(0, 3).toUpperCase() ?? '';
      return '$number $unit';
    } else {
      return input.substring(0, input.length.clamp(0, 6)).toUpperCase();
    }
  }

  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String formatPrice(double price) => '₹${price.toStringAsFixed(0)}';

  static int calculateDiscount(double price, double sellingPrice) {
    if (price <= 0) return 0;
    return (((price - sellingPrice) / price) * 100).round();
  }
}
