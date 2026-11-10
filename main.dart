import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const TribesApp());

const _gold = Color(0xFFE8B84A);
const _orange = Color(0xFFE8501C);
const _bg = Color(0xFFF4F5F8);
const bannerColors = <Color>[
  Color(0xFF111111), Color(0xFF1B4D2E), Color(0xFF12315F),
  Color(0xFF5B1020), Color(0xFF4A2A6A), Color(0xFF0E5560),
];

class Tribe {
  String name;
  int score;
  Color color;
  String? image;
  Tribe(this.name, this.score, this.color);
}

class TribesApp extends StatelessWidget {
  const TribesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        builder: (c, w) => Directionality(textDirection: TextDirection.rtl, child: w!),
        home: const TribesPage(),
      );
}

String ar(String s) {
  const d = '٠١٢٣٤٥٦٧٨٩';
  return s.split('').map((c) {
    final i = '0123456789'.indexOf(c);
    return i >= 0 ? d[i] : c;
  }).join();
}

int? parseNumber(String s) {
  var t = s.trim();
  const d = '٠١٢٣٤٥٦٧٨٩';
  for (int i = 0; i < 10; i++) {
    t = t.replaceAll(d[i], '$i');
  }
  return int.tryParse(t);
}

class TribesPage extends StatefulWidget {
  const TribesPage({super.key});
  @override
  State<TribesPage> createState() => _TribesPageState();
}

class _TribesPageState extends State<TribesPage> {
  final List<Tribe> tribes = [
    Tribe('ال مره', 100, bannerColors[0]),
    Tribe('الدوسري', 51, bannerColors[1]),
    Tribe('الرشيدي', 0, bannerColors[2]),
    Tribe('الهاشمي', 0, bannerColors[3]),
    Tribe('العتيبي', 0, bannerColors[4]),
    Tribe('الحربي', 0, bannerColors[5]),
    Tribe('القرني', 0, bannerColors[0]),
    Tribe('القحطاني', 0, bannerColors[1]),
  ];
  final controller = TextEditingController();
  double zoom = 1.0;
  bool bright = true, sound = true, full = false, running = false;
  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (running) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _sort() => tribes.sort((a, b) => b.score.compareTo(a.score));

  void _add() {
    final name = controller.text.trim();
    if (name.isEmpty || name.length > 34) return;
    setState(() {
      tribes.add(Tribe(name, 0, bannerColors[tribes.length % bannerColors.length]));
      controller.clear();
    });
  }

  String get _time =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _toggleFull() {
    full = !full;
    SystemChrome.setEnabledSystemUIMode(full ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
    setState(() {});
  }

  void _ranking() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('الترتيب'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(shrinkWrap: true, children: [
            for (int i = 0; i < tribes.length && i < 10; i++)
              ListTile(
                dense: true,
                leading: Text(ar('${i + 1}'), style: const TextStyle(fontWeight: FontWeight.bold)),
                title: Text(tribes[i].name),
                trailing: Text(ar('${tribes[i].score}')),
              ),
          ]),
        ),
      ),
    );
  }

  void _openControl(Tribe t) {
    final numCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void change(int v) {
            setState(() {
              t.score += v;
              _sort();
            });
            setSheet(() {});
          }

          void fromKeyboard(int sign) {
            final v = parseNumber(numCtrl.text);
            if (v == null) return;
            change(sign * v.abs());
            numCtrl.clear();
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(t.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Text(ar('${t.score}'), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _orange)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: numCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22),
                      decoration: InputDecoration(
                        hintText: 'اكتب الرقم',
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => fromKeyboard(1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                    onPressed: () => fromKeyboard(1),
                    child: const Text('زوّد'),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                    onPressed: () => fromKeyboard(-1),
                    child: const Text('اخصم'),
                  ),
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: [
                  for (final v in [-10, -5, -1, 1, 5, 10])
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: v < 0 ? Colors.grey : _orange, foregroundColor: Colors.white),
                      onPressed: () => change(v),
                      child: Text(v > 0 ? '+$v' : '$v'),
                    ),
                ]),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text('اختر صورة البانر'),
                  onPressed: () async {
                    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (x != null) {
                      setState(() => t.image = x.path);
                      setSheet(() {});
                    }
                  },
                ),
                if (t.image != null)
                  TextButton(
                    onPressed: () {
                      setState(() => t.image = null);
                      setSheet(() {});
                    },
                    child: const Text('إزالة الصورة'),
                  ),
                const Text('لون البانر'),
                const SizedBox(height: 6),
                Wrap(spacing: 10, children: [
                  for (final c in bannerColors)
                    GestureDetector(
                      onTap: () {
                        setState(() => t.color = c);
                        setSheet(() {});
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: c,
                        child: t.color == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    ),
                ]),
                TextButton(
                  onPressed: () {
                    setState(() => tribes.remove(t));
                    Navigator.pop(ctx);
                  },
                  child: const Text('حذف القبيلة', style: TextStyle(color: Colors.red)),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _mini(IconData i, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          child: CircleAvatar(radius: 17, backgroundColor: Colors.white70, child: Icon(i, size: 20, color: Colors.black87)),
        ),
      );

  Widget _pill(String text, {IconData? icon}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.85), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          if (icon != null) ...[const SizedBox(width: 4), Icon(icon, size: 16)],
        ]),
      );

  Widget _banner() {
    final t = tribes.isEmpty ? null : tribes.first;
    return SizedBox(
      height: 230,
      child: Stack(fit: StackFit.expand, children: [
        if (t != null && t.image != null)
          Image.file(File(t.image!), fit: BoxFit.cover)
        else
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Color.alphaBlend(Colors.white24, t?.color ?? bannerColors[0]), Colors.black],
              ),
            ),
            child: Opacity(
              opacity: .18,
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                for (int r = 0; r < 4; r++)
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    for (int c = 0; c < 9; c++) const Icon(Icons.diamond, size: 14, color: _gold),
                  ]),
              ]),
            ),
          ),
        Positioned(top: 0, left: 0, right: 0, child: Container(height: 4, color: _gold)),
        Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 4, color: _gold)),
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 40, 56, 40),
          child: WavingFlag(name: t?.name ?? '', color: t?.color ?? bannerColors[0], scale: zoom),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: Column(children: [
            _mini(Icons.zoom_in, () => setState(() => zoom = (zoom + 0.1).clamp(0.6, 1.4))),
            _mini(Icons.zoom_out, () => setState(() => zoom = (zoom - 0.1).clamp(0.6, 1.4))),
          ]),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(onTap: _ranking, child: _pill('الترتيب الأسبوعي', icon: Icons.emoji_events)),
            const SizedBox(height: 8),
            _mini(Icons.fullscreen, _toggleFull),
            _mini(Icons.wb_sunny_outlined, () => setState(() => bright = !bright)),
            _mini(sound ? Icons.volume_up : Icons.volume_off, () => setState(() => sound = !sound)),
          ]),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() => running = !running),
              onLongPress: () => setState(() {
                seconds = 0;
                running = false;
              }),
              child: _pill('الجولة ${ar(_time)}', icon: running ? Icons.pause : Icons.play_arrow),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _tile(Tribe t, bool first) => GestureDetector(
        onTap: () => _openControl(t),
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: first ? const Color(0xFFFBEDEA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: first ? const Color(0xFFE9B7A8) : const Color(0xFFD9DCE3)),
          ),
          child: Row(children: [
            const Icon(Icons.diamond, size: 12, color: _gold),
            const SizedBox(width: 8),
            Text(t.name, style: TextStyle(fontSize: 17 * zoom, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              width: 64,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: first ? _orange : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: first ? null : Border.all(color: const Color(0xFFC9CCD4)),
              ),
              child: Text(ar('${t.score}'),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: first ? Colors.white : Colors.black)),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    _sort();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        SafeArea(
          top: false,
          child: Column(children: [
            Container(color: Colors.black, height: MediaQuery.of(context).padding.top),
            _banner(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 6),
                itemCount: tribes.length,
                itemBuilder: (_, i) => _tile(tribes[i], i == 0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLength: 34,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'اكتب اسم القبيلة',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: _add,
                  child: const Text('إضافة'),
                ),
              ]),
            ),
          ]),
        ),
        IgnorePointer(child: Container(color: Colors.black.withOpacity(bright ? 0 : 0.45))),
      ]),
    );
  }
}


