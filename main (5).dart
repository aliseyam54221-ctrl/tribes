import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const TribesApp());

const gold = Color(0xFFF5B942);
const red = Color(0xFF9B1C1C);
const cream = Color(0xFFFFF6E5);

const tribeIcons = <IconData>[
  Icons.local_florist,
  Icons.home_rounded,
  Icons.change_history,
  Icons.nightlight_round,
  Icons.keyboard_double_arrow_down,
  Icons.spa,
  Icons.park,
  Icons.diamond,
  Icons.star_rounded,
  Icons.flag_rounded,
];

class Tribe {
  Tribe(this.name, this.icon, [this.points = 0]);
  final String name;
  final IconData icon;
  int points;
  final Key key = UniqueKey();
}

String ar(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => c == '-' ? '-' : d[int.parse(c)]).join();
}

class TribesApp extends StatelessWidget {
  const TribesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        builder: (c, w) => Directionality(textDirection: TextDirection.rtl, child: w!),
        theme: ThemeData(useMaterial3: true),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const rowH = 70.0;
  final tribes = <Tribe>[];
  final nameCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  bool subtractMode = false; // زر الناقص
  bool searching = false; // زر البحث
  bool muted = true; // زر الصوت
  bool dark = false; // زر الشمس
  bool fullscreen = false; // زر الشاشة الكاملة
  bool anim = true; // زر الكلاكيت (تشغيل/إيقاف الحركة)

  Duration get dur => anim ? const Duration(milliseconds: 100) : Duration.zero;

  List<Tribe> get visible {
    final q = searchCtrl.text.trim();
    final l = tribes.where((t) => q.isEmpty || t.name.contains(q)).toList();
    l.sort((a, b) => b.points.compareTo(a.points));
    return l;
  }

  void addTribe() {
    final n = nameCtrl.text.trim();
    if (n.isEmpty || tribes.length >= 100) return;
    setState(() => tribes.add(Tribe(n, tribeIcons[tribes.length % tribeIcons.length])));
    nameCtrl.clear();
  }

  void pointsDialog(Tribe t) {
    final c = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: Duration.zero, // يفتح فورًا
      pageBuilder: (_, __, ___) => Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: const Alignment(0, -0.5),
          child: Material(
            color: cream,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 300,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(t.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: c,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        hintText: subtractMode ? 'اكتب النقاط للخصم' : 'اكتب النقاط'),
                    onSubmitted: (_) => _apply(t, c),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: red),
                      onPressed: () => _apply(t, c),
                      child: Text(subtractMode ? 'خصم' : 'إضافة'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _apply(Tribe t, TextEditingController c) {
    final v = int.tryParse(c.text) ?? 0;
    setState(() => t.points += subtractMode ? -v : v);
    if (!muted) SystemSound.play(SystemSoundType.click);
    Navigator.pop(context);
  }

  void clearAll() {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف كل القبائل؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('لا')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: red),
              onPressed: () {
                setState(() => tribes.clear());
                Navigator.pop(context);
              },
              child: const Text('نعم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget topBtn(IconData i, VoidCallback f, {bool filled = false, bool on = false}) {
    final bg = filled || on ? red : cream;
    final fg = filled || on ? Colors.white : red;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: f,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: gold, width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Icon(i, size: 20, color: fg),
        ),
      ),
    );
  }

  static const _firstDeco = BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFFFFC857), Color(0xFFFFE3A3)]),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE59A1F), width: 1.5)),
  );
  static const _normalDeco = BoxDecoration(
    color: Color(0xFFFFF6E5),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFF0D9A8), width: 1.5)),
  );
  static const _scoreFirst = BoxDecoration(
    color: Color(0xFFFFB02E),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static const _scoreNormal = BoxDecoration(
    color: red,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  Widget row(Tribe t, int rank) {
    final first = rank == 0 && t.points > 0;
    return AnimatedPositioned(
      key: t.key,
      duration: dur,
      curve: Curves.easeOut,
      top: rank * rowH,
      left: 0,
      right: 0,
      height: rowH,
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Dismissible(
            key: ValueKey(t.key),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) => setState(() => tribes.remove(t)),
            background: const DecoratedBox(
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => pointsDialog(t),
              child: DecoratedBox(
                decoration: first ? _firstDeco : _normalDeco,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFC77D2B),
                      child: Icon(t.icon, color: const Color(0xFFFFE3A3), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(t.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3A2A18))),
                    ),
                    DecoratedBox(
                      decoration: first ? _scoreFirst : _scoreNormal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            ar(t.points),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: first ? Colors.black : gold),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit,
                              size: 13,
                              color: first ? Colors.black54 : const Color(0xFFE8B4A0)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = visible;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [Color(0xFF3B2A18), Color(0xFF241810)]
                : const [Color(0xFFFFE2A8), Color(0xFFFFF1D0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              // الشريط العلوي: يمين -> شمال (الصفحة RTL)
              Row(children: [
                topBtn(fullscreen ? Icons.fullscreen_exit : Icons.fullscreen, () {
                  setState(() => fullscreen = !fullscreen);
                  SystemChrome.setEnabledSystemUIMode(
                      fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
                }),
                topBtn(dark ? Icons.nightlight_round : Icons.wb_sunny,
                    () => setState(() => dark = !dark)),
                topBtn(muted ? Icons.volume_off : Icons.volume_up,
                    () => setState(() => muted = !muted),
                    on: muted),
                topBtn(Icons.movie_creation, () => setState(() => anim = !anim), on: !anim),
                const Spacer(),
                topBtn(Icons.search, () {
                  setState(() {
                    searching = !searching;
                    if (!searching) searchCtrl.clear();
                  });
                }, on: searching),
                topBtn(Icons.remove, () => setState(() => subtractMode = !subtractMode),
                    on: subtractMode),
                Padding(
                  padding: EdgeInsets.zero,
                  child: topBtn(Icons.delete, clearAll, filled: true),
                ),
              ]),
              if (searching)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قبيلة',
                      filled: true,
                      fillColor: cream,
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: list.length * rowH,
                    child: Stack(children: [
                      for (var i = 0; i < list.length; i++) row(list[i], i),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    maxLength: 44,
                    onSubmitted: (_) => addTribe(),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'اسم القبيلة (${ar(tribes.length)}/١٠٠)',
                      filled: true,
                      fillColor: cream,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: red, minimumSize: const Size(80, 52)),
                  onPressed: addTribe,
                  child: const Text('إضافة'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
