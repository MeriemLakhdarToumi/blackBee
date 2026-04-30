// Import Flutter's core UI library (widgets, colors, icons, etc.)
import 'package:flutter/material.dart';
// Import Flutter services for haptic feedback / clipboard
import 'package:flutter/services.dart';
// Import Firebase Authentication to handle user login/logout/session
import 'package:firebase_auth/firebase_auth.dart';
// Import Firestore to read/write data from the cloud database
import 'package:cloud_firestore/cloud_firestore.dart';
// Import Dart's math library (used for min/max in chart calculations)
import 'dart:math';
// Import async utilities for timers
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

// ==================== MAIN DASHBOARD SCAFFOLD ====================

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    HomeTab(),
    AttacksTab(),
    LogsTab(),
    ProfileTab(),
  ];

  Widget _buildDrawer() {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Dashboard',
        'subtitle': 'Overview & stats',
        'color': const Color(0xFFE5AC07),
      },
      {
        'icon': Icons.notification_important_outlined,
        'activeIcon': Icons.notification_important,
        'label': 'Attacks',
        'subtitle': 'Live attack feed',
        'color': Colors.redAccent,
      },
      {
        'icon': Icons.article_outlined,
        'activeIcon': Icons.article,
        'label': 'Logs',
        'subtitle': 'System activity logs',
        'color': Colors.greenAccent,
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile',
        'subtitle': 'Account & security',
        'color': const Color(0xFFE5AC07),
      },
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          border: Border(
            right: BorderSide(
              color: const Color.fromARGB(255, 0, 0, 0),
              width: 0,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5AC07).withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE5AC07).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xFFE5AC07).withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Color(0xFFE5AC07),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HoneypCT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'AI Adaptive Honeypot',
                          style: TextStyle(
                            color: Color(0xFFE5AC07),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Section label ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'NAVIGATION',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Nav items ───────────────────────────────────────────────
              ...List.generate(items.length, (i) {
                final isSelected = _currentIndex == i;
                final itemColor = items[i]['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = i);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? itemColor.withOpacity(0.1)
                          : const Color(0xFF111111).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? itemColor.withOpacity(0.55)
                            : Colors.grey.withOpacity(0.15),
                        width: isSelected ? 0.9 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? itemColor.withOpacity(0.15)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? itemColor.withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.12),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            isSelected
                                ? items[i]['activeIcon'] as IconData
                                : items[i]['icon'] as IconData,
                            color: isSelected ? itemColor : Colors.grey[500],
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Label + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[i]['label'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[400],
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                items[i]['subtitle'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? itemColor.withOpacity(0.8)
                                      : Colors.grey[700],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Active indicator dot
                        if (isSelected)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: itemColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: itemColor.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              // ── Bottom status strip ─────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Honeypot Active',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.greenAccent.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFFE5AC07),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_important_outlined),
              activeIcon: Icon(Icons.notification_important),
              label: 'Attacks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME TAB ====================

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final int totalAttacks = 128;
  final int uniqueIPs = 96;
  final int interactions = 342;
  final int countries = 18;

  // 7-day trend data — clearly increasing
  final List<double> trendData = [18, 28, 35, 45, 52, 63, 75];

  final List<String> trendLabels = [
    'May 10',
    'May 11',
    'May 12',
    'May 13',
    'May 14',
    'May 15',
    'May 16',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1: BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          // LAYER 2: DARK OVERLAY
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // LAYER 3: MAIN CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 25),
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildBeeSection(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildAttackTrend(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu, color: Color(0xFFE5AC07), size: 26),
        ),
        const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Stack(
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFE5AC07),
              size: 26,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5AC07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Honeypot Status Card ─────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5AC07), Color(0xFFCF9700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Honeypot Status',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your honeypot is running\nand monitoring for attacks.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user, color: Colors.black, size: 60),
        ],
      ),
    );
  }

  // ── Bee Logo + App Title Section ─────────────────────────────────────────
  Widget _buildBeeSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          Image.asset(
            'assets/blackbee_icon.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          Transform.translate(
            offset: const Offset(0, -15),
            child: const Text(
              'AI Adaptive Honeypot',
              style: TextStyle(
                color: Color(0xFFE5AC07),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: const Text(
              'Smart. Adaptive. Deceptive.',
              style: TextStyle(
                color: Color.fromARGB(255, 185, 185, 185),
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid (2 columns × 2 rows) ─────────────────────────────────────
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        // Card 1: Total Attacks — increasing sparkline
        _buildStatCard(
          'Total Attacks',
          totalAttacks.toString(),
          icon: Icons.local_fire_department,
          visualWidget: SizedBox(
            height: 28,
            child: CustomPaint(
              size: const Size(double.infinity, 28),
              painter: SparklinePainter(trendUp: true, monotone: true),
            ),
          ),
        ),

        // Card 2: Unique IPs — radial donut visual
        _buildStatCard(
          'Unique IPs',
          uniqueIPs.toString(),
          icon: Icons.lan,
          visualWidget: SizedBox(
            height: 38,
            child: CustomPaint(
              size: const Size(double.infinity, 38),
              painter: DonutPainter(
                value: uniqueIPs / 120.0, // fraction filled (0.0 – 1.0)
                color: const Color(0xFFE5AC07),
              ),
            ),
          ),
        ),

        // Card 3: Interactions — decreasing sparkline
        _buildStatCard(
          'Interactions',
          interactions.toString(),
          icon: Icons.warning_amber_rounded,
          visualWidget: SizedBox(
            height: 28,
            child: CustomPaint(
              size: const Size(double.infinity, 28),
              painter: SparklinePainter(trendUp: false, monotone: true),
            ),
          ),
        ),

        // Card 4: Countries — mini bar chart
        _buildStatCard(
          'Countries',
          countries.toString(),
          icon: Icons.language,
          visualWidget: SizedBox(
            height: 32,
            child: CustomPaint(
              size: const Size(double.infinity, 32),
              painter: MiniBarPainter(
                values: const [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.55],
                color: const Color(0xFFE5AC07),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Builds a single stat card widget
  Widget _buildStatCard(
    String label,
    String value, {
    IconData? icon,
    Widget? visualWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 17, 17, 17).withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE5AC07),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color.fromARGB(213, 255, 255, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (visualWidget != null) visualWidget,
              ],
            ),
          ),
          if (icon != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Icon(icon, color: const Color(0xFFE5AC07), size: 25),
            ),
        ],
      ),
    );
  }

  // ── Attack Trend Chart (Last 7 Days) ─────────────────────────────────────
  Widget _buildAttackTrend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 17, 17, 17).withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attack Trend (Last 7 Days)',
            style: TextStyle(
              color: Color(0xFFE5AC07),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: AreaChartPainter(
                data: trendData,
                labels: trendLabels,
                lineColor: const Color(0xFFE5AC07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HEXAGON CLIPPER ====================

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==================== SPARKLINE PAINTER ====================
// Supports monotone (clearly increasing or decreasing) mode.

class SparklinePainter extends CustomPainter {
  final bool trendUp;

  /// If true, generates a cleanly rising/falling line without noise.
  final bool monotone;

  SparklinePainter({required this.trendUp, this.monotone = false});

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[];
    final count = 8;

    if (monotone) {
      // Generate a smooth monotone trend without random noise
      for (int i = 0; i < count; i++) {
        final x = size.width * i / (count - 1);
        final progress = i / (count - 1); // 0.0 → 1.0
        // Ease-in curve for a more natural look
        final eased = progress * progress;
        final y = trendUp
            ? size.height - eased * size.height * 0.85
            : size.height * 0.15 + eased * size.height * 0.7;
        points.add(Offset(x, y.clamp(0.0, size.height)));
      }
    } else {
      final rng = Random(trendUp ? 42 : 13);
      for (int i = 0; i < count; i++) {
        final x = size.width * i / (count - 1);
        double base = trendUp
            ? (i / count) * size.height * 0.6
            : size.height * 0.6 - (i / count) * size.height * 0.4;
        final y = size.height - base - rng.nextDouble() * 6;
        points.add(Offset(x, y.clamp(0.0, size.height)));
      }
    }

    // Build smooth curve
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      path.cubicTo(
        prev.dx + (curr.dx - prev.dx) / 2,
        prev.dy,
        prev.dx + (curr.dx - prev.dx) / 2,
        curr.dy,
        curr.dx,
        curr.dy,
      );
    }

    // Filled area
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE5AC07).withOpacity(0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE5AC07)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ==================== DONUT PAINTER (Unique IPs) ====================
// Draws a thin arc that fills based on [value] (0.0–1.0).

class DonutPainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final Color color;

  DonutPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    const strokeWidth = 5.0;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Filled arc
    final sweepAngle = 2 * pi * value.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Percentage text in the center
    final pct = '${(value * 100).round()}%';
    final tp = TextPainter(
      text: TextSpan(
        text: pct,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.value != value || old.color != color;
}

// ==================== MINI BAR PAINTER (Countries) ====================
// Draws a row of small vertical bars, like a mini bar chart.

class MiniBarPainter extends CustomPainter {
  final List<double> values; // Each value: 0.0–1.0
  final Color color;

  MiniBarPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final count = values.length;
    final barWidth = (size.width - (count - 1) * 3) / count;

    for (int i = 0; i < count; i++) {
      final barHeight = values[i] * size.height;
      final x = i * (barWidth + 3);
      final y = size.height - barHeight;

      // Background bar (track)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, barWidth, size.height),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.grey.withOpacity(0.12),
      );

      // Filled bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(2),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withOpacity(0.5)],
          ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight)),
      );
    }
  }

  @override
  bool shouldRepaint(MiniBarPainter old) => false;
}

// ==================== AREA CHART PAINTER (7-day trend chart) ====================

class AreaChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color lineColor;

  AreaChartPainter({
    required this.data,
    required this.labels,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 28;
    const double rightMargin = 8;
    const double topMargin = 10;
    const double bottomMargin = 28;

    final double chartW = size.width - leftMargin - rightMargin;
    final double chartH = size.height - topMargin - bottomMargin;

    final double maxVal = data.reduce(max);
    final double minVal = data.reduce(min);
    final double range = (maxVal - minVal) == 0 ? 1 : maxVal - minVal;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 3; i++) {
      final y = topMargin + (i * chartH / 3);
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width - rightMargin, y),
        gridPaint,
      );
      final val = (maxVal - (i * range / 3)).round();
      _drawText(canvas, val.toString(), Offset(0, y - 6), Colors.grey, 9);
    }

    // Data point positions
    final List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = leftMargin + (i * chartW / (data.length - 1));
      final y = topMargin + chartH - ((data[i] - minVal) / range * chartH);
      pts.add(Offset(x, y));
    }

    // Filled area
    final areaPath = Path();
    areaPath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      areaPath.cubicTo(
        prev.dx + (curr.dx - prev.dx) * 0.5,
        prev.dy,
        prev.dx + (curr.dx - prev.dx) * 0.5,
        curr.dy,
        curr.dx,
        curr.dy,
      );
    }
    areaPath.lineTo(pts.last.dx, topMargin + chartH);
    areaPath.lineTo(pts.first.dx, topMargin + chartH);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withOpacity(0.45), lineColor.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(leftMargin, topMargin, chartW, chartH)),
    );

    // Line
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      linePath.cubicTo(
        prev.dx + (curr.dx - prev.dx) * 0.5,
        prev.dy,
        prev.dx + (curr.dx - prev.dx) * 0.5,
        curr.dy,
        curr.dx,
        curr.dy,
      );
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots + X-axis labels
    for (int i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 3.5, Paint()..color = lineColor);
      canvas.drawCircle(pts[i], 2, Paint()..color = const Color(0xff1E1F25));
      _drawText(
        canvas,
        labels[i],
        Offset(pts[i].dx - 14, size.height - bottomMargin + 6),
        Colors.grey,
        8,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}

