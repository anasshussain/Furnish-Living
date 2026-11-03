import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/illustrations/product_illustration.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/press_scale.dart';
import '../../data/app_settings.dart';
import '../../data/models/furniture_kind.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Future<void> _explore() async {
    HapticFeedback.lightImpact();
    final settings = context.read<AppSettings>();
    await settings.setOnboarded(true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8CA17D), Color(0xFF5C6F51), Color(0xFF38462F)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _BackdropPainter()),
              ),
              Positioned(
                top: size.height * 0.08,
                left: size.width * 0.04,
                right: -size.width * 0.18,
                height: size.height * 0.56,
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (context, child) {
                    final t = Curves.easeInOut.transform(_float.value);
                    return Transform.translate(
                      offset: Offset(0, t * 14 - 7),
                      child: child,
                    );
                  },
                  child: const ProductIllustration(
                    kind: FurnitureKind.tubChair,
                    color: Color(0xFF2F3B2A),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: size.width * 0.36,
                child: const IgnorePointer(child: _ReedGlass()),
              ),
              Positioned(
                left: 28,
                right: 28,
                bottom: bottomInset + 112,
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 700),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Choose\n',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'furniture ',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: 'that\n',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'fits your space',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.15,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: bottomInset + 28,
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: PressScale(
                        onTap: _explore,
                        scale: 0.97,
                        child: Container(
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(29),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Color(0xFF111111),
                              ),
                            ],
                          ),
                        ),
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

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Offset(size.width * 0.75, size.height * 0.28);
    canvas.drawCircle(
      glow,
      size.width * 0.7,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x44FFFFFF), Color(0x00FFFFFF)],
        ).createShader(Rect.fromCircle(center: glow, radius: size.width * 0.7)),
    );
    final floor = Rect.fromLTWH(0, size.height * 0.62, size.width, size.height);
    canvas.drawRect(
      floor,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x55000000)],
        ).createShader(floor),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReedGlass extends StatelessWidget {
  const _ReedGlass();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 0.5),
        child: const CustomPaint(painter: _ReedPainter()),
      ),
    );
  }
}

class _ReedPainter extends CustomPainter {
  const _ReedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rib = 9.0;
    final count = (size.width / rib).ceil();
    for (var i = 0; i < count; i++) {
      final x = i * rib;
      final fade = 1 - (x / size.width);
      final rect = Rect.fromLTWH(x, 0, rib - 1.5, size.height);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.fromRGBO(255, 255, 255, 0.26 * fade),
              Color.fromRGBO(255, 255, 255, 0.04 * fade),
            ],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
