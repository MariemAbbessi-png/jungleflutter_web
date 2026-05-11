import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'chat.dart';

class FintechApp extends StatelessWidget {
  const FintechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wealth Driven — Fintech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFF0D2414),
      ),
      home: const pagep(),
    );
  }
}

class AppColors {
  static const bg        = Color(0xFF0D2414);
  static const bgMid     = Color(0xFF1A3D22);
  static const bgLight   = Color(0xFF2A5F1A);
  static const green1    = Color(0xFF62AA32);
  static const green2    = Color(0xFF4A8522);
  static const green3    = Color(0xFF3A7C18);
  static const accent    = Color(0xFF7BC94A);
  static const textLight = Color(0xFFE8F5D0);
  static const textMuted = Color(0xFFB4D888);
  static const billDark  = Color(0xFF2E6C14);
  static const billMid   = Color(0xFF3D8818);
  static const billBright= Color(0xFF5CB830);
  static const gold      = Color(0xFFC8A832);
}

class pagep extends StatefulWidget {
  const pagep({super.key});

  @override
  State<pagep> createState() => _pagepState();
}

class _pagepState extends State<pagep>
    with TickerProviderStateMixin {
  late AnimationController _billCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _smokeCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _billCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _billCtrl.dispose();
    _glowCtrl.dispose();
    _smokeCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Stack(
          children: [
            _buildBackground(),
            _buildWaves(),
            _buildGlowOrbs(),
            _buildSmoke(),
            _buildFloatingBills(),
            _buildBankCard(),
            _buildNavbar(),
            _buildHeroContent(),
            _buildDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D2414),
            Color(0xFF1A3D22),
            Color(0xFF0F2E18),
            Color(0xFF0A1F10),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildWaves() {
    return Positioned.fill(
      child: CustomPaint(painter: WavePainter()),
    );
  }

  Widget _buildGlowOrbs() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        final t = _glowCtrl.value;
        return Stack(
          children: [
            Positioned(
              right: -60 + t * 20,
              top: 80 + t * 30,
              child: _glowOrb(280, AppColors.green1, 0.18 + t * 0.07),
            ),
            Positioned(
              left: 80,
              bottom: -20 + t * 20,
              child: _glowOrb(200, AppColors.bgMid, 0.25 + t * 0.08),
            ),
          ],
        );
      },
    );
  }

  Widget _glowOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: size * 0.6,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildSmoke() {
    return AnimatedBuilder(
      animation: _smokeCtrl,
      builder: (_, __) => Positioned(
        right: 120,
        top: 100,
        child: CustomPaint(
          size: const Size(100, 180),
          painter: SmokePainter(_smokeCtrl.value),
        ),
      ),
    );
  }

  Widget _buildFloatingBills() {
    return AnimatedBuilder(
      animation: _billCtrl,
      builder: (_, __) {
        final t = _billCtrl.value;
        return Stack(
          children: [
            Positioned(
              right: 100,
              bottom: 80 + t * 14,
              child: Transform.rotate(
                angle: -0.14 + t * 0.05,
                child: const BillWidget(
                  width: 200, height: 92, denomination: '100',
                  color1: Color(0xFF4A9C25), color2: Color(0xFF2A5C10),
                ),
              ),
            ),
            Positioned(
              right: 240,
              top: 100 + t * -10,
              child: Transform.rotate(
                angle: 0.21 - t * 0.05,
                child: const BillWidget(
                  width: 160, height: 74, denomination: '50',
                  color1: Color(0xFF3D8818), color2: Color(0xFF52A824),
                ),
              ),
            ),
            Positioned(
              right: 50,
              top: 60 + t * -18,
              child: Transform.rotate(
                angle: -0.31 + t * 0.06,
                child: const BillWidget(
                  width: 124, height: 58, denomination: '20',
                  color1: Color(0xFF5CB830), color2: Color(0xFF3D8818),
                ),
              ),
            ),
            Positioned(
              left: 320,
              top: 140 + t * 12,
              child: Transform.rotate(
                angle: 0.09 - t * 0.04,
                child: const BillWidget(
                  width: 100, height: 46, denomination: '10',
                  color1: Color(0xFF4AAA28), color2: Color(0xFF2E6C14),
                ),
              ),
            ),
            Positioned(
              right: 320,
              top: 55 + t * -8,
              child: Transform.rotate(
                angle: -0.44 + t * 0.05,
                child: const BillWidget(
                  width: 85, height: 40, denomination: '5',
                  color1: Color(0xFF62B835), color2: Color(0xFF40841E),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBankCard() {
    return Positioned(
      right: 60,
      bottom: 70,
      child: const BankCardWidget(),
    );
  }

  Widget _buildNavbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.5), width: 1.5),
                color: AppColors.green1.withOpacity(0.1),
              ),
            child: Center(
            child: Container(
  width: 50,
  height: 50,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: AppColors.accent.withOpacity(0.5),
      width: 1.5,
    ),
    image: const DecorationImage(
      image: AssetImage('images/logo.jpeg'),
      fit: BoxFit.cover,
    ),
  ),
),
          ),
                      ),
            const SizedBox(width: 36),
            ...[
              "page d'accueil", 'Junglebot'
            ].map((label) => Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: GestureDetector(
  onTap: () {
    if (label == "page d'accueil") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FintechApp()),
      );
    } else if (label == "Junglebot") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const chat()),
      );
    }
  },
  child: Text(label.toUpperCase()),
),
                )),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green1, AppColors.green2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green1.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text('Se connecter',
                  style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroContent() {
    return Positioned(
      left: 48,
      top: 110,
      child: SizedBox(
        width: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jungle · cashback',
                style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text('BIENVENUE \n CHEZ \n ESPACE ADMIN',
                style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.5)),
            const SizedBox(height: 16),
            Text(
              '',
              style: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.7,
                  letterSpacing: 0.2),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _primaryButton('Se connecter', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginUI()),
                );
              }),
                const SizedBox(width: 12),
                
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.green1, AppColors.green2],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(color: AppColors.textLight)),
    ),
  );
}

  Widget _outlineButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.green1.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              color: AppColors.textMuted.withOpacity(0.75),
              fontSize: 13,
              letterSpacing: 0.4)),
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _billCtrl,
      builder: (_, __) {
        final t = _billCtrl.value;
        final dots = [
          {'right': 170.0, 'top': 85.0, 'size': 8.0},
          {'right': 290.0, 'top': 125.0, 'size': 5.0},
          {'right': 130.0, 'bottom': 190.0, 'size': 6.0},
          {'left': 360.0, 'top': 178.0, 'size': 4.0},
        ];
        return Stack(
          children: dots.asMap().entries.map((e) {
            final d = e.value;
            final phase = e.key * 0.4;
            final pulse =
                0.4 + 0.4 * math.sin((t + phase) * math.pi * 2);
            return Positioned(
              right: d['right'],
              left: d['left'],
              top: d['top'],
              bottom: d['bottom'],
              child: Container(
                width: d['size'],
                height: d['size'],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(pulse),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green1.withOpacity(pulse * 0.7),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final p1 = Path();
    p1.moveTo(w * 0.55, 0);
    p1.cubicTo(w * 0.7, h * 0.15, w * 0.85, h * 0.12, w, h * 0.3);
    p1.cubicTo(w, h * 0.5, w, h * 0.62, w, h * 0.75);
    p1.cubicTo(w * 0.92, h, w * 0.82, h, w * 0.72, h);
    p1.lineTo(w, h);
    p1.lineTo(w, 0);
    p1.close();
    canvas.drawPath(
        p1,
        Paint()
          ..color = const Color(0xFF1A3D22).withOpacity(0.55)
          ..style = PaintingStyle.fill);

    final p2 = Path();
    p2.moveTo(w * 0.46, 0);
    p2.cubicTo(w * 0.6, h * 0.18, w * 0.78, h * 0.15, w * 0.84, h * 0.36);
    p2.cubicTo(w * 0.9, h * 0.58, w * 0.88, h * 0.74, w, h * 0.82);
    p2.lineTo(w, 0);
    p2.close();
    canvas.drawPath(
        p2,
        Paint()
          ..color = const Color(0xFF0F2E18).withOpacity(0.38)
          ..style = PaintingStyle.fill);

    final p3 = Path();
    p3.moveTo(w * 0.62, 0);
    p3.cubicTo(w * 0.72, h * 0.11, w * 0.8, h * 0.2, w * 0.85, h * 0.34);
    p3.cubicTo(w * 0.9, h * 0.48, w * 0.92, h * 0.62, w, h * 0.7);
    p3.lineTo(w, 0);
    p3.close();
    canvas.drawPath(
        p3,
        Paint()
          ..color = const Color(0xFF2A6E1A).withOpacity(0.28)
          ..style = PaintingStyle.fill);

    final linePaint = Paint()
      ..color = const Color(0xFF64C83C).withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final line1 = Path();
    line1.moveTo(w * 0.5, 0);
    line1.cubicTo(w * 0.6, h * 0.22, w * 0.67, h * 0.15, w * 0.73, h * 0.36);
    line1.cubicTo(w * 0.79, h * 0.58, w * 0.84, h * 0.72, w, h * 0.79);
    canvas.drawPath(line1, linePaint);

    final linePaint2 = Paint()
      ..color = const Color(0xFF50B428).withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final line2 = Path();
    line2.moveTo(w * 0.52, 0);
    line2.cubicTo(w * 0.63, h * 0.24, w * 0.69, h * 0.16, w * 0.75, h * 0.38);
    line2.cubicTo(w * 0.81, h * 0.6, w * 0.86, h * 0.73, w, h * 0.81);
    canvas.drawPath(line2, linePaint2);

    final p4 = Path();
    p4.moveTo(0, h * 0.72);
    p4.cubicTo(w * 0.09, h * 0.65, w * 0.16, h * 0.76, w * 0.22, h * 0.68);
    p4.cubicTo(w * 0.29, h * 0.6, w * 0.31, h * 0.76, w * 0.38, h * 0.72);
    p4.cubicTo(w * 0.44, h * 0.68, w * 0.44, h * 0.86, w * 0.33, h * 0.93);
    p4.cubicTo(w * 0.22, h, 0, h, 0, h);
    p4.close();
    canvas.drawPath(
        p4,
        Paint()
          ..color = const Color(0xFF152B16).withOpacity(0.45)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

class SmokePainter extends CustomPainter {
  final double progress;
  SmokePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;

    void drawWisp(double xBase, double opacity, double phase) {
      final p = Paint()
        ..color = const Color(0xFFA0DC64).withOpacity(opacity * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final yOff = -t * 60;
      final xWave = math.sin((t + phase) * math.pi * 2) * 8;
      path.moveTo(xBase + xWave, size.height + yOff);
      path.cubicTo(
        xBase - 10 + xWave, size.height * 0.65 + yOff,
        xBase + 14 + xWave, size.height * 0.4 + yOff,
        xBase + xWave * 1.2, size.height * 0.1 + yOff,
      );
      canvas.drawPath(path, p);
    }

    drawWisp(40, 0.35, 0.0);
    drawWisp(62, 0.25, 0.5);
  }

  @override
  bool shouldRepaint(SmokePainter old) => old.progress != progress;
}

class BillWidget extends StatelessWidget {
  final double width;
  final double height;
  final String denomination;
  final Color color1;
  final Color color2;

  const BillWidget({
    super.key,
    required this.width,
    required this.height,
    required this.denomination,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFA0E65A).withOpacity(0.22),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.5),
        child: CustomPaint(
          painter: BillPainter(denomination),
        ),
      ),
    );
  }
}

class BillPainter extends CustomPainter {
  final String denomination;
  BillPainter(this.denomination);

  @override
  void paint(Canvas canvas, Size s) {
    final textColor = const Color(0xFFC8F08A).withOpacity(0.85);
    final borderPaint = Paint()
      ..color = const Color(0xFF90D060).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 6, s.width - 12, s.height - 12),
        const Radius.circular(2));
    canvas.drawRRect(rrect, borderPaint);

    final ovalPaint = Paint()
      ..color = const Color(0xFF3C8C1E).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * 0.5, s.height * 0.5),
            width: s.width * 0.22,
            height: s.height * 0.7),
        ovalPaint);

    final wavePaint = Paint()
      ..color = const Color(0xFF78C83C).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    void drawWave(double y) {
      final path = Path();
      path.moveTo(s.width * 0.1, y);
      for (double x = s.width * 0.1; x < s.width * 0.9; x += 12) {
        path.quadraticBezierTo(x + 6, y - 4, x + 12, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    drawWave(s.height * 0.32);
    drawWave(s.height * 0.68);


    final tp1 = TextPainter(
      text: TextSpan(
          text: denomination,
          style: TextStyle(
              color: textColor,
              fontSize: s.height * 0.28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, Offset(s.width * 0.08, s.height * 0.35));


    final tp2 = TextPainter(
      text: TextSpan(
          text: denomination,
          style: TextStyle(
              color: textColor,
              fontSize: s.height * 0.28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(
        canvas, Offset(s.width * 0.92 - tp2.width, s.height * 0.35));

    final tp3 = TextPainter(
      text: TextSpan(
          text: 'cashback',
          style: TextStyle(
              color: const Color(0xFF90C860).withOpacity(0.45),
              fontSize: s.height * 0.12,
              letterSpacing: 1.2,
              fontFamily: 'Georgia')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp3.paint(canvas,
        Offset((s.width - tp3.width) / 2, s.height * 0.78));
  }

  @override
  bool shouldRepaint(_) => false;
}

class BankCardWidget extends StatelessWidget {
  const BankCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 145,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A5F1A),
            Color(0xFF1C4412),
            Color(0xFF0F2A08),
          ],
          stops: [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF78C846).withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 50,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: const Color(0xFF50A028).withOpacity(0.12),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            
            Positioned(
              left: -30,
              top: 0,
              bottom: 0,
              width: 120,
              child: Transform(
                transform: Matrix4.skewX(-0.26),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFB4F078).withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, Color(0xFFA08520)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: const Color(0xFFDCB43C).withOpacity(0.4),
                              width: 0.5),
                        ),
                        child: CustomPaint(painter: ChipPainter()),
                      ),
                      CustomPaint(
                        size: const Size(18, 18),
                        painter: ContactlessPainter(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '•••• •••• •••• 4782',
                    style: TextStyle(
                        color: AppColors.textMuted.withOpacity(0.8),
                        fontSize: 13.5,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Courier'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('10% cashback',
                              style: TextStyle(
                                  color:
                                      const Color(0xFF78B446).withOpacity(0.45),
                                  fontSize: 8,
                                  letterSpacing: 1.2)),
                          const Text('Jungle carte',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE8A020),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-9, 0),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFD03020).withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0xFFB48C30).withOpacity(0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, s.height / 2), Offset(s.width, s.height / 2), p);
    canvas.drawLine(Offset(s.width / 2, 0), Offset(s.width / 2, s.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class ContactlessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0xFFA3D278).withOpacity(0.5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void arc(double r) {
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(s.width * 0.3, s.height * 0.55),
              width: r * 2,
              height: r * 2),
          -math.pi * 0.75,
          math.pi * 0.5,
          false,
          p);
    }

    arc(4); arc(7); arc(10);

    canvas.drawCircle(
        Offset(s.width * 0.3, s.height * 0.55),
        1.5,
        Paint()..color = const Color(0xFFA3D278).withOpacity(0.5));
  }

  @override
  bool shouldRepaint(_) => false;
  
}