// ==================== ATTACKS TAB ====================

class AttacksTab extends StatefulWidget {
  @override
  _AttacksTabState createState() => _AttacksTabState();
}

class _AttacksTabState extends State<AttacksTab> {
  // Selected time filter index: 0=All, 1=Today, 2=This Week, 3=This Month
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];

  // Severity filter: null = all, 'Low', 'Medium', 'High'
  String? _selectedSeverity;

  // Search state
  bool _searchOpen = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Full attack list with country flag emoji and severity
  final List<Map<String, dynamic>> _allAttacks = [
    {
      'type': 'SSH Brute Force',
      'ip': '192.168.1.100',
      'time': '2 min ago',
      'status': 'active',
      'severity': 'High',
      'flag': '🇺🇸',
      'country': 'united states',
      'filter': 'Today',
      'commands': [
        'AUTH root password123',
        'AUTH admin admin',
        'AUTH root toor',
        'ls -la /etc',
        'cat /etc/passwd',
      ],
      'nextCommands': [
        'wget malicious.sh',
        'chmod +x malicious.sh',
        'crontab -e',
        'useradd backdoor',
      ],
      'port': '22',
      'protocol': 'SSH',
      'duration': '4 min 12s',
      'attempts': 47,
    },
    {
      'type': 'Web Login Attempt',
      'ip': '203.0.113.45',
      'time': '5 min ago',
      'status': 'active',
      'severity': 'Medium',
      'flag': '🇳🇱',
      'country': 'netherlands',
      'filter': 'Today',
      'commands': ['POST /wp-login.php', 'POST /admin/login', 'GET /wp-admin/'],
      'nextCommands': [
        'Upload webshell',
        'Enumerate plugins',
        'Read wp-config.php',
      ],
      'port': '443',
      'protocol': 'HTTPS',
      'duration': '1 min 30s',
      'attempts': 12,
    },
    {
      'type': 'Port Scan',
      'ip': '185.199.108.23',
      'time': '12 min ago',
      'status': 'blocked',
      'severity': 'Low',
      'flag': '🇩🇪',
      'country': 'germany',
      'filter': 'Today',
      'commands': ['SYN 22', 'SYN 80', 'SYN 443', 'SYN 3306', 'SYN 8080'],
      'nextCommands': [
        'Exploit open port',
        'Banner grabbing',
        'Service enumeration',
      ],
      'port': 'Multiple',
      'protocol': 'TCP',
      'duration': '45s',
      'attempts': 320,
    },
    {
      'type': 'SQL Injection Attempt',
      'ip': '198.51.100.77',
      'time': '18 min ago',
      'status': 'active',
      'severity': 'High',
      'flag': '🇸🇬',
      'country': 'singapore',
      'filter': 'Today',
      'commands': [
        "GET /?id=1'",
        "GET /?id=1 OR 1=1--",
        "GET /?id=1 UNION SELECT null,null--",
      ],
      'nextCommands': [
        'Dump database',
        'Read system files',
        'Write webshell via INTO OUTFILE',
      ],
      'port': '80',
      'protocol': 'HTTP',
      'duration': '2 min 5s',
      'attempts': 28,
    },
    {
      'type': 'Directory Traversal',
      'ip': '203.0.113.88',
      'time': '25 min ago',
      'status': 'active',
      'severity': 'Medium',
      'flag': '🇬🇧',
      'country': 'united kingdom',
      'filter': 'This Week',
      'commands': [
        'GET /../../../etc/passwd',
        'GET /..%2F..%2Fetc/shadow',
        'GET /%2e%2e/windows/win.ini',
      ],
      'nextCommands': [
        'Read SSH private keys',
        'Steal config files',
        'Enumerate user directories',
      ],
      'port': '80',
      'protocol': 'HTTP',
      'duration': '55s',
      'attempts': 9,
    },
    {
      'type': 'Bad Bot',
      'ip': '192.0.2.44',
      'time': '35 min ago',
      'status': 'blocked',
      'severity': 'Low',
      'flag': '🇫🇷',
      'country': 'france',
      'filter': 'This Week',
      'commands': [
        'GET /robots.txt',
        'GET /sitemap.xml',
        'GET /admin',
        'GET /.env',
      ],
      'nextCommands': [
        'Credential stuffing',
        'Data scraping',
        'Vulnerability probing',
      ],
      'port': '443',
      'protocol': 'HTTPS',
      'duration': '3 min',
      'attempts': 61,
    },
    {
      'type': 'SSH Brute Force',
      'ip': '203.0.113.91',
      'time': '45 min ago',
      'status': 'active',
      'severity': 'High',
      'flag': '🇧🇷',
      'country': 'brazil',
      'filter': 'This Month',
      'commands': [
        'AUTH root 123456',
        'AUTH ubuntu ubuntu',
        'AUTH pi raspberry',
      ],
      'nextCommands': [
        'Install backdoor',
        'Lateral movement',
        'Exfiltrate /home',
      ],
      'port': '22',
      'protocol': 'SSH',
      'duration': '6 min 40s',
      'attempts': 83,
    },
    {
      'type': 'XSS Attack',
      'ip': '172.16.0.99',
      'time': '1 hr ago',
      'status': 'blocked',
      'severity': 'Medium',
      'flag': '🇨🇳',
      'country': 'china',
      'filter': 'This Month',
      'commands': [
        'GET /search?q=<script>alert(1)</script>',
        'POST /comment body=<img src=x onerror=alert(1)>',
      ],
      'nextCommands': [
        'Steal session cookies',
        'Redirect to phishing',
        'Keylog victim browser',
      ],
      'port': '443',
      'protocol': 'HTTPS',
      'duration': '20s',
      'attempts': 5,
    },
  ];

  List<Map<String, dynamic>> get _filteredAttacks {
    final filterLabel = _filters[_selectedFilter];
    return _allAttacks.where((a) {
      // Time filter
      final matchesFilter =
          filterLabel == 'All' ||
          a['filter'] == filterLabel ||
          // "This Week" also includes "Today"
          (filterLabel == 'This Week' && a['filter'] == 'Today') ||
          // "This Month" includes everything
          (filterLabel == 'This Month');

      // Severity filter
      final matchesSeverity =
          _selectedSeverity == null || a['severity'] == _selectedSeverity;

      // Search filter
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          a['ip'].toLowerCase().contains(q) ||
          a['type'].toLowerCase().contains(q) ||
          (a['country'] ?? '').toLowerCase().contains(q);

      return matchesFilter && matchesSeverity && matchesSearch;
    }).toList();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return const Color(0xFFE5AC07);
      default:
        return Colors.greenAccent;
    }
  }

  Color _severityBg(String severity) {
    switch (severity) {
      case 'High':
        return Colors.red.withOpacity(0.15);
      case 'Medium':
        return const Color(0xFFE5AC07).withOpacity(0.15);
      default:
        return Colors.green.withOpacity(0.15);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attacks = _filteredAttacks;

    return SafeArea(
      child: Column(
        children: [
          // ── Top Bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Hamburger icon
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(
                    Icons.menu,
                    color: Color(0xFFE5AC07),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 118),
                // Title
                const Expanded(
                  child: Text(
                    'Attacks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Search icon — toggles search bar
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchOpen = !_searchOpen;
                      if (!_searchOpen) {
                        _searchQuery = '';
                        _searchController.clear();
                      }
                    });
                  },
                  child: Icon(
                    _searchOpen ? Icons.search_off : Icons.search,
                    color: _searchOpen
                        ? const Color(0xFFE5AC07)
                        : const Color(0xFFE5AC07),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // ── Search Bar (visible when search is open) ──────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _searchOpen ? 52 : 0,
            child: _searchOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search by IP, attack type or country…',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFE5AC07),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          17,
                          17,
                          17,
                        ).withOpacity(0.45),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5AC07), // golden when focused
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 26),

          // ── Filter Tabs: All / Today / This Week / This Month ─────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final selected = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE5AC07)
                          : const Color.fromARGB(
                              255,
                              17,
                              17,
                              17,
                            ).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: selected
                          ? null
                          : Border.all(
                              color: Colors.grey.withOpacity(0.45),
                              width: 0.8,
                            ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        color: selected ? Colors.black : Colors.grey[400],
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── Severity Summary Boxes: Low / Medium / High ───────────────
          Builder(
            builder: (context) {
              // Count by severity using time filter only (ignore severity filter for counts)
              final filterLabel = _filters[_selectedFilter];
              final timeFiltered = _allAttacks.where((a) {
                return filterLabel == 'All' ||
                    a['filter'] == filterLabel ||
                    (filterLabel == 'This Week' && a['filter'] == 'Today') ||
                    (filterLabel == 'This Month');
              }).toList();
              final lowCount = timeFiltered
                  .where((a) => a['severity'] == 'Low')
                  .length;
              final medCount = timeFiltered
                  .where((a) => a['severity'] == 'Medium')
                  .length;
              final highCount = timeFiltered
                  .where((a) => a['severity'] == 'High')
                  .length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSeverityBox(
                      'Low',
                      lowCount,
                      Colors.greenAccent,
                      Colors.green.withOpacity(0.12),
                    ),
                    const SizedBox(width: 8),
                    _buildSeverityBox(
                      'Medium',
                      medCount,
                      const Color(0xFFE5AC07),
                      const Color(0xFFE5AC07).withOpacity(0.12),
                    ),
                    const SizedBox(width: 8),
                    _buildSeverityBox(
                      'High',
                      highCount,
                      Colors.redAccent,
                      Colors.red.withOpacity(0.12),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // ── Attack List ───────────────────────────────────────────────
          Expanded(
            child: attacks.isEmpty
                ? Center(
                    child: Text(
                      'No attacks found.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: attacks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final a = attacks[i];
                      final severity = a['severity'] as String;
                      final borderColor = _severityColor(severity);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttackDetailScreen(attack: a),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              17,
                              17,
                              17,
                            ).withOpacity(0.45),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: borderColor.withOpacity(0.55),
                              width: 0.9,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Country flag with severity-colored border
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: borderColor.withOpacity(0.65),
                                    width: 1.3,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  a['flag'],
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // IP + country + attack type
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a['ip'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (a['country'] as String)
                                          .split(' ')
                                          .map(
                                            (w) => w.isNotEmpty
                                                ? w[0].toUpperCase() +
                                                      w.substring(1)
                                                : w,
                                          )
                                          .join(' '),
                                      style: const TextStyle(
                                        color: Color(0xFFE5AC07),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      a['type'],
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Time + severity badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    a['time'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _severityBg(severity),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      severity,
                                      style: TextStyle(
                                        color: _severityColor(severity),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Severity summary box (tappable)
  Widget _buildSeverityBox(String label, int count, Color color, Color bg) {
    final isSelected = _selectedSeverity == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedSeverity = isSelected ? null : label;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.22) : bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.35),
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(
                label == 'Low'
                    ? Icons.shield_outlined
                    : label == 'Medium'
                    ? Icons.warning_amber_rounded
                    : Icons.local_fire_department,
                color: color,
                size: 15,
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ATTACK DETAIL SCREEN ====================

class AttackDetailScreen extends StatelessWidget {
  final Map<String, dynamic> attack;
  const AttackDetailScreen({required this.attack, super.key});

  Color _severityColor(String s) {
    switch (s) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return const Color(0xFFE5AC07);
      default:
        return Colors.greenAccent;
    }
  }

  Color _severityBg(String s) {
    switch (s) {
      case 'High':
        return Colors.red.withOpacity(0.15);
      case 'Medium':
        return const Color(0xFFE5AC07).withOpacity(0.15);
      default:
        return Colors.green.withOpacity(0.15);
    }
  }

  IconData _severityIcon(String s) {
    switch (s) {
      case 'High':
        return Icons.local_fire_department;
      case 'Medium':
        return Icons.warning_amber_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  String _capitalize(String s) => s
      .split(' ')
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final severity = attack['severity'] as String;
    final status = attack['status'] as String;
    final commands = (attack['commands'] as List).cast<String>();
    final nextCmds = (attack['nextCommands'] as List).cast<String>();
    final color = _severityColor(severity);
    final isActive = status == 'active';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────────────────
          Positioned.fill(child: Container(color: Colors.black)),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFFE5AC07),
                          size: 22,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Attack Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Status badge
                      const SizedBox(width: 22),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hero card ───────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111).withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.55),
                              width: 0.9,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Flag
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color.withOpacity(0.65),
                                    width: 1.3,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  attack['flag'],
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attack['type'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _capitalize(attack['country']),
                                      style: const TextStyle(
                                        color: Color(0xFFE5AC07),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      attack['time'],
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Severity badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _severityBg(severity),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withOpacity(0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _severityIcon(severity),
                                      color: color,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      severity,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Info grid ───────────────────────────────────
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.4,
                          children: [
                            _infoTile(
                              Icons.computer,
                              'IP Address',
                              attack['ip'],
                            ),
                            _infoTile(
                              Icons.lan,
                              'Protocol',
                              attack['protocol'],
                            ),
                            _infoTile(
                              Icons.electrical_services,
                              'Port',
                              attack['port'],
                            ),
                            _infoTile(
                              Icons.repeat,
                              'Attempts',
                              attack['attempts'].toString(),
                            ),
                            _infoTile(
                              Icons.timer_outlined,
                              'Duration',
                              attack['duration'],
                            ),
                            _infoTile(
                              isActive ? Icons.wifi : Icons.wifi_off,
                              'Connection',
                              isActive ? 'Still Active' : 'Blocked',
                              valueColor: isActive
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Commands used ───────────────────────────────
                        _sectionLabel('Commands Used', Icons.terminal),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111).withOpacity(0.45),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: commands
                                .map(
                                  (cmd) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '›',
                                          style: TextStyle(
                                            color: Color(0xFFE5AC07),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            cmd,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Possible next commands ──────────────────────
                        _sectionLabel(
                          'Predicted Next Actions',
                          Icons.psychology_outlined,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on attack pattern analysis',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: nextCmds.asMap().entries.map((e) {
                              final idx = e.key + 1;
                              final cmd = e.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(
                                          0.15,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.redAccent.withOpacity(
                                            0.4,
                                          ),
                                          width: 0.8,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$idx',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        cmd,
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE5AC07), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE5AC07), size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
// ==================== LOGS TAB ====================

class LogsTab extends StatefulWidget {
  @override
  _LogsTabState createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];
  int _selectedFilter = 0;
  String? _selectedStatus; // null = all, 'connected', 'disconnected'
  bool _searchOpen = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allLogs = const [
    {
      'ip': '192.168.1.100',
      'country': 'Russia',
      'flag': '🇷🇺',
      'detail': 'SSH Brute Force',
      'time': 'May 16, 10:24 AM',
      'status': 'disconnected',
      'filter': 'Today',
    },
    {
      'ip': '192.168.1.101',
      'country': 'China',
      'flag': '🇨🇳',
      'detail': 'Failed login — admin',
      'time': 'May 16, 09:45 AM',
      'status': 'disconnected',
      'filter': 'Today',
    },
    {
      'ip': '203.0.113.45',
      'country': 'Netherlands',
      'flag': '🇳🇱',
      'detail': 'Web Login Attempt',
      'time': 'May 16, 09:30 AM',
      'status': 'connected',
      'filter': 'Today',
    },
    {
      'ip': '185.199.108.23',
      'country': 'Germany',
      'flag': '🇩🇪',
      'detail': 'Port Scan',
      'time': 'May 16, 08:55 AM',
      'status': 'disconnected',
      'filter': 'Today',
    },
    {
      'ip': '10.0.0.5',
      'country': 'Brazil',
      'flag': '🇧🇷',
      'detail': 'Payload captured — /etc/passwd',
      'time': 'May 15, 14:31 PM',
      'status': 'disconnected',
      'filter': 'This Week',
    },
    {
      'ip': '8.8.8.8',
      'country': 'United States',
      'flag': '🇺🇸',
      'detail': 'Port 22 probe',
      'time': 'May 15, 14:28 PM',
      'status': 'connected',
      'filter': 'This Week',
    },
    {
      'ip': '198.51.100.77',
      'country': 'Singapore',
      'flag': '🇸🇬',
      'detail': 'SQL Injection Attempt',
      'time': 'May 15, 11:02 AM',
      'status': 'disconnected',
      'filter': 'This Week',
    },
    {
      'ip': '172.16.0.55',
      'country': 'Germany',
      'flag': '🇩🇪',
      'detail': 'DDoS flood — auto-blocked',
      'time': 'May 14, 13:58 PM',
      'status': 'disconnected',
      'filter': 'This Month',
    },
    {
      'ip': '203.0.113.88',
      'country': 'United Kingdom',
      'flag': '🇬🇧',
      'detail': 'Directory Traversal',
      'time': 'May 13, 16:44 PM',
      'status': 'connected',
      'filter': 'This Month',
    },
    {
      'ip': '192.0.2.44',
      'country': 'France',
      'flag': '🇫🇷',
      'detail': 'Bad Bot detected',
      'time': 'May 12, 09:11 AM',
      'status': 'disconnected',
      'filter': 'This Month',
    },
  ];

  List<Map<String, dynamic>> get _filteredLogs {
    final filterLabel = _filters[_selectedFilter];
    return _allLogs.where((log) {
      final matchesFilter =
          filterLabel == 'All' ||
          log['filter'] == filterLabel ||
          (filterLabel == 'This Week' && log['filter'] == 'Today') ||
          (filterLabel == 'This Month');
      final matchesStatus =
          _selectedStatus == null || log['status'] == _selectedStatus;
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          (log['ip'] as String).toLowerCase().contains(q) ||
          (log['country'] as String).toLowerCase().contains(q) ||
          (log['detail'] as String).toLowerCase().contains(q);
      return matchesFilter && matchesStatus && matchesSearch;
    }).toList();
  }

  // Border accent color per status
  Color _statusBorderColor(String status) {
    return status == 'connected'
        ? Colors.greenAccent.withOpacity(0.55)
        : Colors.redAccent.withOpacity(0.55);
  }

  // Badge background
  Color _statusBg(String status) {
    return status == 'connected'
        ? Colors.green.withOpacity(0.15)
        : Colors.red.withOpacity(0.15);
  }

  // Badge text color
  Color _statusColor(String status) {
    return status == 'connected' ? Colors.greenAccent : Colors.redAccent;
  }

  // Badge icon
  IconData _statusIcon(String status) {
    return status == 'connected' ? Icons.link : Icons.link_off;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = _filteredLogs;

    return SafeArea(
      child: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(
                    Icons.menu,
                    color: Color(0xFFE5AC07),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 129),
                const Expanded(
                  child: Text(
                    'Logs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchOpen = !_searchOpen;
                      if (!_searchOpen) {
                        _searchQuery = '';
                        _searchController.clear();
                      }
                    });
                  },
                  child: Icon(
                    _searchOpen ? Icons.search_off : Icons.search,
                    color: const Color(0xFFE5AC07),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // ── Search Bar ────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _searchOpen ? 52 : 0,
            child: _searchOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search by IP, country or event…',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFE5AC07),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          17,
                          17,
                          17,
                        ).withOpacity(0.45),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5AC07),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // ── Filter Tabs: All / Today / This Week / This Month ─────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final selected = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE5AC07)
                          : const Color.fromARGB(
                              255,
                              17,
                              17,
                              17,
                            ).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: selected
                          ? null
                          : Border.all(
                              color: Colors.grey.withOpacity(0.45),
                              width: 0.8,
                            ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        color: selected ? Colors.black : Colors.grey[400],
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── Summary row: connected / disconnected counts ───────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCountChip(
                  icon: Icons.link,
                  label: 'Connected',
                  count: _allLogs.where((l) {
                    final fl = _filters[_selectedFilter];
                    return (fl == 'All' ||
                            l['filter'] == fl ||
                            (fl == 'This Week' && l['filter'] == 'Today') ||
                            fl == 'This Month') &&
                        l['status'] == 'connected';
                  }).length,
                  color: Colors.greenAccent,
                  bg: Colors.green.withOpacity(0.12),
                  isSelected: _selectedStatus == 'connected',
                  onTap: () => setState(() {
                    _selectedStatus = _selectedStatus == 'connected'
                        ? null
                        : 'connected';
                  }),
                ),
                const SizedBox(width: 10),
                _buildCountChip(
                  icon: Icons.link_off,
                  label: 'Disconnected',
                  count: _allLogs.where((l) {
                    final fl = _filters[_selectedFilter];
                    return (fl == 'All' ||
                            l['filter'] == fl ||
                            (fl == 'This Week' && l['filter'] == 'Today') ||
                            fl == 'This Month') &&
                        l['status'] == 'disconnected';
                  }).length,
                  color: Colors.redAccent,
                  bg: Colors.red.withOpacity(0.12),
                  isSelected: _selectedStatus == 'disconnected',
                  onTap: () => setState(() {
                    _selectedStatus = _selectedStatus == 'disconnected'
                        ? null
                        : 'disconnected';
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Log List ──────────────────────────────────────────────────
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      'No connections found.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      final status = log['status'] as String;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            17,
                            17,
                            17,
                          ).withOpacity(0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _statusBorderColor(status),
                            width: 0.9,
                          ),
                        ),
                        child: Row(
                          children: [
                            // ── Country flag in circle ──────────────────
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _statusBorderColor(status),
                                  width: 1.2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                log['flag'],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // ── IP (primary) + country + event ──────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // IP address — most prominent
                                  Text(
                                    log['ip'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Country name
                                  Text(
                                    log['country'],
                                    style: const TextStyle(
                                      color: Color(0xFFE5AC07),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Event detail
                                  Text(
                                    log['detail'],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // ── Time + status badge ─────────────────────
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  log['time'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusBg(status),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _statusIcon(status),
                                        color: _statusColor(status),
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        status == 'connected'
                                            ? 'Connected'
                                            : 'Disconnected',
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Small chip showing count of connected / disconnected IPs (tappable)
  Widget _buildCountChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required Color bg,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.22) : bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.35),
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PROFILE TAB ====================

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  bool emailAlerts = true;
  bool twoFactorEnabled = false;
  bool _togglingTwoFactor = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (mounted) {
      final data = doc.data() ?? {};
      setState(() {
        userData = data;
        twoFactorEnabled = data['twoFactorEnabled'] == true;
      });
    }
  }

  /// Toggles 2FA: if enabling, navigates to the 2FA setup screen.
  /// If disabling, asks for confirmation then updates Firestore directly.
  Future<void> _toggleTwoFactor() async {
    if (_togglingTwoFactor) return;

    if (!twoFactorEnabled) {
      // ── ENABLE: check that a phone number exists first ──────────────────
      final phone = userData?['phone'] as String?;
      if (phone == null || phone.trim().isEmpty) {
        _showSnack(
          'Please add a phone number in Profile Information first.',
          success: false,
        );
        return;
      }
      // Navigate to 2FA setup screen; refresh on return
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFactorSetupScreen(phoneNumber: phone.trim()),
        ),
      );
      if (result == true && mounted) {
        setState(() => twoFactorEnabled = true);
        _showSnack('Two-Factor Authentication enabled.', success: true);
      }
    } else {
      // ── DISABLE: confirmation dialog ─────────────────────────────────────
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Disable 2FA?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will remove the extra layer of security from your account. Are you sure?',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Disable',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        setState(() => _togglingTwoFactor = true);
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .set({'twoFactorEnabled': false}, SetOptions(merge: true));
          if (mounted) {
            setState(() => twoFactorEnabled = false);
            _showSnack('Two-Factor Authentication disabled.', success: true);
          }
        } catch (_) {
          if (mounted) {
            _showSnack('Failed to update 2FA setting.', success: false);
          }
        } finally {
          if (mounted) setState(() => _togglingTwoFactor = false);
        }
      }
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userData != null
        ? '${userData!['lastName'] ?? ''} ${userData!['firstName'] ?? ''}'
              .trim()
        : 'Admin User';
    final email = user?.email ?? 'admin@honeypct.local';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/profile_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFFE5AC07),
                          size: 26,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileInfoScreen(),
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFE5AC07),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Avatar + Name + Email ─────────────────────────────────
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5AC07),
                      width: 2.5,
                    ),
                    color: const Color(0xFFE5AC07),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/user_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  displayName.isEmpty ? 'Admin User' : displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),

                const SizedBox(height: 28),

                // ── Scrollable Settings List ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account section
                        _sectionLabel('Account'),
                        const SizedBox(height: 8),
                        _buildMenuCard([
                          _menuRow(
                            icon: Icons.person_outline,
                            label: 'Profile Information',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileInfoScreen(),
                              ),
                            ),
                          ),
                          _divider(),
                          _menuRow(
                            icon: Icons.lock_outline,
                            label: 'Change Password',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangePasswordScreen(),
                              ),
                            ),
                          ),
                          _divider(),
                          _menuRow(
                            icon: Icons.security_outlined,
                            label: 'Two-Factor Authentication',
                            trailing: _togglingTwoFactor
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFE5AC07),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    twoFactorEnabled ? 'On' : 'Off',
                                    style: TextStyle(
                                      color: twoFactorEnabled
                                          ? Colors.greenAccent
                                          : Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            onTap: _toggleTwoFactor,
                          ),
                          _divider(),
                          _menuRow(
                            icon: Icons.vpn_key_outlined,
                            label: 'API Tokens',
                            onTap: () {},
                          ),
                          _divider(),
                          _menuRow(
                            icon: Icons.devices_outlined,
                            label: 'Active Sessions',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActiveSessionsScreen(),
                              ),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Preferences section
                        _sectionLabel('Preferences'),
                        const SizedBox(height: 8),
                        _buildMenuCard([
                          _menuRow(
                            icon: Icons.palette_outlined,
                            label: 'Theme',
                            trailing: Text(
                              'Dark / Yellow',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {},
                          ),
                          _divider(),
                          _menuRow(
                            icon: Icons.language_outlined,
                            label: 'Language',
                            trailing: Text(
                              'English',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ]),

                        const SizedBox(height: 32),

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.15),
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.redAccent.withOpacity(0.4),
                                  width: 0.8,
                                ),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 0.8),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE5AC07), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.12), indent: 50);
  }
}

// ==================== SESSION SERVICE ====================

class SessionService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> createSession() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final deviceName = await _detectPlatform();
    final location = await _fetchLocationInfo();
    final sessionRef = _db.collection('sessions').doc();

    await sessionRef.set({
      'sessionId': sessionRef.id,
      'userId': user.uid,
      'device': deviceName,
      'ipAddress': location['ip'],
      'country': location['country'],
      'city': location['city'],
      'lastActive': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> terminateSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).delete();
  }

  static Future<void> terminateAllSessions() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snap = await _db
        .collection('sessions')
        .where('userId', isEqualTo: user.uid)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) batch.delete(doc.reference);
    await batch.commit();
  }

  static Stream<QuerySnapshot> sessionsStream(String uid) {
    return _db
        .collection('sessions')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  static Future<String> _detectPlatform() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.name;
      }
    } catch (_) {}
    return 'Unknown Device';
  }

  static Future<Map<String, String>> _fetchLocationInfo() async {
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'ip': data['query'] ?? '0.0.0.0',
          'country': data['country'] ?? 'Unknown',
          'city': data['city'] ?? '',
        };
      }
    } catch (_) {}
    return {'ip': '0.0.0.0', 'country': 'Unknown', 'city': ''};
  }
}

// ==================== ACTIVE SESSIONS SCREEN ====================

class ActiveSessionsScreen extends StatefulWidget {
  @override
  _ActiveSessionsScreenState createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Tracks which session is currently being terminated
  final Set<String> _terminating = {};

  // ── Format a Firestore Timestamp ────────────────────────────────────────
  String _formatTs(dynamic ts) {
    if (ts == null) return 'Just now';
    try {
      final DateTime dt = (ts as dynamic).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '-';
    }
  }

  // ── Device icon based on device string ─────────────────────────────────
  IconData _deviceIcon(String device) {
    final d = device.toLowerCase();
    if (d.contains('ios') || d.contains('iphone') || d.contains('android')) {
      return Icons.phone_android;
    }
    if (d.contains('mac') || d.contains('windows') || d.contains('linux')) {
      return Icons.laptop;
    }
    if (d.contains('tablet') || d.contains('ipad')) {
      return Icons.tablet_android;
    }
    return Icons.devices;
  }

  // ── Terminate a single session ──────────────────────────────────────────
  Future<void> _terminate(String sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Terminate Session?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will immediately end that session. The device will need to log in again.',
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Terminate',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _terminating.add(sessionId));
    try {
      await SessionService.terminateSession(sessionId);
    } catch (_) {
      if (mounted) _showSnack('Failed to terminate session.', success: false);
    } finally {
      if (mounted) setState(() => _terminating.remove(sessionId));
    }
  }

  // ── Terminate ALL sessions ──────────────────────────────────────────────
  Future<void> _terminateAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out All Devices?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'All active sessions will be terminated. Every device will need to log in again.',
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out All',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await SessionService.terminateAllSessions();
      if (mounted) {
        _showSnack('All sessions terminated.', success: true);
      }
    } catch (_) {
      if (mounted) _showSnack('Failed to terminate sessions.', success: false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Not logged in.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/profile_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.62)),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFFE5AC07),
                          size: 22,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Active Sessions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Sign out all button
                      GestureDetector(
                        onTap: _terminateAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.4),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'Sign Out All',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Info banner ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5AC07).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5AC07).withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFE5AC07),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'These are all devices currently logged into your account. Terminate any session you don\'t recognise.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Sessions list (real-time stream) ─────────────────────
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: SessionService.sessionsStream(user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE5AC07),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading sessions.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      // Sort client-side by lastActive descending (avoids Firestore composite index)
                      final sortedDocs = [...docs];
                      sortedDocs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTs = aData['lastActive'];
                        final bTs = bData['lastActive'];
                        if (aTs == null && bTs == null) return 0;
                        if (aTs == null) return 1;
                        if (bTs == null) return -1;
                        try {
                          return (bTs as dynamic).toDate().compareTo(
                            (aTs as dynamic).toDate(),
                          );
                        } catch (_) {
                          return 0;
                        }
                      });

                      if (sortedDocs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.devices_other,
                                color: Colors.grey[700],
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No active sessions found.',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sessions are created when you log in.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: sortedDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final data =
                              sortedDocs[i].data() as Map<String, dynamic>;
                          final sessionId =
                              data['sessionId'] as String? ?? sortedDocs[i].id;
                          final device =
                              data['device'] as String? ?? 'Unknown Device';
                          final ip = data['ipAddress'] as String? ?? '-';
                          final country = data['country'] as String? ?? '';
                          final city = data['city'] as String? ?? '';
                          final location = [
                            city,
                            country,
                          ].where((v) => v.isNotEmpty).join(', ');
                          final lastActive = data['lastActive'];
                          final createdAt = data['createdAt'];
                          final isTerminating = _terminating.contains(
                            sessionId,
                          );
                          final isCurrentSession = i == 0;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111).withOpacity(0.55),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCurrentSession
                                    ? const Color(0xFFE5AC07).withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.15),
                                width: isCurrentSession ? 1.2 : 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                // ── Device icon ───────────────────────────
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isCurrentSession
                                        ? const Color(
                                            0xFFE5AC07,
                                          ).withOpacity(0.12)
                                        : Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCurrentSession
                                          ? const Color(
                                              0xFFE5AC07,
                                            ).withOpacity(0.4)
                                          : Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _deviceIcon(device),
                                    color: isCurrentSession
                                        ? const Color(0xFFE5AC07)
                                        : Colors.grey[400],
                                    size: 22,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // ── Session details ───────────────────────
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              device,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCurrentSession)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFE5AC07,
                                                ).withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE5AC07,
                                                  ).withOpacity(0.4),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Current',
                                                style: TextStyle(
                                                  color: Color(0xFFE5AC07),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // IP
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.wifi,
                                            color: Colors.grey[600],
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            ip,
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),

                                      // Country / City
                                      if (location.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.grey[600],
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              location,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 3),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.grey[600],
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Active: ${_formatTs(lastActive)}  ·  Started: ${_formatTs(createdAt)}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // ── Terminate button ──────────────────────
                                GestureDetector(
                                  onTap: isTerminating
                                      ? null
                                      : () => _terminate(sessionId),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.redAccent.withOpacity(
                                          0.35,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: isTerminating
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.redAccent,
                                              strokeWidth: 1.5,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.power_settings_new,
                                            color: Colors.redAccent,
                                            size: 16,
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

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SHARED HEADER WIDGET ====================

Widget _buildHeader(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, color: Colors.white, size: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
      ],
    ),
  );
}

