import 'package:flutter/material.dart';

void main() => runApp(const TribesApp());

const _red = Color(0xFFB3202A);
const _gold = Color(0xFFF7B733);
const _goldDark = Color(0xFFD99A1E);
const _bg = Color(0xFFFCE9C4);

const flagColors = <Color>[
  Color(0xFFB3202A), Color(0xFF1B7F3B), Color(0xFF1E5AA8), Color(0xFF111111),
  Color(0xFFE67E22), Color(0xFF7D3C98), Color(0xFF16A5A5), Color(0xFFD81B60),
];

class Tribe {
  String name;
  int score;
  Color flag;
  Tribe(this.name, this.score, this.flag);
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

String toArabicDigits(int n) {
  const d = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((c) => c == '-' ? '-' : d[int.parse(c)]).join();
}

int? parseNumber(String s) {
  const d = '٠١٢٣٤٥٦٧٨٩';
  var t = s.trim();
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
    Tribe('التميمي', 805, flagColors[0]),
    Tribe('الهذلي', 510, flagColors[1]),
    Tribe('الحوسني', 27, flagColors[2]),
    Tribe('ال قزيع', 16, flagColors[3]),
    Tribe('السهلي', 0, flagColors[4]),
    Tribe('الهادي', 0, flagColors[5]),
  ];
  final controller = TextEditingController();
  bool bright = true;
  bool sound = true;
  double zoom = 1.0;

  void _sort() => tribes.sort((a, b) => b.score.compareTo(a.score));

  void _add() {
    final name = controller.text.trim();
    if (name.isEmpty || name.length > 34) return;
    setState(() {
      tribes.add(Tribe(name, 0, flagColors[tribes.length % flagColors.length]));
      controller.clear();
    });
  }

  void _openControl(Tribe t) {
    final numCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bg,
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.flag, color: t.flag, size: 34),
                  const SizedBox(width: 8),
                  Text(t.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _red)),
                ]),
                const SizedBox(height: 6),
                Text(toArabicDigits(t.score), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // إدخال الرقم من الكيبورد
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
                        fillColor: Colors.white,
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
                        backgroundColor: _red, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                    onPressed: () => fromKeyboard(-1),
                    child: const Text('اخصم'),
                  ),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  for (final v in [-10, -5, -1, 1, 5, 10])
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: v < 0 ? Colors.grey : _red, foregroundColor: Colors.white),
                      onPressed: () => change(v),
                      child: Text(v > 0 ? '+$v' : '$v'),
                    ),
                ]),
                const SizedBox(height: 12),
                const Text('لون العلم'),
                const SizedBox(height: 6),
                Wrap(spacing: 10, children: [
                  for (final c in flagColors)
                    GestureDetector(
                      onTap: () {
                        setState(() => t.flag = c);
                        setSheet(() {});
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: c,
                        child: t.flag == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    ),
                ]),
                TextButton(
                  onPressed: () {
                    setState(() => tribes.remove(t));
                    Navigator.pop(ctx);
                  },
                  child: const Text('حذف القبيلة', style: TextStyle(color: _red)),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _circleBtn(IconData i, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Icon(i, color: Colors.grey.shade700)),
        ),
      );

  Widget _header() {
    final top = tribes.isEmpty ? null : tribes.first;
    return Container(
      height: 280,
      color: _bg,
      child: Stack(children: [
        Center(
          child: top == null
              ? const SizedBox()
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.emoji_events, color: _gold, size: 36),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.flag, color: top.flag, size: 56),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      decoration: BoxDecoration(
                        color: top.flag,
                        border: Border.all(color: _gold, width: 3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(top.name,
                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    Icon(Icons.flag, color: top.flag, size: 56),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (int i = 0; i < 7; i++)
                      Column(children: [
                        Icon(Icons.flag, color: top.flag, size: 22),
                        const Icon(Icons.person, color: Colors.brown, size: 30),
                      ]),
                  ]),
                ]),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Column(children: [
            _circleBtn(Icons.fullscreen, () {}),
            _circleBtn(bright ? Icons.wb_sunny : Icons.nightlight, () => setState(() => bright = !bright)),
            _circleBtn(sound ? Icons.volume_up : Icons.volume_off, () => setState(() => sound = !sound)),
            _circleBtn(Icons.movie, () {}),
          ]),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: Column(children: [
            _circleBtn(Icons.delete, () => setState(() => tribes.clear())),
            _circleBtn(Icons.zoom_in, () => setState(() => zoom = (zoom + 0.1).clamp(0.8, 1.5))),
            _circleBtn(Icons.remove, () => setState(() => zoom = (zoom - 0.1).clamp(0.8, 1.5))),
          ]),
        ),
      ]),
    );
  }

  Widget _tile(Tribe t, bool first) => GestureDetector(
        onTap: () => _openControl(t),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: first ? _gold : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _gold.withOpacity(.6)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(children: [
            CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flag, color: t.flag)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(t.name,
                  style: TextStyle(fontSize: 22 * zoom, fontWeight: FontWeight.w600, color: Colors.brown.shade800)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: first ? _goldDark : _red, borderRadius: BorderRadius.circular(12)),
              child: Text(toArabicDigits(t.score),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    _sort();
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(children: [
          _header(),
          Expanded(
            child: ListView.builder(
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
                    hintText: 'اسم القبيلة (١-٣٤)',
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
                    backgroundColor: _red, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                onPressed: _add,
                child: const Text('إضافة'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
