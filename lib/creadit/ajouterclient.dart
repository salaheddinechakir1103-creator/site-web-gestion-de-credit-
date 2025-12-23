import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:math' as math;

/// صفحة إضافة عميل جديد مع تصميم فائق التقدم والمهنية.
/// تشمل خلفية متحركة مع جسيمات متقدمة، رسوم متحركة ثلاثية الأبعاد، وتأثيرات زجاجية فائقة.
class InputScreen extends StatefulWidget {
  final String docoss;
  const InputScreen({super.key, required this.docoss});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with TickerProviderStateMixin {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController creditAmountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late CollectionReference creadit = FirebaseFirestore.instance.collection(
    'creadit',
  );

  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formRotationAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonGlowAnimation;
  late AnimationController _particleController;
  final List<AdvancedParticle> _particles = [];
  late AnimationController _backgroundGlowController;

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Curves.elasticOut,
          ),
        );
    _formRotationAnimation = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeOut),
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _buttonGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeIn),
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _backgroundGlowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // إنشاء جسيمات متقدمة
    for (int i = 0; i < 80; i++) {
      _particles.add(AdvancedParticle.random());
    }

    // بدء الرسوم المتحركة
    Future.delayed(const Duration(milliseconds: 400), () {
      _formAnimationController.forward();
      _buttonAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _particleController.dispose();
    _backgroundGlowController.dispose();
    super.dispose();
  }

  Future<void> addcredit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      await creadit.add({
        'name': clientNameController.text.trim(),
        'credit': double.tryParse(creditAmountController.text.trim()) ?? 0,
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      showErrorDialog();
    }
  }

  void showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'نجاح',
      desc: "تم إضافة العميل بنجاح ✅",
      btnOkOnPress: () {
        if (mounted) Navigator.of(context).pop();
      },
    ).show();
  }

  void showErrorDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'خطأ',
      desc: "تعذر إضافة العميل ❌",
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: const Text(
            'عميل جديد',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 3),
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.deepPurple.shade700.withOpacity(0.9),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // خلفية متحركة مع جسيمات متقدمة وتلألؤ
            AnimatedBuilder(
              animation: Listenable.merge([
                _particleController,
                _backgroundGlowController,
              ]),
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade900.withOpacity(0.95),
                        Colors.grey.shade900.withOpacity(0.9),
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: AdvancedParticlePainter(
                          _particles,
                          _particleController.value,
                        ),
                        size: Size.infinite,
                      ),
                      // تلألؤ خلفي
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5,
                            colors: [
                              Colors.deepPurple.withOpacity(
                                _backgroundGlowController.value * 0.2,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _formFadeAnimation,
                    child: SlideTransition(
                      position: _formSlideAnimation,
                      child: Transform.rotate(
                        angle: _formRotationAnimation.value,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade800.withOpacity(
                                      0.95,
                                    ),
                                    Colors.deepPurple.shade600.withOpacity(0.8),
                                    Colors.deepPurple.shade400.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.4),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    _buildAdvancedInputField(
                                      controller: clientNameController,
                                      label: 'اسم العميل',
                                      icon: Icons.person,
                                      validatorMsg: 'أدخل اسم العميل',
                                    ),
                                    const SizedBox(height: 28),

                                    _buildAdvancedInputField(
                                      controller: creditAmountController,
                                      label: 'مبلغ الرصيد',
                                      icon: Icons.attach_money,
                                      keyboardType: TextInputType.number,
                                      validatorMsg: 'أدخل المبلغ',
                                      customValidator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'أدخل المبلغ';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'مبلغ غير صالح';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 28),

                                    _buildAdvancedInputField(
                                      controller: phoneController,
                                      label: 'رقم الهاتف',
                                      icon: Icons.phone,
                                      keyboardType: TextInputType.phone,
                                      validatorMsg: 'أدخل رقم الهاتف',
                                    ),
                                    const SizedBox(height: 28),

                                    _buildAdvancedInputField(
                                      controller: locationController,
                                      label: 'العنوان / الموقع',
                                      icon: Icons.location_on,
                                      validatorMsg: 'أدخل عنوان العميل',
                                    ),
                                    const SizedBox(height: 40),

                                    // زر الإضافة مع رسوم متحركة فائقة
                                    AnimatedBuilder(
                                      animation: _buttonAnimationController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _buttonScaleAnimation.value,
                                          child: Container(
                                            width: double.infinity,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(35),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.deepPurple.shade700,
                                                  Colors.deepPurple.shade500,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.6),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(
                                                        _buttonGlowAnimation
                                                                .value *
                                                            0.3,
                                                      ),
                                                  blurRadius: 15,
                                                  spreadRadius: 3,
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: addcredit,
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(35),
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                              ),
                                              icon: const Icon(
                                                Icons.person_add_alt_1_rounded,
                                                size: 32,
                                              ),
                                              label: const Text(
                                                'إضافة العميل',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget لتوحيد الحقول مع تحسينات فائقة
  Widget _buildAdvancedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? customValidator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: keyboardType,
        validator:
            customValidator ??
            (value) => (value == null || value.isEmpty) ? validatorMsg : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 18),
          prefixIcon: Icon(icon, color: Colors.white70, size: 28),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 3),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

/// فئة لتمثيل جسيم متحرك متقدم
class AdvancedParticle {
  double x, y, vx, vy, size, angle, rotationSpeed;
  Color color;
  double life;

  AdvancedParticle(
    this.x,
    this.y,
    this.vx,
    this.vy,
    this.size,
    this.color,
    this.angle,
    this.rotationSpeed,
    this.life,
  );

  factory AdvancedParticle.random() {
    final random = math.Random();
    return AdvancedParticle(
      random.nextDouble() * 400,
      random.nextDouble() * 800,
      (random.nextDouble() - 0.5) * 3,
      random.nextDouble() * 2,
      random.nextDouble() * 5 + 2,
      Colors.deepPurple.withOpacity(random.nextDouble() * 0.4 + 0.2),
      random.nextDouble() * math.pi * 2,
      (random.nextDouble() - 0.5) * 0.1,
      random.nextDouble() * 100 + 50,
    );
  }

  void update(double deltaTime) {
    x += vx * deltaTime;
    y += vy * deltaTime;
    angle += rotationSpeed;
    life -= deltaTime;
    if (x < 0 || x > 400) vx = -vx;
    if (y > 800 || life <= 0) {
      y = -size;
      life = math.Random().nextDouble() * 100 + 50;
    }
  }
}

/// رسام الجسيمات المتقدم
class AdvancedParticlePainter extends CustomPainter {
  final List<AdvancedParticle> particles;
  final double animationValue;

  AdvancedParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(1.0);
      final paint = Paint()..color = particle.color;
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.angle);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