// ==================== PROFILE INFORMATION SCREEN ====================

class ProfileInfoScreen extends StatefulWidget {
  @override
  _ProfileInfoScreenState createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool _loading = true;
  bool _savingPhone = false;

  // Only the phone number is editable
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (mounted) {
      final data = doc.data() ?? {};
      setState(() {
        userData = data;
        _phoneController.text = data['phone'] ?? '';
        _loading = false;
      });
    }
  }

  /// Updates only the phone number in Firestore
  Future<void> _updatePhone() async {
    if (user == null) return;
    final newPhone = _phoneController.text.trim();
    if (newPhone.isEmpty) {
      _showSnack('Phone number cannot be empty', success: false);
      return;
    }
    setState(() => _savingPhone = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'phone': newPhone});
      if (mounted) {
        setState(() => userData = {...?userData, 'phone': newPhone});
        _showSnack('Phone number updated successfully', success: true);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to update phone number', success: false);
    } finally {
      if (mounted) setState(() => _savingPhone = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Formats a Firestore Timestamp to a readable date string
  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '-';
    try {
      final DateTime dt = (ts as dynamic).toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = (userData?['name'] as String? ?? '').trim();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/profile_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFFE5AC07),
                          size: 22,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Profile Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Avatar + name + email ──────────────────────────────────
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5AC07),
                      width: 2.5,
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/user_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (!_loading &&
                    ((userData?['lastName'] ?? '').isNotEmpty ||
                        (userData?['firstName'] ?? '').isNotEmpty))
                  Text(
                    '${userData?['lastName'] ?? ''} ${userData?['firstName'] ?? ''}'
                        .trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),

                const SizedBox(height: 24),

                // ── Body ──────────────────────────────────────────────────
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE5AC07),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Personal Details (read-only) ─────────────
                              _piSectionLabel('Personal Details'),
                              const SizedBox(height: 12),
                              _piReadOnly(
                                value:
                                    '${userData?['lastName'] ?? ''} ${userData?['firstName'] ?? ''}'
                                        .trim()
                                        .isEmpty
                                    ? '-'
                                    : '${userData?['lastName'] ?? ''} ${userData?['firstName'] ?? ''}'
                                          .trim(),
                                label: 'Full Name',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 24),

                              // ── Contact (phone editable, email locked) ───
                              _piSectionLabel('Contact'),
                              const SizedBox(height: 12),

                              // Editable phone field with inline Update button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      cursorColor: const Color(0xFFE5AC07),
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        labelStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.phone_outlined,
                                          color: Color(0xFFE5AC07),
                                          size: 20,
                                        ),
                                        filled: true,
                                        fillColor: const Color(
                                          0xFF111111,
                                        ).withOpacity(0.8),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 16,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.2),
                                            width: 0.8,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5AC07),
                                            width: 1.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE5AC07,
                                        ),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: _savingPhone
                                          ? null
                                          : _updatePhone,
                                      child: _savingPhone
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                color: Colors.black,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Update',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _piReadOnly(
                                value: user?.email ?? '-',
                                label: 'Email',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 24),

                              // ── Account Info (read-only) ──────────────────
                              _piSectionLabel('Account Info'),
                              const SizedBox(height: 12),
                              _piReadOnly(
                                value: user?.uid ?? '-',
                                label: 'User ID',
                                icon: Icons.fingerprint,
                                monospace: true,
                              ),
                              const SizedBox(height: 12),
                              _piReadOnly(
                                value: _formatTimestamp(userData?['createdAt']),
                                label: 'Member Since',
                                icon: Icons.calendar_today_outlined,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _piSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
    ),
  );

  Widget _piReadOnly({
    required String value,
    required String label,
    required IconData icon,
    bool monospace = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: monospace ? 11 : 13,
                    fontFamily: monospace ? 'monospace' : null,
                    letterSpacing: monospace ? 0.5 : null,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_outline, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}

// ==================== CHANGE PASSWORD SCREEN ====================

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;

  int get _strength {
    final p = _newPasswordController.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return const Color(0xFFE5AC07);
      case 4:
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  String get _strengthLabel {
    switch (_strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields', success: false);
      return;
    }
    if (newPass != confirm) {
      _showSnack('New passwords do not match', success: false);
      return;
    }
    if (newPass.length < 6) {
      _showSnack('Password must be at least 6 characters', success: false);
      return;
    }
    if (newPass == current) {
      _showSnack('New password must differ from current', success: false);
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: current,
      );
      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPass);
      if (mounted) {
        _showSnack('Password updated successfully', success: true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'New password is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please log out and log back in first';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }
      if (mounted) _showSnack(message, success: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/profile_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFFE5AC07),
                          size: 22,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Lock icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE5AC07).withOpacity(0.12),
                    border: Border.all(
                      color: const Color(0xFFE5AC07).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFE5AC07),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Update your password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use a strong password to keep your account safe',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cpField(
                          controller: _currentPasswordController,
                          label: 'Current Password',
                          show: _showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                        ),
                        const SizedBox(height: 14),
                        _cpField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          show: _showNew,
                          onToggle: () => setState(() => _showNew = !_showNew),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_newPasswordController.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildStrengthBar(),
                        ],
                        const SizedBox(height: 14),
                        _cpField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          show: _showConfirm,
                          onToggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_confirmPasswordController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildMatchIndicator(),
                        ],
                        const SizedBox(height: 14),
                        _buildRequirements(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE5AC07),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _loading ? null : _changePassword,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cpField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: const Color(0xFFE5AC07),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFFE5AC07),
          size: 20,
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: show ? const Color(0xFFE5AC07) : Colors.grey[500],
            size: 20,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFF111111).withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5AC07), width: 1.3),
        ),
      ),
    );
  }

  Widget _buildStrengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < _strength
                      ? _strengthColor
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Text(
          _strengthLabel,
          style: TextStyle(
            color: _strengthColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchIndicator() {
    final match =
        _newPasswordController.text == _confirmPasswordController.text;
    return Row(
      children: [
        Icon(
          match ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: match ? Colors.greenAccent : Colors.redAccent,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          match ? 'Passwords match' : 'Passwords do not match',
          style: TextStyle(
            color: match ? Colors.greenAccent : Colors.redAccent,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    final p = _newPasswordController.text;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _cpReq('At least 8 characters', p.length >= 8),
          _cpReq('One uppercase letter', p.contains(RegExp(r'[A-Z]'))),
          _cpReq('One number', p.contains(RegExp(r'[0-9]'))),
          _cpReq(
            'One special character',
            p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
          ),
        ],
      ),
    );
  }

  Widget _cpReq(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: met ? Colors.greenAccent : Colors.grey[600],
            size: 13,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.greenAccent : Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TWO-FACTOR SETUP SCREEN ====================
// Shown when the user enables 2FA from the Profile tab.
// Sends a verification code to their phone, verifies it, then
// writes twoFactorEnabled = true to Firestore.

class TwoFactorSetupScreen extends StatefulWidget {
  final String phoneNumber;
  const TwoFactorSetupScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  _TwoFactorSetupScreenState createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final _auth = FirebaseAuth.instance;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _verificationId;
  bool _codeSent = false;
  bool _sending = false;
  bool _verifying = false;
  bool _resendAllowed = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _resendAllowed = false;
      _resendCountdown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _resendAllowed = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _sendCode() async {
    setState(() => _sending = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          await _enableTwoFactor(cred);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            _showSnack(e.message ?? 'Verification failed.', success: false);
            setState(() => _sending = false);
          }
        },
        codeSent: (String verificationId, int? _) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _sending = false;
            });
            _startCountdown();
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (_) {
      if (mounted) {
        _showSnack('Failed to send code.', success: false);
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text.trim()).join();
    if (code.length < 6) {
      _showSnack('Enter all 6 digits.', success: false);
      return;
    }
    if (_verificationId == null) {
      _showSnack('Session expired. Resend.', success: false);
      return;
    }
    setState(() => _verifying = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _enableTwoFactor(cred);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showSnack(
          e.code == 'invalid-verification-code'
              ? 'Incorrect code. Try again.'
              : (e.message ?? 'Verification failed.'),
          success: false,
        );
        for (final c in _controllers) c.clear();
        _focusNodes.first.requestFocus();
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _enableTwoFactor(PhoneAuthCredential cred) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      // Link the phone credential to the existing email/password account.
      // Do NOT use reauthenticateWithCredential here — that only works when
      // the user's primary sign-in method is phone, which it isn't.
      await user.linkWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      // 'provider-already-linked' means phone is already linked — that's fine,
      // the user is just re-enabling 2FA, so we can proceed.
      if (e.code != 'provider-already-linked') {
        if (mounted) {
          _showSnack(e.message ?? 'Failed to verify phone.', success: false);
          setState(() => _verifying = false);
        }
        return;
      }
    }
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'twoFactorEnabled': true},
      SetOptions(merge: true), // safe even if field doesn't exist yet
    );
    if (mounted) Navigator.pop(context, true);
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF111111).withOpacity(0.8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.25),
              width: 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5AC07), width: 1.5),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5)
            _focusNodes[index + 1].requestFocus();
          if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
          if (_controllers.every((c) => c.text.isNotEmpty)) _verifyCode();
        },
      ),
    );
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/profile_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFFE5AC07),
                          size: 22,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Two-Factor Authentication',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Shield icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE5AC07).withOpacity(0.12),
                            border: Border.all(
                              color: const Color(0xFFE5AC07).withOpacity(0.45),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFFE5AC07),
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Verify your phone number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _sending
                              ? 'Sending verification code…'
                              : 'A 6-digit code was sent to\n${widget.phoneNumber}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // OTP boxes
                        if (_codeSent)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (i) => Padding(
                                padding: EdgeInsets.only(right: i < 5 ? 10 : 0),
                                child: _otpBox(i),
                              ),
                            ),
                          ),

                        if (_sending && !_codeSent) ...[
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(
                            color: Color(0xFFE5AC07),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Verify button
                        if (_codeSent)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE5AC07),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _verifying ? null : _verifyCode,
                              child: _verifying
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verify & Enable 2FA',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Resend
                        if (_codeSent)
                          GestureDetector(
                            onTap: _resendAllowed ? _sendCode : null,
                            child: Text(
                              _resendAllowed
                                  ? 'Resend code'
                                  : 'Resend in ${_resendCountdown}s',
                              style: TextStyle(
                                color: _resendAllowed
                                    ? const Color(0xFFE5AC07)
                                    : Colors.grey[600],
                                fontSize: 13,
                                fontWeight: _resendAllowed
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                decoration: _resendAllowed
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          ),

                        const SizedBox(height: 36),

                        // Info note
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111).withOpacity(0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFE5AC07),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'After enabling 2FA, every login will require a '
                                  'verification code sent to your registered phone number.',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TWO-FACTOR VERIFY SCREEN ====================
// Used at LOGIN time when twoFactorEnabled == true in Firestore.
// Place this after successful email/password auth in your login screen:
//
//   final doc = await FirebaseFirestore.instance
//       .collection('users').doc(user.uid).get();
//   if (doc.data()?['twoFactorEnabled'] == true) {
//     Navigator.pushReplacement(context,
//       MaterialPageRoute(builder: (_) =>
//         TwoFactorVerifyScreen(phoneNumber: doc.data()!['phone'])));
//   } else {
//     Navigator.pushReplacementNamed(context, '/dashboard');
//   }

class TwoFactorVerifyScreen extends StatefulWidget {
  final String phoneNumber;
  const TwoFactorVerifyScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  _TwoFactorVerifyScreenState createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends State<TwoFactorVerifyScreen> {
  final _auth = FirebaseAuth.instance;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _verificationId;
  bool _codeSent = false;
  bool _sending = false;
  bool _verifying = false;
  bool _resendAllowed = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _resendAllowed = false;
      _resendCountdown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _resendAllowed = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _sendCode() async {
    setState(() => _sending = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          await _grantAccess(cred);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            _showSnack(e.message ?? 'Verification failed.', success: false);
            setState(() => _sending = false);
          }
        },
        codeSent: (String verificationId, int? _) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _sending = false;
            });
            _startCountdown();
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (_) {
      if (mounted) {
        _showSnack('Failed to send code.', success: false);
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text.trim()).join();
    if (code.length < 6) {
      _showSnack('Enter all 6 digits.', success: false);
      return;
    }
    if (_verificationId == null) {
      _showSnack('Session expired. Resend.', success: false);
      return;
    }
    setState(() => _verifying = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _grantAccess(cred);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showSnack(
          e.code == 'invalid-verification-code'
              ? 'Incorrect code. Try again.'
              : (e.message ?? 'Verification failed.'),
          success: false,
        );
        for (final c in _controllers) c.clear();
        _focusNodes.first.requestFocus();
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _grantAccess(PhoneAuthCredential cred) async {
    await _auth.currentUser?.reauthenticateWithCredential(cred);
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF111111).withOpacity(0.8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.25),
              width: 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5AC07), width: 1.5),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5)
            _focusNodes[index + 1].requestFocus();
          if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
          if (_controllers.every((c) => c.text.isNotEmpty)) _verifyCode();
        },
      ),
    );
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/profile_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Center(
                    child: Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE5AC07).withOpacity(0.12),
                            border: Border.all(
                              color: const Color(0xFFE5AC07).withOpacity(0.45),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_open_outlined,
                            color: Color(0xFFE5AC07),
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Two-Factor Authentication',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _sending
                              ? 'Sending verification code…'
                              : 'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        if (_codeSent)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (i) => Padding(
                                padding: EdgeInsets.only(right: i < 5 ? 10 : 0),
                                child: _otpBox(i),
                              ),
                            ),
                          ),

                        if (_sending && !_codeSent) ...[
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(
                            color: Color(0xFFE5AC07),
                          ),
                        ],

                        const SizedBox(height: 32),

                        if (_codeSent)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE5AC07),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _verifying ? null : _verifyCode,
                              child: _verifying
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Confirm & Continue',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        if (_codeSent)
                          GestureDetector(
                            onTap: _resendAllowed ? _sendCode : null,
                            child: Text(
                              _resendAllowed
                                  ? 'Resend code'
                                  : 'Resend in ${_resendCountdown}s',
                              style: TextStyle(
                                color: _resendAllowed
                                    ? const Color(0xFFE5AC07)
                                    : Colors.grey[600],
                                fontSize: 13,
                                fontWeight: _resendAllowed
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                decoration: _resendAllowed
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
