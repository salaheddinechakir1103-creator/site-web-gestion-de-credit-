import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

/// صفحة تعديل بيانات العميل مع تصميم فائق التقدم ومهني.
/// تشمل خلفية متحركة، رسوم متحركة متقدمة، وتأثيرات زجاجية محسنة.
class EditCreaditPagedepot extends StatefulWidget {
  final String docId;
  final String oldName;
  final String olddepot;
  final String oldPhone;
  final String oldLocation;

  const EditCreaditPagedepot({
    Key? key,
    required this.docId,
    required this.oldName,
    required this.olddepot,
    required this.oldPhone,
    required this.oldLocation,
    required String oldCredit,
  }) : super(key: key);

  @override
  _EditCreaditPageState createState() => _EditCreaditPageState();
}

class _EditCreaditPageState extends State<EditCreaditPagedepot>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController creditController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  final CollectionReference creditCollection = FirebaseFirestore.instance
      .collection('depot');

  bool _isLoading = false;

  late AnimationController _formAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.oldName);
    creditController = TextEditingController(text: widget.olddepot);
    phoneController = TextEditingController(text: widget.oldPhone);
    locationController = TextEditingController(text: widget.oldLocation);

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // إنشاء جسيمات متحركة
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle.random());
    }

    // بدء الرسوم المتحركة
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formAnimationController.forward();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    creditController.dispose();
    phoneController.dispose();
    locationController.dispose();
    _formAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double creditValue = double.parse(
        creditController.text.replaceAll(',', '.'),
      );

      await creditCollection.doc(widget.docId).set({
        "name": nameController.text.trim(),
        "credit": creditValue,
        "phone": phoneController.text.trim(),
        "location": locationController.text.trim(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'تم بنجاح',
        desc: "تم تعديل بيانات العميل ✅",
        btnOkOnPress: () {
          Navigator.of(context).pop(true);
        },
      ).show();
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'خطأ',
        desc: "تعذر الحفظ ❌\n$e",
        btnOkOnPress: () {},
      ).show();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: const Text(
            "تعديل بيانات العميل",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple.shade800,
          elevation: 10,
          shadowColor: Colors.deepPurple.shade900.withOpacity(0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // خلفية متحركة مع جسيمات
            AnimatedBuilder(
              animation: _particleController,
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
                  child: CustomPaint(
                    painter: ParticlePainter(
                      _particles,
                      _particleController.value,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade800,
                                  Colors.teal.shade600,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: nameController,
                                    label: 'الاسم',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'الاسم مطلوب';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'الاسم قصير جدًا';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: creditController,
                                    label: 'الرصيد',
                                    icon: Icons.attach_money,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'الرصيد مطلوب';
                                      }
                                      final parsed = double.tryParse(
                                        value.replaceAll(',', '.').trim(),
                                      );
                                      if (parsed == null)
                                        return 'أدخل رقم صالح';
                                      if (parsed < 0)
                                        return 'يجب أن يكون الرقم موجبًا';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: phoneController,
                                    label: 'الهاتف',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'رقم الهاتف مطلوب';
                                      }
                                      if (value.trim().length < 6)
                                        return 'رقم قصير جدًا';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: locationController,
                                    label: 'العنوان',
                                    icon: Icons.location_on,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'العنوان مطلوب';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'إلغاء',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : saveChanges,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            backgroundColor:
                                                Colors.teal.shade800,
                                            elevation: 8,
                                            shadowColor: Colors.teal.shade800,
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Text('حفظ التعديلات'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
}

/// فئة لتمثيل جسيم متحرك
class Particle {
  double x, y, vx, vy, size;
  Color color;

  Particle(this.x, this.y, this.vx, this.vy, this.size, this.color);

  factory Particle.random() {
    final random = math.Random();
    return Particle(
      random.nextDouble() * 400,
      random.nextDouble() * 800,
      (random.nextDouble() - 0.5) * 2,
      random.nextDouble() * 1.5,
      random.nextDouble() * 4 + 1,
      Colors.deepPurple.withOpacity(random.nextDouble() * 0.3 + 0.1),
    );
  }

  void update(double deltaTime) {
    x += vx * deltaTime;
    y += vy * deltaTime;
    if (x < 0 || x > 400) vx = -vx;
    if (y > 800) y = -size;
  }
}

/// رسام الجسيمات
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(1.0);
      final paint = Paint()..color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
