import 'package:flutter/foundation.dart';

/// Set to true if you want real Luhn checksum validation when adding cards.
/// It is off so any card number can be added while testing the demo.
const bool kEnforceLuhn = false;

enum CardBrand { visa, mastercard, amex, unionpay, other }

String brandName(CardBrand brand) {
  switch (brand) {
    case CardBrand.visa:
      return 'Visa';
    case CardBrand.mastercard:
      return 'Mastercard';
    case CardBrand.amex:
      return 'Amex';
    case CardBrand.unionpay:
      return 'UnionPay';
    case CardBrand.other:
      return 'Card';
  }
}

CardBrand detectBrand(String digits) {
  if (digits.isEmpty) return CardBrand.other;
  if (digits.startsWith('4')) return CardBrand.visa;
  if (digits.startsWith('34') || digits.startsWith('37')) {
    return CardBrand.amex;
  }
  if (digits.startsWith('62')) return CardBrand.unionpay;
  if (digits.length >= 2) {
    final two = int.tryParse(digits.substring(0, 2)) ?? 0;
    if (two >= 51 && two <= 55) return CardBrand.mastercard;
  }
  if (digits.length >= 4) {
    final four = int.tryParse(digits.substring(0, 4)) ?? 0;
    if (four >= 2221 && four <= 2720) return CardBrand.mastercard;
  }
  return CardBrand.other;
}

int maxDigits(CardBrand brand) => brand == CardBrand.amex ? 15 : 16;

int cvvLength(CardBrand brand) => brand == CardBrand.amex ? 4 : 3;

List<int> _groups(CardBrand brand) =>
    brand == CardBrand.amex ? const [4, 6, 5] : const [4, 4, 4, 4];

bool isValidLength(String digits, CardBrand brand) {
  if (brand == CardBrand.amex) return digits.length == 15;
  return digits.length >= 13 && digits.length <= 16;
}

bool passesLuhn(String digits) {
  var sum = 0;
  var alt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  return digits.isNotEmpty && sum % 10 == 0;
}

/// "4242424242424242" -> "4242 4242 4242 4242"
String formatCardNumber(String digits, CardBrand brand) {
  final parts = <String>[];
  var i = 0;
  for (final g in _groups(brand)) {
    if (i >= digits.length) break;
    final end = (i + g) > digits.length ? digits.length : i + g;
    parts.add(digits.substring(i, end));
    i += g;
  }
  return parts.join(' ');
}

/// Live preview text for the card being typed: typed digits + bullet padding.
String previewCardNumber(String digits, CardBrand brand) {
  var i = 0;
  final parts = <String>[];
  for (final g in _groups(brand)) {
    final sb = StringBuffer();
    for (var k = 0; k < g; k++) {
      sb.write(i < digits.length ? digits[i] : '\u2022');
      i++;
    }
    parts.add(sb.toString());
  }
  return parts.join(' ');
}

/// Only safe data is kept: no full number and never the CVV.
@immutable
class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.holder,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
    required this.tone,
  });

  final String id;
  final String holder;
  final String last4;
  final CardBrand brand;
  final int expMonth;
  final int expYear;
  final int tone;

  String get expiry =>
      '${expMonth.toString().padLeft(2, '0')}/${(expYear % 100).toString().padLeft(2, '0')}';

  String get maskedNumber => '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 $last4';
}

/// App-wide in-memory store. Cards live until the app is closed.
/// To persist them, save/load `_cards` (without full numbers) in
/// shared_preferences or secure storage.
class PaymentCardsProvider extends ChangeNotifier {
  PaymentCardsProvider._();

  static final PaymentCardsProvider instance = PaymentCardsProvider._();

  final List<PaymentCard> _cards = [];

  List<PaymentCard> get cards => List.unmodifiable(_cards);

  PaymentCard add({
    required String holder,
    required String digits,
    required int expMonth,
    required int expYear,
    required int tone,
  }) {
    final card = PaymentCard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      holder: holder,
      last4: digits.substring(digits.length - 4),
      brand: detectBrand(digits),
      expMonth: expMonth,
      expYear: expYear,
      tone: tone,
    );
    _cards.add(card);
    notifyListeners();
    return card;
  }

  void remove(String id) {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void clear() {
    _cards.clear();
    notifyListeners();
  }
}