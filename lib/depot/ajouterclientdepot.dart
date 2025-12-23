import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'dart:math' as math;

/// صفحة إضافة عميل جديد للإيداع مع تصميم فائق التقدم والمهنية.
/// تشمل خلفية متحركة مع جسيمات متقدمة، رسوم متحركة ثلاثية الأبعاد، وتأثيرات زجاجية فائقة.
class InputScreendepot extends StatefulWidget {
  final String docoss;
  const InputScreendepot({
    super.key,
    required this.docoss,
    required String lang,
  });

  @override
  State<InputScreendepot> createState() => _InputScreendepotState();
}

class _InputScreendepotState extends State<InputScreendepot>
    with TickerProviderStateMixin {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late CollectionReference depotsCollection = FirebaseFirestore.instance
      .collection('depot');

  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formRotationAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonGlowAnimation;
  late AnimationController _locationButtonAnimationController;
  late Animation<double> _locationButtonScaleAnimation;
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

    _locationButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _locationButtonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _locationButtonAnimationController,
        curve: Curves.elasticOut,
      ),
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
      _locationButtonAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _locationButtonAnimationController.dispose();
    _particleController.dispose();
    _backgroundGlowController.dispose();
    super.dispose();
  }

  // Récupérer la position GPS
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "خطأ",
        desc: "خدمة الموقع غير متوفرة",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    locationController.text =
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  Future<void> addClient() async {
    if (!formKey.currentState!.validate()) return;

    double amount = double.tryParse(amountController.text.trim()) ?? 0;

    try {
      await depotsCollection.add({
        'name': clientNameController.text.trim(),
        'depot': amount,
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
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'نجاح',
      desc: "تمت إضافة العميل بنجاح ✅",
      btnOkOnPress: () {
        if (mounted) Navigator.of(context).pop();
      },
    ).show();
  }

  void showErrorDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'خطأ',
      desc: "حدث خطأ أثناء إضافة العميل ❌",
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
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal.shade700.withOpacity(0.9),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade900,
                  Colors.teal.shade700,
                  Colors.teal.shade500,
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
                        Colors.teal.shade900.withOpacity(0.95),
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
                              Colors.teal.withOpacity(
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
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildAdvancedGlassField(
                                controller: clientNameController,
                                label: 'اسم العميل',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 28),
                              _buildAdvancedGlassField(
                                controller: amountController,
                                label: 'المبلغ',
                                icon: Icons.attach_money,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true)
                                    return 'الرجاء إدخال المبلغ';
                                  if (double.tryParse(value!.trim()) == null)
                                    return 'المبلغ غير صالح';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              _buildAdvancedGlassField(
                                controller: phoneController,
                                label: 'رقم الهاتف',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value?.isEmpty ?? true)
                                    return 'الرجاء إدخال رقم الهاتف';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              _buildAdvancedGlassField(
                                controller: locationController,
                                label: 'الموقع',
                                icon: Icons.location_on,
                                validator: (value) {
                                  if (value?.isEmpty ?? true)
                                    return 'الرجاء إدخال الموقع';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // زر تحديد الموقع مع رسوم متحركة
                              ScaleTransition(
                                scale: _locationButtonScaleAnimation,
                                child: ElevatedButton.icon(
                                  onPressed: getCurrentLocation,
                                  icon: const Icon(Icons.my_location, size: 24),
                                  label: const Text(
                                    'تحديد الموقع الحالي',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade600
                                        .withOpacity(0.9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.tealAccent.withOpacity(
                                      0.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
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
                                        borderRadius: BorderRadius.circular(35),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.teal.shade700,
                                            Colors.teal.shade500,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.teal.withOpacity(0.6),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              _buttonGlowAnimation.value * 0.3,
                                            ),
                                            blurRadius: 15,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: addClient,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              35,
                                            ),
                                          ),
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: const Text(
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
  Widget _buildAdvancedGlassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                prefixIcon: Icon(icon, color: Colors.white70, size: 28),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
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
      Colors.teal.withOpacity(random.nextDouble() * 0.4 + 0.2),
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
