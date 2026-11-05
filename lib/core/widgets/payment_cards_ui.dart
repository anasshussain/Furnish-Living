import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/payment_cards.dart';
import '../theme/app_colors.dart';
import 'press_scale.dart';

const kCardPalettes = <List<Color>>[
  [Color(0xFF24493B), Color(0xFF0F211A)],
  [Color(0xFF9BB08B), Color(0xFF5E7350)],
  [Color(0xFF34343A), Color(0xFF111114)],
  [Color(0xFFCFAE74), Color(0xFF8A6A33)],
  [Color(0xFF5B4B8A), Color(0xFF2A2145)],
];

class PaymentCardView extends StatelessWidget {
  const PaymentCardView({
    super.key,
    required this.numberText,
    required this.holder,
    required this.expiry,
    required this.brand,
    required this.tone,
    this.onRemove,
  });

  final String numberText;
  final String holder;
  final String expiry;
  final CardBrand brand;
  final int tone;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = kCardPalettes[tone % kCardPalettes.length];
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -60,
                child: _Circle(size: 200, opacity: 0.08),
              ),
              Positioned(
                left: -50,
                bottom: -100,
                child: _Circle(size: 200, opacity: 0.06),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const _Chip(),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.nfc_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 22,
                        ),
                        const Spacer(),
                        if (onRemove != null)
                          Semantics(
                            button: true,
                            label: 'Remove card',
                            child: GestureDetector(
                              onTap: onRemove,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.18),
                                ),
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          numberText,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MiniLabel('Card holder'),
                              const SizedBox(height: 2),
                              Text(
                                holder.isEmpty
                                    ? 'YOUR NAME'
                                    : holder.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MiniLabel('Expires'),
                            const SizedBox(height: 2),
                            Text(
                              expiry.isEmpty ? 'MM/YY' : expiry,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        _BrandMark(brand: brand),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 31,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1D68E), Color(0xFFC49A45)],
        ),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x66000000), width: 1),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.brand});

  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    switch (brand) {
      case CardBrand.mastercard:
        return SizedBox(
          width: 44,
          height: 28,
          child: Stack(
            children: const [
              Positioned(left: 0, child: _Dot(Color(0xFFEB001B))),
              Positioned(right: 0, child: _Dot(Color(0xCCF79E1B))),
            ],
          ),
        );
      case CardBrand.visa:
        return const Text(
          'VISA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        );
      case CardBrand.amex:
        return const Text(
          'AMEX',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.white,
          ),
        );
      case CardBrand.unionpay:
        return const Text(
          'UnionPay',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        );
      case CardBrand.other:
        return Icon(
          Icons.credit_card_rounded,
          color: Colors.white.withOpacity(0.75),
        );
    }
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

Future<PaymentCard?> showAddCardSheet(BuildContext context) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<PaymentCard>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const _AddCardSheet(),
  );
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  late int _tone =
      PaymentCardsProvider.instance.cards.length % kCardPalettes.length;
  bool _submitted = false;

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');
  CardBrand get _brand => detectBrand(_digits);

  @override
  void initState() {
    super.initState();
    for (final c in [_number, _name, _expiry, _cvv]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final c in [_number, _name, _expiry, _cvv]) {
      c.removeListener(_refresh);
      c.dispose();
    }
    super.dispose();
  }

  String? get _numberError {
    if (!_submitted) return null;
    if (!isValidLength(_digits, _brand)) return 'Enter a valid card number';
    if (kEnforceLuhn && !passesLuhn(_digits)) {
      return 'This card number is not valid';
    }
    return null;
  }

  String? get _nameError {
    if (!_submitted) return null;
    return _name.text.trim().length < 2 ? 'Enter the name on the card' : null;
  }

  String? get _expiryError {
    if (!_submitted) return null;
    final t = _expiry.text;
    if (t.length != 5) return 'Use MM/YY';
    final m = int.tryParse(t.substring(0, 2));
    final y = int.tryParse(t.substring(3, 5));
    if (m == null || y == null || m < 1 || m > 12) return 'Invalid month';
    final endOfMonth = DateTime(2000 + y, m + 1);
    if (!endOfMonth.isAfter(DateTime.now())) return 'Card has expired';
    return null;
  }

  String? get _cvvError {
    if (!_submitted) return null;
    final n = cvvLength(_brand);
    return _cvv.text.length != n ? 'Enter $n digits' : null;
  }

  void _save() {
    setState(() => _submitted = true);
    final hasError = [_numberError, _nameError, _expiryError, _cvvError]
        .any((e) => e != null);
    if (hasError) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    final parts = _expiry.text.split('/');
    final card = PaymentCardsProvider.instance.add(
      holder: _name.text.trim(),
      digits: _digits,
      expMonth: int.parse(parts[0]),
      expYear: 2000 + int.parse(parts[1]),
      tone: _tone,
    );
    Navigator.of(context).pop(card);
  }

  @override
  Widget build(BuildContext context) {
    final brand = _brand;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add a card',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: PaymentCardView(
                  numberText: previewCardNumber(_digits, brand),
                  holder: _name.text.trim(),
                  expiry: _expiry.text,
                  brand: brand,
                  tone: _tone,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Card colour',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(width: 14),
                for (var i = 0; i < kCardPalettes.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _Swatch(
                      colors: kCardPalettes[i],
                      selected: _tone == i,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tone = i);
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _LabeledField(
              label: 'Card number',
              controller: _number,
              hint: '1234 5678 9012 3456',
              keyboardType: TextInputType.number,
              formatters: [_CardNumberFormatter()],
              errorText: _numberError,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Name on card',
              controller: _name,
              hint: 'As printed on the card',
              keyboardType: TextInputType.name,
              capitalization: TextCapitalization.words,
              errorText: _nameError,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Expiry',
                    controller: _expiry,
                    hint: 'MM/YY',
                    keyboardType: TextInputType.number,
                    formatters: [_ExpiryFormatter()],
                    errorText: _expiryError,
                    action: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'CVV',
                    controller: _cvv,
                    hint: brand == CardBrand.amex ? '4 digits' : '3 digits',
                    keyboardType: TextInputType.number,
                    obscure: true,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(cvvLength(brand)),
                    ],
                    errorText: _cvvError,
                    action: TextInputAction.done,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Only the last 4 digits are kept on this device. '
                        'Your full number and CVV are never saved.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PressScale(
              onTap: _save,
              scale: 0.97,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Text(
                  'Save card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.ink : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.formatters,
    this.errorText,
    this.obscure = false,
    this.capitalization = TextCapitalization.none,
    this.action = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? errorText;
  final bool obscure;
  final TextCapitalization capitalization;
  final TextInputAction action;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: width == 0
              ? BorderSide.none
              : BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          obscureText: obscure,
          textCapitalization: capitalization,
          textInputAction: action,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w400,
            ),
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: border(Colors.transparent),
            enabledBorder: border(Colors.transparent),
            focusedBorder: border(AppColors.sageDark, 1.5),
            errorBorder: border(AppColors.danger, 1.2),
            focusedErrorBorder: border(AppColors.danger, 1.5),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final brand = detectBrand(digits);
    final max = maxDigits(brand);
    if (digits.length > max) digits = digits.substring(0, max);
    final text = formatCardNumber(digits, brand);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length == 1 && int.parse(digits) > 1) digits = '0$digits';
    final growing = newValue.text.length > oldValue.text.length;
    String text;
    if (digits.length > 2) {
      text = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2 && growing) {
      text = '$digits/';
    } else {
      text = digits;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}