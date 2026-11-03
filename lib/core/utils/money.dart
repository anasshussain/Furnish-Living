/// Formats an amount in cents as a dollar string, e.g. 5750 -> "$57.50".
///
/// All prices in the app are stored as integer cents so totals never suffer
/// from floating point rounding errors.
String formatCents(int cents) {
  final negative = cents < 0;
  final abs = cents.abs();
  final dollars = abs ~/ 100;
  final remainder = abs % 100;
  final digits = dollars.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  final sign = negative ? '-' : '';
  return '$sign\$${buffer.toString()}.${remainder.toString().padLeft(2, '0')}';
}
