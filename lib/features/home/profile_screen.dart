import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/press_scale.dart';
import '../../data/app_settings.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';

// Local tokens so this file compiles without touching AppColors.
const _hairline = Color(0xFFEEEBE5);
const _surface = Colors.white;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().count;
    final cartCount = context.select<CartProvider, int>((c) => c.itemCount);

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
        children: [
          const _Header(),
          const SizedBox(height: 20),
          // The single orchestrated entrance: hero card.
          FadeSlideIn(
            child: _HeroCard(
              onSignIn: () => _comingSoon(context, 'Sign in'),
            ),
          ),
          const SizedBox(height: 14),
          _StatsBar(
            favorites: favorites,
            cartCount: cartCount,
            onFavorites: () => _comingSoon(context, 'Favourites'),
            onCart: () => context.push('/cart'),
          ),
          const SizedBox(height: 28),
          _MenuGroup(
            title: 'Shopping',
            children: [
              _MenuRow(
                icon: Icons.shopping_bag_outlined,
                label: 'My cart',
                trailingText: cartCount > 0 ? '$cartCount' : null,
                onTap: () => context.push('/cart'),
              ),
              _MenuRow(
                icon: Icons.favorite_border_rounded,
                label: 'Saved items',
                trailingText: favorites > 0 ? '$favorites' : null,
                onTap: () => _comingSoon(context, 'Saved items'),
              ),
              _MenuRow(
                icon: Icons.local_shipping_outlined,
                label: 'Orders & tracking',
                onTap: () => _comingSoon(context, 'Orders'),
              ),
              _MenuRow(
                icon: Icons.location_on_outlined,
                label: 'Delivery addresses',
                onTap: () => _comingSoon(context, 'Addresses'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MenuGroup(
            title: 'Preferences',
            children: const [
              _SwitchRow(
                icon: Icons.notifications_none_rounded,
                label: 'Order updates',
                subtitle: 'Delivery and price-drop alerts',
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MenuGroup(
            title: 'Support',
            children: [
              _MenuRow(
                icon: Icons.help_outline_rounded,
                label: 'Help centre',
                onTap: () => _comingSoon(context, 'Help centre'),
              ),
              _MenuRow(
                icon: Icons.info_outline_rounded,
                label: 'About Nook',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Nook',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                  'A furniture marketplace demo built with Flutter.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MenuGroup(
            children: [
              _MenuRow(
                icon: Icons.restart_alt_rounded,
                label: 'Reset app data',
                destructive: true,
                showChevron: false,
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Nook 1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  static void _comingSoon(BuildContext context, String feature) {
    HapticFeedback.selectionClick();
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text('$feature is coming soon'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _confirmReset(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Reset app data?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'This clears your cart and favourites and shows the intro again.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<CartProvider>().clear();
    context.read<FavoritesProvider>().clear();
    await context.read<AppSettings>().setOnboarded(false);
    if (!context.mounted) return;
    context.go('/');
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Profile',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.ink,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero card
// ---------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9BB08B), AppColors.sageDark],
          ),
        ),
        child: Stack(
          children: [
            // Soft depth shapes, kept subtle.
            Positioned(
              right: -40,
              top: -50,
              child: _Orb(size: 170, opacity: 0.10),
            ),
            Positioned(
              right: 50,
              bottom: -70,
              child: _Orb(size: 130, opacity: 0.07),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.55),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Nook',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Furniture that fits your space',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                color: Color(0xD9FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PressScale(
                    onTap: onSignIn,
                    scale: 0.97,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sign in or create account',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.opacity});

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

// ---------------------------------------------------------------------------
// Stats bar (one surface, two tappable segments)
// ---------------------------------------------------------------------------

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.favorites,
    required this.cartCount,
    required this.onFavorites,
    required this.onCart,
  });

  final int favorites;
  final int cartCount;
  final VoidCallback onFavorites;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatSegment(
                icon: Icons.favorite_rounded,
                value: favorites,
                label: 'Favourites',
                onTap: onFavorites,
                radius: const BorderRadius.horizontal(
                  left: Radius.circular(26),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 18,
              endIndent: 18,
              color: _hairline,
            ),
            Expanded(
              child: _StatSegment(
                icon: Icons.shopping_bag_rounded,
                value: cartCount,
                label: 'In cart',
                onTap: onCart,
                radius: const BorderRadius.horizontal(
                  right: Radius.circular(26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatSegment extends StatelessWidget {
  const _StatSegment({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    required this.radius,
  });

  final IconData icon;
  final int value;
  final String label;
  final VoidCallback onTap;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            child: Row(
              children: [
                _IconBadge(icon: icon),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: Text(
                        '$value',
                        key: ValueKey(value),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped menu
// ---------------------------------------------------------------------------

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(const Padding(
          padding: EdgeInsets.only(left: 66),
          child: Divider(height: 1, thickness: 1, color: _hairline),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 10),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Material(
            color: _surface,
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.ink;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _IconBadge(icon: icon, destructive: destructive),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (trailingText != null)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sageDark.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailingText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sageDark,
                    ),
                  ),
                ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatefulWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBadge(icon: widget.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _on,
            activeColor: AppColors.sageDark,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _on = v);
            },
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.destructive = false});

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.sageDark;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}