import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'creadit/homecreadit.dart';
import 'depot/homedepot.dart' hide HomeCreadit;

/// نقطة دخول التطبيق.
/// تهيئ Firebase وتشغيل التطبيق.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

/// عنصر الجذر للتطبيق.
/// يقوم بتكوين MaterialApp مع سمة داكنة محسنة.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الإيداع الكريدي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: Colors.grey.shade900,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// صفحة الرئيسية مع تصميم متقدم يشمل خلفية متحركة وتأثيرات بصرية محسنة.
/// تعرض بطاقات تفاعلية مع رسوم متحركة متقدمة.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height * 0.25;
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متحركة مع تأثير ضبابي
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade900.withOpacity(0.8),
                        Colors.teal.shade900.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رأس متحرك
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإيداع و الكريدي',
                              style: TextStyle(
                                fontSize: 36.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade200,
                                letterSpacing: 1.0,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 3),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'إدارة حساباتك بكفاءة وأمان',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // قائمة البطاقات مع تأثيرات متقدمة
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          final items = [
                            {
                              'title': 'الكريدي',
                              'subtitle': 'إدارة حسابات الكريدي بسهولة',
                              'icon': Icons.credit_card,
                              'colors': [
                                Colors.purple.shade600,
                                Colors.purple.shade400,
                              ],
                              'onTap': () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HomeCreadit(),
                                ),
                              ),
                            },
                            {
                              'title': 'الإيداع',
                              'subtitle': 'إدارة حسابات الإيداع بسرعة',
                              'icon': Icons.account_balance_wallet,
                              'colors': [
                                Colors.teal.shade600,
                                Colors.teal.shade400,
                              ],
                              'onTap': () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => Homedepot()),
                              ),
                            },
                          ];
                          final item = items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: AdvancedGlassCard(
                              title: item['title'] as String,
                              subtitle: item['subtitle'] as String,
                              icon: item['icon'] as IconData,
                              colors: item['colors'] as List<Color>,
                              height: cardHeight,
                              onTap: item['onTap'] as VoidCallback,
                              animationDelay: index * 200,
                            ),
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
}

/// بطاقة زجاجية متقدمة مع رسوم متحركة عند التحميل والضغط.
/// تشمل تأثيرات بصرية محسنة مثل التلألؤ والظلال الديناميكية.
class AdvancedGlassCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final double height;
  final VoidCallback onTap;
  final int animationDelay;

  const AdvancedGlassCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.height,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  State<AdvancedGlassCard> createState() => _AdvancedGlassCardState();
}

class _AdvancedGlassCardState extends State<AdvancedGlassCard>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _cardAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * (_isPressed ? 0.95 : 1.0),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.colors
                            .map((c) => c.withOpacity(0.8))
                            .toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20.0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: widget.colors.first.withOpacity(0.3),
                          blurRadius: 10.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // أيقونة مع تأثير تلألؤ
                        Container(
                          margin: const EdgeInsets.all(20.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 12.0,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            size: 50.0,
                            color: Colors.white,
                          ),
                        ),
                        // نصوص مع تأثيرات
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 3),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
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
