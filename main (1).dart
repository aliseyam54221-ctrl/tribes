import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
        theme: ThemeData(textTheme: GoogleFonts.cairoTextTheme()),
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t?.color ?? bannerColors[0], Colors.black87],
              ),
            ),
          ),
        Positioned(top: 0, left: 0, right: 0, child: Container(height: 4, color: _gold)),
        Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 4, color: _gold)),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF1B8), Color(0xFFE8B84A), Color(0xFFB8860B)],
                ).createShader(r),
                child: Text(t?.name ?? '',
                    style: GoogleFonts.lalezar(
                      color: Colors.white,
                      fontSize: 72 * zoom,
                      shadows: const [Shadow(color: Colors.black, blurRadius: 14)],
                    )),
              ),
            ),
          ),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
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
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: first ? const Color(0xFFFBEDEA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: first ? const Color(0xFFE9B7A8) : const Color(0xFFD9DCE3)),
          ),
          child: Row(children: [
            const Icon(Icons.diamond, size: 12, color: _gold),
            const SizedBox(width: 8),
            Text(t.name, style: TextStyle(fontSize: 20 * zoom, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              width: 76,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: first ? _orange : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: first ? null : Border.all(color: const Color(0xFFC9CCD4)),
              ),
              child: Text(ar('${t.score}'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: first ? Colors.white : Colors.black)),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    _sort();
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        SafeArea(
          child: Column(children: [
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
                      backgroundColor: _orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
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
