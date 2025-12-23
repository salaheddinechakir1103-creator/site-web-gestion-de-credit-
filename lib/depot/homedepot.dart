import 'package:Chakir_Shop/depot/ClientDetailsScreen.dart';
import 'package:Chakir_Shop/depot/ajouterclientdepot.dart';
import 'package:Chakir_Shop/depot/editdepot.dart';
import 'package:Chakir_Shop/depot/homeclientdepot.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:ui';
import 'dart:math' as math;

/// صفحة إدارة العملاء الكريدي مع تصميم فائق التقدم ومهني.
/// تشمل خلفية متحركة، رسوم متحركة متقدمة، وتأثيرات زجاجية محسنة.
class Homedepot extends StatefulWidget {
  const Homedepot({super.key});

  @override
  State<Homedepot> createState() => _HomeCreaditState();
}

class _HomeCreaditState extends State<Homedepot> with TickerProviderStateMixin {
  String searchQuery = '';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchOpacityAnimation;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _searchOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchAnimationController, curve: Curves.easeIn),
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
    Future.delayed(const Duration(milliseconds: 200), () {
      _fabAnimationController.forward();
      _searchAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.teal.shade800,
          centerTitle: true,
          title: const Text(
            "لوحة العملاء الكريدي",
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
        floatingActionButton: ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.teal.shade800.withOpacity(0.9),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InputScreendepot(docoss: '', lang: ''),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            label: const Text(
              "إضافة عميل",
              style: TextStyle(fontWeight: FontWeight.bold),
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
            Column(
              children: [
                // 🔍 شريط البحث المتقدم
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FadeTransition(
                    opacity: _searchOpacityAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن عميل...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.trim().toLowerCase();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔄 قائمة الشبكة الديناميكية مع رسوم متحركة
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('depot')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 0, 95, 84),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      // ✅ تصفية حسب استعلام البحث
                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>?;
                        final name = (data?['name'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 64,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? "لا يوجد عملاء"
                                    : "لا يوجد نتائج مطابقة",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent:
                                  350, // زيادة الارتفاع للبطاقة المتقدمة
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, i) {
                          final doc = filteredDocs[i];
                          final data = doc.data() as Map<String, dynamic>?;

                          final name = data?['name'] ?? 'بدون اسم';
                          final credit = data?['credit'] ?? 0;
                          final phone = data?['phone'] ?? '';
                          final location = data?['location'] ?? '';

                          return AdvancedClientCard(
                            name: name,
                            credit: credit,
                            index: i,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ClientDepotsScreen(
                                    clientId: doc.id,
                                    oldName: name,
                                    oldDepot: credit.toString(),
                                    oldphone: phone,
                                    oldlocation: location,
                                    docId: doc.id,
                                    docoss: '',
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                headerAnimationLoop: false,
                                animType: AnimType.bottomSlide,
                                title: 'اختر الإجراء',
                                desc: "حدد الإجراء المطلوب لهذا العميل",
                                btnCancelText: "حذف",
                                btnOkText: "تعديل",
                                btnCancelOnPress: () async {
                                  await FirebaseFirestore.instance
                                      .collection('depot')
                                      .doc(doc.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم حذف العميل'),
                                    ),
                                  );
                                },
                                btnOkOnPress: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditCreaditPagedepot(
                                            docId: doc.id,
                                            oldName: name,
                                            olddepot: credit.toString(),
                                            oldPhone: phone,
                                            oldLocation: location,
                                            oldCredit: credit.toString(),
                                          ),
                                    ),
                                  );
                                },
                              ).show();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
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

/// بطاقة العميل المتقدمة مع تصميم احترافي ومتقدم: تأثيرات زجاجية محسنة، رسوم متحركة متقدمة،
/// عناصر تفاعلية، وتخطيط محسن لعرض المعلومات بشكل أكثر احترافية.
class AdvancedClientCard extends StatefulWidget {
  final String name;
  final dynamic credit;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AdvancedClientCard({
    super.key,
    required this.name,
    required this.credit,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<AdvancedClientCard> createState() => _AdvancedClientCardState();
}

class _AdvancedClientCardState extends State<AdvancedClientCard>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _glowController;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconRotationAnimation;
  bool _isPressed = false;

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

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _glowController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _iconAnimationController.forward().then(
          (_) => _iconAnimationController.reverse(),
        );
        widget.onTap();
      },
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _cardAnimationController,
          _glowController,
          _iconAnimationController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * (_isPressed ? 0.95 : 1.0),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
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
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.teal.shade800,
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // الجزء العلوي: الصورة الرمزية مع تأثير دوران خفيف
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage: const NetworkImage(
                                  "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png",
                                ),
                                backgroundColor: Colors.deepPurple.shade300,
                              ),
                            ),
                            // أيقونة صغيرة متحركة فوق الصورة
                            Positioned(
                              top: 10,
                              right: 10,
                              child: RotationTransition(
                                turns: _iconRotationAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.teal.shade800,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // الجزء الأوسط: الاسم والرصيد مع أيقونة
                        Column(
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "الرصيد: ${widget.credit}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // الجزء السفلي: رقم العميل مع أيقونة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.tag,
                                  color: Colors.white60,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "عميل #${widget.index + 1}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
