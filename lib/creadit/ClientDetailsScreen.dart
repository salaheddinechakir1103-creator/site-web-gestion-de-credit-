import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'editcreadit.dart'; // تأكد من استيراد صفحة التعديل

/// صفحة تفاصيل العميل مع تصميم فائق التقدم ومهني.
/// تشمل خلفية متحركة، رسوم متحركة متقدمة، وتأثيرات زجاجية محسنة.
class ClientDetailsScreen1 extends StatefulWidget {
  final String clientId;
  const ClientDetailsScreen1({Key? key, required this.clientId})
    : super(key: key);

  @override
  State<ClientDetailsScreen1> createState() => _ClientDetailsScreen1State();
}

class _ClientDetailsScreen1State extends State<ClientDetailsScreen1>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeIn),
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
      if (mounted) _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Référence vers la collection "creadit"
    DocumentReference clientDoc = FirebaseFirestore.instance
        .collection('creadit')
        .doc(widget.clientId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: const Text(
            "معلومات العميل",
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
          backgroundColor: Colors.deepPurple.shade800,
          centerTitle: true,
          elevation: 10,
          shadowColor: Colors.deepPurple.shade900.withOpacity(0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade600,
                ],
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
                        Colors.deepPurple.shade900.withOpacity(0.95),
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
            StreamBuilder<DocumentSnapshot>(
              stream: clientDoc.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.amberAccent,
                      ),
                    ),
                  );
                }

                // Récupération des données
                var clientData =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                String name = clientData['name'] ?? "غير معروف";
                String phone = clientData['phone'] ?? "غير محدد";
                String location = clientData['location'] ?? "غير محدد";
                double credit = 0;
                if (clientData['credit'] != null) {
                  credit =
                      double.tryParse(clientData['credit'].toString()) ?? 0;
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        // Profile Card with Advanced Animations and Glassmorphism
                        AnimatedBuilder(
                          animation: _cardAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 25,
                                      sigmaY: 25,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 36,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurple.shade700
                                                .withOpacity(0.5),
                                            Colors.deepPurple.shade900
                                                .withOpacity(0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Avatar with Gradient Border and Glow
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.amberAccent,
                                                  Colors.deepPurple.shade400,
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.grey,
                                              child: Icon(
                                                Icons.person_pin_circle_rounded,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black26,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Divider(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            thickness: 1,
                                            indent: 40,
                                            endIndent: 40,
                                          ),
                                          const SizedBox(height: 20),
                                          _buildInfoRow(
                                            Icons.phone,
                                            "رقم الهاتف",
                                            phone,
                                          ),
                                          const SizedBox(height: 14),
                                          _buildInfoRow(
                                            Icons.location_on,
                                            "العنوان",
                                            location,
                                          ),
                                          const SizedBox(height: 14),
                                          _buildInfoRow(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            "إجمالي الرصيد",
                                            "$credit درهم",
                                            color: Colors.amberAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        // Action Buttons with Animation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnimatedButton(
                              context,
                              icon: Icons.arrow_back_ios_new_rounded,
                              label: "عودة",
                              color: Colors.deepPurple.shade700,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 20),
                            _buildAnimatedButton(
                              context,
                              icon: Icons.edit,
                              label: "تعديل",
                              color: Colors.deepPurple.shade600,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditCreaditPage(
                                      docId: widget.clientId,
                                      oldName: name,
                                      oldCredit: credit.toString(),
                                      oldPhone: phone,
                                      oldLocation: location,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.white70,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
