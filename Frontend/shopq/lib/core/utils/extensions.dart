extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
}

extension DoubleExtensions on double {
  String get asCurrency => '₹${toStringAsFixed(0)}';

  int discountFrom(double original) {
    if (original <= 0) return 0;
    return (((original - this) / original) * 100).round();
  }
}

extension NullableStringExtensions on String? {
  String get orEmpty => this ?? '';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