class WavingFlag extends StatefulWidget {
  final String name;
  final Color color;
  final double scale;
  const WavingFlag({super.key, required this.name, required this.color, this.scale = 1});
  @override
  State<WavingFlag> createState() => _WavingFlagState();
}

class _WavingFlagState extends State<WavingFlag> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _FlagPainter(widget.name, widget.color, c.value, widget.scale),
        ),
      );
}

class _FlagPainter extends CustomPainter {
  final String name;
  final Color color;
  final double t;
  final double scale;
  _FlagPainter(this.name, this.color, this.t, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    const poleW = 7.0;
    const strips = 70;
    final flagW = size.width - poleW;
    final top = size.height * 0.12;
    final flagH = size.height * 0.66;
    final amp = size.height * 0.05;
    final sw = flagW / strips;
    final cloth = Rect.fromLTWH(0, top, flagW, flagH);
    final base = Color.lerp(color, Colors.white, .1)!;
    final clothPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [base, Color.lerp(base, Colors.black, .35)!],
      ).createShader(cloth);
    final border = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    TextPainter mk(double f) => TextPainter(
          text: TextSpan(
            text: name,
            style: TextStyle(
              fontSize: f,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF2C14E),
              shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout();
    final maxW = flagW * 0.84;
    var tp = mk(flagH * 0.5 * scale);
    if (tp.width > maxW) tp = mk(flagH * 0.5 * scale * maxW / tp.width);
    final textPos = Offset((flagW - tp.width) / 2, top + (flagH - tp.height) / 2);

    for (int i = 0; i < strips; i++) {
      final x0 = i * sw;
      final frac = 1 - x0 / flagW; // الطرف الحر عند الشمال يتحرك أكتر
      final angle = (x0 / flagW) * 2 * math.pi * 1.4 + t * 2 * math.pi;
      final dy = math.sin(angle) * amp * frac;
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(x0, -size.height, sw + 0.8, size.height * 3));
      canvas.translate(0, dy);
      canvas.drawRect(cloth, clothPaint);
      canvas.drawRect(cloth.deflate(2), border);
      tp.paint(canvas, textPos);
      canvas.restore();
      final shade = (math.cos(angle) * frac + 1) / 2;
      canvas.drawRect(
        Rect.fromLTWH(x0, top + dy, sw + 0.8, flagH),
        Paint()..color = Colors.black.withOpacity(shade * 0.28),
      );
    }

    final pole = Rect.fromLTWH(flagW, 0, poleW, size.height);
    canvas.drawRect(pole, Paint()..color = const Color(0xFFC89B2E));
    canvas.drawCircle(Offset(flagW + poleW / 2, 4), 6, Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(covariant _FlagPainter old) => true;
}
