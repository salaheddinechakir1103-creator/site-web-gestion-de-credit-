import 'dart:ui';
import 'dart:math' as math;

import 'package:Chakir_Shop/creadit/ClientDetailsScreen.dart';
import 'package:Chakir_Shop/depot/ClientDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;

/// صفحة إدارة رصيد العميل مع تصميم فائق التقدم ومهني.
/// تشمل خلفية متحركة، رسوم متحركة متقدمة، وتأثيرات زجاجية محسنة.
class ClientDepotsScreen extends StatefulWidget {
  final String docId;
  const ClientDepotsScreen({
    Key? key,
    required this.docId,
    required String docoss,
    required oldName,
    required String oldDepot,
    required oldphone,
    required oldlocation,
    required String clientId,
  }) : super(key: key);

  @override
  State<ClientDepotsScreen> createState() => _ClientCreditsScreenState();
}

class _ClientCreditsScreenState extends State<ClientDepotsScreen>
    with TickerProviderStateMixin {
  late CollectionReference creditCollection;
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double currentCredit = 0.0;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    creditCollection = FirebaseFirestore.instance
        .collection('depot')
        .doc(widget.docId)
        .collection("detail");

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // إنشاء جسيمات متحركة
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle.random());
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    amountController.dispose();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> performTransaction(bool isDeposit) async {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(amountController.text);

      // Vérification pour le retrait
      if (!isDeposit && amount > currentCredit) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: "تحذير",
          desc: "الرصيد غير كافٍ للسحب",
          btnOkOnPress: () {},
        ).show();
        return;
      }

      setState(() => isLoading = true);

      String type = isDeposit ? "إيداع" : "سحب";

      try {
        await creditCollection.add({
          'detailcredit': "$type: $amount",
          'amount': isDeposit ? amount : -amount,
          'timestamp': FieldValue.serverTimestamp(),
        });

        var clientDoc = FirebaseFirestore.instance
            .collection('depot')
            .doc(widget.docId);
        await clientDoc.update({
          'depot': FieldValue.increment(isDeposit ? amount : -amount),
        });

        amountController.clear();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: "نجاح",
          desc: "$amount تم ${isDeposit ? "إيداعه" : "سحبه"} ✅",
          btnOkOnPress: () {},
        ).show();
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: "خطأ",
          desc: "حدث خطأ أثناء العملية ❌",
          btnOkOnPress: () {},
        ).show();
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.teal.shade700.withOpacity(0.9),
          centerTitle: true,
          title: const Text(
            "رصيد العميل",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
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
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Carte du client avec design avancé
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('depot')
                          .doc(widget.docId)
                          .snapshots(),
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
                        var data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        if (data == null) {
                          return const Text(
                            "لا توجد بيانات",
                            style: TextStyle(color: Colors.white),
                          );
                        }

                        double total = (data['depot'] ?? 0).toDouble();
                        currentCredit = total;
                        String name = data['name'] ?? "اسم العميل";

                        return _buildAdvancedGlassCard(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClientDetailsScreen(
                                    clientId: widget.docId,
                                    name: null,
                                    credit: null,
                                    phone: null,
                                    location: null,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
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
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
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
                                      const SizedBox(height: 8),
                                      const Text(
                                        "الرصيد الحالي",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "${NumberFormat.currency(locale: 'ar_SA', symbol: 'درهم ').format(total)}",
                                        style: TextStyle(
                                          color: total >= 0
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Formulaire avec design amélioré
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildAdvancedGlassField(
                              controller: amountController,
                              label: 'أدخل المبلغ',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'الرجاء إدخال المبلغ';
                                if (double.tryParse(value) == null)
                                  return 'المبلغ غير صالح';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            children: [
                              _buildActionButton(
                                onPressed: isLoading
                                    ? null
                                    : () => performTransaction(true),
                                icon: Icons.add,
                                label: "إيداع",
                                color: Colors.green,
                              ),
                              const SizedBox(height: 10),
                              _buildActionButton(
                                onPressed: isLoading
                                    ? null
                                    : () => performTransaction(false),
                                icon: Icons.remove,
                                label: "سحب",
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 20),

                    // Liste des transactions avec design avancé
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: creditCollection
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
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
                          var docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "لا توجد عمليات",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              var depot =
                                  docs[index].data() as Map<String, dynamic>;

                              // تحويل القيمة إلى double بشكل آمن
                              double amount = 0;
                              if (depot['amount'] != null) {
                                if (depot['amount'] is int) {
                                  amount = (depot['amount'] as int).toDouble();
                                } else if (depot['amount'] is double) {
                                  amount = depot['amount'] as double;
                                } else if (depot['amount'] is String) {
                                  amount =
                                      double.tryParse(depot['amount']) ?? 0;
                                }
                              }

                              // تحويل detailcredit إلى String دائمًا
                              String detail =
                                  depot['detailcredit']?.toString() ?? '';

                              // تحويل التاريخ إلى نص بشكل آمن
                              String date = '';
                              if (depot['timestamp'] != null &&
                                  depot['timestamp'] is Timestamp) {
                                date = DateFormat('yyyy-MM-dd HH:mm').format(
                                  (depot['timestamp'] as Timestamp).toDate(),
                                );
                              }

                              return _buildAdvancedGlassCard(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detail,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: amount >= 0
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${amount >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'ar_SA', symbol: '').format(amount)}",
                                        style: TextStyle(
                                          color: amount >= 0
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedGlassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }

  Widget _buildAdvancedGlassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: Icon(icon, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
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
