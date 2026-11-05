import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/illustrations/product_illustration.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/payment_cards_ui.dart';
import '../../core/widgets/press_scale.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../providers/cart_provider.dart';
import '../../providers/payment_cards.dart';

enum _PayMethod { card, cod }

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final PageController _pager = PageController(viewportFraction: 0.88);
  late _PayMethod _method = PaymentCardsProvider.instance.cards.isEmpty
      ? _PayMethod.cod
      : _PayMethod.card;
  int _page = 0;
  int _cardIndex = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  PaymentCard? _selectedCard(List<PaymentCard> cards) {
    if (_method != _PayMethod.card || cards.isEmpty) return null;
    return cards[_cardIndex.clamp(0, cards.length - 1)];
  }

  Future<void> _addCard() async {
    final card = await showAddCardSheet(context);
    if (card == null || !mounted) return;
    final cards = PaymentCardsProvider.instance.cards;
    setState(() {
      _method = _PayMethod.card;
      _cardIndex = cards.length - 1;
      _page = _cardIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pager.hasClients) {
        _pager.animateToPage(
          _cardIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _confirmRemove(PaymentCard card) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Remove this card?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          '${brandName(card.brand)} ending in ${card.last4} will be removed from this device.',
          style: const TextStyle(color: AppColors.muted, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    PaymentCardsProvider.instance.remove(card.id);
    setState(() {
      _cardIndex = 0;
      _page = 0;
    });
    if (_pager.hasClients) _pager.jumpToPage(0);
  }

  Future<void> _placeOrder(PaymentCard? card) async {
    if (_method == _PayMethod.card && card == null) {
      await _addCard();
      return;
    }
    HapticFeedback.mediumImpact();
    final label = card == null
        ? 'Cash on delivery'
        : '${brandName(card.brand)} \u2022\u2022\u2022\u2022 ${card.last4}';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _OrderPlacedDialog(paymentLabel: label),
    );
    if (!mounted) return;
    context.read<CartProvider>().clear();
    context.go('/home');
  }

  void _removeWithUndo(CartItem item) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.remove(item.key);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text('${item.product.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cartProvider.add(
              item.product,
              item.colorIndex,
              quantity: item.quantity,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: PaymentCardsProvider.instance,
          builder: (context, _) {
            final cards = PaymentCardsProvider.instance.cards;
            final selected = _selectedCard(cards);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onTap: _back,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'My cart',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.7,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (items.isNotEmpty)
                        Text(
                          '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    message:
                    'Add a few pieces you love and they will show up here.',
                    actionLabel: 'Start shopping',
                    onAction: () => context.go('/home'),
                  )
                      : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      _DeliveryProgress(cart: cart),
                      const SizedBox(height: 16),
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(item.key),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _removeWithUndo(item),
                            child: _CartTile(item: item),
                          ),
                        ),
                      const SizedBox(height: 14),
                      const _SectionTitle('Payment method'),
                      const SizedBox(height: 12),
                      _MethodToggle(
                        method: _method,
                        onChanged: (m) {
                          HapticFeedback.selectionClick();
                          setState(() => _method = m);
                        },
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _method == _PayMethod.card
                            ? _buildCarousel(cards)
                            : const _CodNote(key: ValueKey('cod')),
                      ),
                      const SizedBox(height: 26),
                      const _SectionTitle('Order summary'),
                      const SizedBox(height: 12),
                      _SummaryCard(cart: cart),
                    ],
                  ),
                ),
                if (items.isNotEmpty)
                  _CheckoutBar(
                    totalCents: cart.totalCents,
                    label: (_method == _PayMethod.card && selected == null)
                        ? 'Add a card'
                        : 'Place order',
                    onTap: () => _placeOrder(selected),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarousel(List<PaymentCard> cards) {
    return LayoutBuilder(
      key: const ValueKey('cards'),
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth * 0.88;
        final height = (pageWidth - 12) / 1.586 + 16;
        final pages = cards.length + 1;
        return Column(
          children: [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _pager,
                clipBehavior: Clip.none,
                padEnds: false,
                itemCount: pages,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _page = i;
                    if (i < cards.length) _cardIndex = i;
                  });
                },
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 16),
                    child: i < cards.length
                        ? AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: i == _cardIndex ? 1 : 0.65,
                      child: PaymentCardView(
                        numberText: cards[i].maskedNumber,
                        holder: cards[i].holder,
                        expiry: cards[i].expiry,
                        brand: cards[i].brand,
                        tone: cards[i].tone,
                        onRemove: () => _confirmRemove(cards[i]),
                      ),
                    )
                        : _AddCardTile(onTap: _addCard),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.ink : AppColors.line,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  const _DeliveryProgress({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final free = cart.deliveryCents == 0;
    final remaining = kFreeDeliveryThresholdCents - cart.subtotalCents;
    final progress =
    (cart.subtotalCents / kFreeDeliveryThresholdCents).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (free ? AppColors.success : AppColors.sageDark)
                      .withOpacity(0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  free
                      ? Icons.check_circle_outline_rounded
                      : Icons.local_shipping_outlined,
                  size: 19,
                  color: free ? AppColors.success : AppColors.sageDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  free
                      ? 'You unlocked free delivery'
                      : 'Add ${formatCents(remaining)} more for free delivery',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(
                  free ? AppColors.success : AppColors.sageDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ProductIllustration(
              kind: item.product.kind,
              color: item.color.color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x1F000000)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.color.name}  |  ${formatCents(item.product.priceCents)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    QuantityStepper(
                      compact: true,
                      value: item.quantity,
                      canDecrement: item.quantity > 1,
                      canIncrement: item.quantity < kMaxQuantity,
                      onDecrement: () =>
                          cart.setQuantity(item.key, item.quantity - 1),
                      onIncrement: () =>
                          cart.setQuantity(item.key, item.quantity + 1),
                    ),
                    const Spacer(),
                    Text(
                      formatCents(item.totalCents),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment widgets
// ---------------------------------------------------------------------------

class _MethodToggle extends StatelessWidget {
  const _MethodToggle({required this.method, required this.onChanged});

  final _PayMethod method;
  final ValueChanged<_PayMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleSegment(
              icon: Icons.credit_card_rounded,
              label: 'Card',
              selected: method == _PayMethod.card,
              onTap: () => onChanged(_PayMethod.card),
            ),
          ),
          Expanded(
            child: _ToggleSegment(
              icon: Icons.payments_outlined,
              label: 'Cash on delivery',
              selected: method == _PayMethod.cod,
              onTap: () => onChanged(_PayMethod.cod),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppColors.muted,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  const _AddCardTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a new card',
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1.586,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.line, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.sageDark.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: AppColors.sageDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add a new card',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Visa, Mastercard and more',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodNote extends StatelessWidget {
  const _CodNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.sageDark.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 20,
              color: AppColors.sageDark,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Pay in cash when your order arrives. '
                  'Please keep the exact amount ready.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary + checkout
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final free = cart.deliveryCents == 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: formatCents(cart.subtotalCents),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Delivery',
            value: free ? 'Free' : formatCents(cart.deliveryCents),
            valueColor: free ? AppColors.success : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.line),
          ),
          _SummaryRow(
            label: 'Total',
            value: formatCents(cart.totalCents),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 18 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: bold ? AppColors.ink : AppColors.muted,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ?? AppColors.ink,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.totalCents,
    required this.label,
    required this.onTap,
  });

  final int totalCents;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCents(totalCents),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: PressScale(
                  onTap: onTap,
                  scale: 0.97,
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order placed dialog
// ---------------------------------------------------------------------------

class _OrderPlacedDialog extends StatelessWidget {
  const _OrderPlacedDialog({required this.paymentLabel});

  final String paymentLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 46,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Order placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sageDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.credit_card_rounded,
                    size: 16,
                    color: AppColors.sageDark,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      paymentLabel,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sageDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thank you for shopping with Nook. This is a demo, so no payment was taken.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Continue shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}