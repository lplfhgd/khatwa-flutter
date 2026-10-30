import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/children/controllers/children_controller.dart';
import 'features/children/controllers/selected_child_controller.dart';
import 'core/bindings/app_binding.dart';
import 'features/aac/controllers/aac_controller.dart';
import 'features/routine/controllers/routine_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/parent_auth_screen.dart';
import 'shared/widgets/k_button.dart';
import 'shared/widgets/k_card.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KhatwaApp());
}

class KColors {
  static const primary = Color(0xFF168F8B);
  static const support = Color(0xFF76C99C);
  static const accent = Color(0xFFFFC44F);
  static const background = Color(0xFFF7F9F7);
  static const text = Color(0xFF263F43);
  static const soft = Color(0xFFE5F3ED);
  static const border = Color(0xFFE1EAE6);
}

class AacItem {
  AacItem(this.label, this.symbol, this.category);
  final String label;
  final IconData symbol;
  final String category;
}

class RoutineItem {
  RoutineItem(this.label, this.symbol, {this.complete = false});
  final String label;
  final IconData symbol;
  bool complete;
}

class DemoStore extends ChangeNotifier {
  final List<AacItem> cards = [
    AacItem('أريد ماء', Icons.water_drop_outlined, 'الاحتياجات'),
    AacItem('أريد طعام', Icons.restaurant_outlined, 'الاحتياجات'),
    AacItem('أحتاج مساعدة', Icons.volunteer_activism_outlined, 'الاحتياجات'),
    AacItem('أريد استراحة', Icons.self_improvement_outlined, 'الاحتياجات'),
    AacItem('أنا سعيد', Icons.sentiment_satisfied_alt_outlined, 'المشاعر'),
    AacItem('أنا حزين', Icons.sentiment_dissatisfied_outlined, 'المشاعر'),
  ];
  final List<RoutineItem> routine = [
    RoutineItem('الاستيقاظ', Icons.wb_sunny_outlined),
    RoutineItem('غسل الوجه', Icons.wash_outlined),
    RoutineItem('تنظيف الأسنان', Icons.clean_hands_outlined),
    RoutineItem('الإفطار', Icons.breakfast_dining_outlined),
    RoutineItem('الاستعداد للخروج', Icons.backpack_outlined),
  ];

  void addCard(String label) {
    final cleaned = label.trim();
    if (cleaned.isEmpty) return;
    cards.add(AacItem(cleaned, Icons.chat_bubble_outline, 'مخصص'));
    notifyListeners();
  }

  void addRoutine(String label) {
    final cleaned = label.trim();
    if (cleaned.isEmpty) return;
    routine.add(RoutineItem(cleaned, Icons.checklist_outlined));
    notifyListeners();
  }

  void toggleRoutine(int index) {
    routine[index].complete = !routine[index].complete;
    notifyListeners();
  }
}

class KhatwaApp extends StatefulWidget {
  const KhatwaApp({super.key});
  @override
  State<KhatwaApp> createState() => _KhatwaAppState();
}

class _KhatwaAppState extends State<KhatwaApp> {
  final store = DemoStore();
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
      title: 'خطوة | Khatwa',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily:
            'IBM Plex Sans Arabic', // Requires user-installed font assets for exact production rendering.
        scaffoldBackgroundColor: KColors.background,
        colorScheme: ColorScheme.fromSeed(
            seedColor: KColors.primary,
            primary: KColors.primary,
            surface: KColors.background),
        appBarTheme: const AppBarTheme(
            backgroundColor: KColors.background,
            foregroundColor: KColors.text,
            centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: KColors.soft,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: RoleScreen(store: store),
    );
  }
}

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Image.asset('assets/images/khatwa_logo.png',
                        height: 195, fit: BoxFit.contain),
                    const SizedBox(height: 14),
                    const Text('من سيستخدم التطبيق؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            color: KColors.text,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('اختر نوع الواجهة للمتابعة',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                    const SizedBox(height: 28),
                    _RoleTile(
                      title: 'ولي الأمر',
                      subtitle: 'إدارة الطفل والمحتوى والمتابعة',
                      icon: Icons.family_restroom,
                      onTap: () => Get.to(
                        () => ParentAuthGate(store: store),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RoleTile(
                      title: 'الطفل',
                      subtitle: 'التواصل والتعلم والروتين',
                      icon: Icons.child_care,
                      onTap: () => Get.to(
                        () => ChildPairScreen(store: store),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                        'حساب ولي الأمر وملفات الأطفال تُحفظ عبر Firebase؛ ربط جهاز الطفل تجريبي حاليًا',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    const SizedBox(height: 16),
                  ],
                ))),
      );
}

class _RoleTile extends StatelessWidget {
  const _RoleTile(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: KCard(
          child: Row(children: [
        CircleAvatar(
            backgroundColor: KColors.soft,
            radius: 34,
            child: Icon(icon, color: KColors.primary, size: 35)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle)
        ])),
        const Icon(Icons.chevron_left),
      ])));
}

/// Requires a signed-in parent before allowing access to parent tools.
class ParentAuthGate extends StatelessWidget {
  const ParentAuthGate({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Get.find<AuthController>().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('حساب ولي الأمر')),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                  'تعذّر التحقق من جلسة الدخول. تأكد من الاتصال بالإنترنت وحاول مجددًا.\n${snapshot.error}',
                  textAlign: TextAlign.center),
            )),
          );
        }
        if (snapshot.data == null) return const ParentAuthScreen();
        return ParentShell(store: store);
      },
    );
  }
}

class ParentShell extends StatefulWidget {
  const ParentShell({super.key, required this.store});
  final DemoStore store;
  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    // Open the authenticated parent's Firestore stream once per shell instance.
    Get.find<ChildrenController>().startWatching();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final pages = [
          ParentHome(
              store: widget.store,
              navigate: (index) => setState(() => tab = index)),
          ParentContent(store: widget.store),
          ParentProgress(store: widget.store),
          ParentSettings(store: widget.store)
        ];
        return Scaffold(
          appBar: AppBar(
              title: Text(['الرئيسية', 'المحتوى', 'التقدم', 'الإعدادات'][tab])),
          body: pages[tab],
          bottomNavigationBar: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (index) => setState(() => tab = index),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
                NavigationDestination(
                    icon: Icon(Icons.auto_stories_outlined), label: 'المحتوى'),
                NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined), label: 'التقدم'),
                NavigationDestination(
                    icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
              ]),
        );
      });
}

void showAddDialog(BuildContext context,
    {required String title,
    required String hint,
    required ValueChanged<String> onSave}) {
  final controller = TextEditingController();
  showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(hintText: hint)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء')),
              FilledButton(
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('حفظ'))
            ],
          )).then((_) => controller.dispose());
}

/// Child profiles are provided by ChildrenController; views never query Firestore.
class ChildProfilesSection extends StatelessWidget {
  const ChildProfilesSection({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final childrenController = Get.find<ChildrenController>();
    final selectedController = Get.find<SelectedChildController>();

    return Obx(() {
      final children = childrenController.children;
      final loading = childrenController.isLoading.value;
      final error = childrenController.errorMessage.value;
      final selectedId = selectedController.selectedChildId.value;

      if (loading && children.isEmpty) {
        return const KCard(child: Center(child: CircularProgressIndicator()));
      }
      if (error != null && children.isEmpty) {
        return KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(error),
              const SizedBox(height: 8),
              KButton(
                label: 'إعادة المحاولة',
                outlined: true,
                onPressed: childrenController.startWatching,
              ),
            ],
          ),
        );
      }

      final selected = children.where((child) => child.id == selectedId);
      final activeName =
          selected.isEmpty ? 'لم يتم اختيار طفل' : selected.first.name;

      return KCard(
        tint: KColors.soft,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
              radius: 29, child: Icon(Icons.child_care, size: 32)),
          title: Text(activeName,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          subtitle: Text(children.isEmpty
              ? 'لا توجد ملفات أطفال بعد. أضف طفلًا تجريبيًا.'
              : 'ملفات الأطفال: ${children.length} • اضغط للإدارة أو اختيار طفل'),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => Get.to(() => ChildProfilesScreen(store: store)),
        ),
      );
    });
  }
}

class ChildProfilesScreen extends StatelessWidget {
  const ChildProfilesScreen({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final childrenController = Get.find<ChildrenController>();
    final selectedController = Get.find<SelectedChildController>();

    return Scaffold(
      appBar: AppBar(title: const Text('ملفات الأطفال')),
      body: Obx(() {
        final children = childrenController.children.toList();
        final loading = childrenController.isLoading.value;
        final error = childrenController.errorMessage.value;
        final selectedId = selectedController.selectedChildId.value;

        if (loading && children.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (error != null && children.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  KButton(
                      label: 'إعادة المحاولة',
                      onPressed: childrenController.startWatching),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('إدارة أطفال العائلة',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: KColors.text)),
            const SizedBox(height: 8),
            const Text(
                'استخدم أسماء تجريبية فقط خلال التطوير. يتيح لك الاختيار تحديد الطفل النشط في هذه الجلسة.'),
            const SizedBox(height: 18),
            KButton(
              label: 'إضافة طفل جديد',
              onPressed: () => Get.to(() => ChildProfileEditor(store: store)),
            ),
            const SizedBox(height: 18),
            if (error != null) ...[
              Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            if (children.isEmpty)
              const KCard(
                  child: Text(
                      'لا توجد ملفات أطفال حاليًا. اضغط «إضافة طفل جديد» للبدء.')),
            ...children.map((child) {
              final isSelected = selectedId == child.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: KCard(
                  tint: isSelected ? KColors.soft : Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.child_care_outlined,
                      color: KColors.primary,
                      size: 32,
                    ),
                    title: Text(child.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(child.birthYear == null
                        ? 'سنة الميلاد غير محددة'
                        : 'سنة الميلاد: ${child.birthYear}'),
                    onTap: () {
                      childrenController.selectChild(child);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'تم اختيار ${child.name} للواجهة التجريبية.')),
                      );
                    },
                    trailing: IconButton(
                      tooltip: 'تعديل الملف',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Get.to(() => ChildProfileEditor(
                            store: store,
                            childId: child.id,
                            initialName: child.name,
                            initialBirthYear: child.birthYear,
                          )),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class ChildProfileEditor extends StatefulWidget {
  const ChildProfileEditor({
    super.key,
    required this.store,
    this.childId,
    this.initialName,
    this.initialBirthYear,
  });
  final DemoStore store;
  final String? childId;
  final String? initialName;
  final int? initialBirthYear;

  @override
  State<ChildProfileEditor> createState() => _ChildProfileEditorState();
}

class _ChildProfileEditorState extends State<ChildProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  final ChildrenController childrenController = Get.find<ChildrenController>();
  late final TextEditingController _name;
  late final TextEditingController _birthYear;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName ?? '');
    _birthYear =
        TextEditingController(text: widget.initialBirthYear?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (childrenController.isSaving.value ||
        !_formKey.currentState!.validate()) {
      return;
    }
    final name = _name.text.trim();
    final yearText = _birthYear.text.trim();
    final year = yearText.isEmpty ? null : int.parse(yearText);

    final bool succeeded;
    if (widget.childId == null) {
      succeeded =
          await childrenController.addChild(name: name, birthYear: year);
    } else {
      succeeded = await childrenController.updateChild(
        childId: widget.childId!,
        name: name,
        birthYear: year,
      );
    }
    if (succeeded && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title:
                Text(widget.childId == null ? 'إضافة طفل' : 'تعديل ملف طفل')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('ملف الطفل',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: KColors.text)),
                  const SizedBox(height: 8),
                  const Text(
                      'للاختبار استخدم بيانات وهمية، ولا تدخل معلومات طفل حقيقي.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'اسم الطفل التجريبي',
                      prefixIcon: Icon(Icons.child_care_outlined),
                    ),
                    validator: (value) {
                      final name = (value ?? '').trim();
                      if (name.isEmpty) return 'أدخل اسمًا تجريبيًا';
                      if (name.length < 2) return 'الاسم قصير جدًا';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _birthYear,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'سنة الميلاد (اختياري)',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return null;
                      final year = int.tryParse(text);
                      final currentYear = DateTime.now().year;
                      if (year == null || year < 2000 || year > currentYear) {
                        return 'أدخل سنة صحيحة بين 2000 و$currentYear';
                      }
                      return null;
                    },
                  ),
                  Obx(() {
                    final error = childrenController.errorMessage.value;
                    if (error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(error,
                          style: const TextStyle(color: Colors.red)),
                    );
                  }),
                  const SizedBox(height: 24),
                  Obx(() {
                    final saving = childrenController.isSaving.value;
                    return KButton(
                      label: saving ? 'جارٍ الحفظ...' : 'حفظ ملف الطفل',
                      onPressed: saving ? null : _save,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key, required this.store, required this.navigate});
  final DemoStore store;
  final ValueChanged<int> navigate;
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('أهلًا بك في خطوة',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: KColors.text)),
      const SizedBox(height: 8),
      const Text('تابع رحلة طفلك، خطوة بخطوة'),
      const SizedBox(height: 20),
      ChildProfilesSection(store: store),
      const SizedBox(height: 20),
      Obx(() {
        final controller = Get.find<RoutineController>();

        final completed = controller.completedCount;
        final total = controller.routine.length;

        return KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'روتين اليوم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: controller.progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text('$completed من $total مهام مكتملة'),
            ],
          ),
        );
      }),
      const SizedBox(height: 18),
      const Text('إدارة سريعة',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _Shortcut(
          icon: Icons.chat_bubble_outline,
          title: 'بطاقات التواصل AAC',
          onTap: () => navigate(1)),
      _Shortcut(
          icon: Icons.calendar_month_outlined,
          title: 'إدارة الروتين المصور',
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ParentRoutineScreen(store: store)))),
      _Shortcut(
          icon: Icons.link_outlined,
          title: 'ربط جهاز الطفل',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ParentPairScreen()))),
      _Shortcut(
          icon: Icons.bar_chart_outlined,
          title: 'تقارير وملاحظات التقدم',
          onTap: () => navigate(2)),
    ]);
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(
      {required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KCard(
          child: ListTile(
              leading: Icon(icon, color: KColors.primary, size: 29),
              title: Text(title),
              trailing: const Icon(Icons.chevron_left),
              onTap: onTap)));
}

class ParentContent extends StatelessWidget {
  const ParentContent({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(20), children: [
        const Text('محتوى طفلك',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('أضف بطاقات التواصل والروتينات التي يحتاجها طفلك.'),
        const SizedBox(height: 20),
        KButton(
            label: 'إضافة بطاقة تواصل',
            onPressed: () => showAddDialog(context,
                title: 'بطاقة AAC جديدة',
                hint: 'مثال: أريد كتابًا',
                onSave: Get.find<AacController>().addCard)),
        const SizedBox(height: 12),
        Obx(() {
          final cards = Get.find<AacController>().cards;

          return Column(
            children: cards.map((card) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: KCard(
                  child: ListTile(
                    leading: Icon(
                      card.symbol,
                      color: KColors.primary,
                      size: 32,
                    ),
                    title: Text(card.label),
                    subtitle: Text(card.category),
                  ),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 10),
        KButton(
            label: 'إدارة الروتين اليومي',
            outlined: true,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ParentRoutineScreen(store: store)))),
        const SizedBox(height: 16),
        const KCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('القصص والألعاب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 6),
          Text(
              'شاشات تجريبية مبدئية؛ إدارة المحتوى التفصيلية ستُضاف في المرحلة التالية.')
        ])),
      ]);
}

class ParentRoutineScreen extends StatelessWidget {
  const ParentRoutineScreen({
    super.key,
    required this.store,
  });

  // نبقيه مؤقتًا حتى لا نغيّر استدعاءات الشاشة الأخرى.
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final routineController = Get.find<RoutineController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الروتين'),
      ),
      body: Obx(() {
        final tasks = routineController.routine;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            KButton(
              label: 'إضافة خطوة للروتين',
              onPressed: () => showAddDialog(
                context,
                title: 'خطوة جديدة',
                hint: 'مثال: ارتداء الملابس',
                onSave: routineController.addRoutine,
              ),
            ),
            const SizedBox(height: 15),
            ...tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: KCard(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      task.symbol,
                      color: KColors.primary,
                    ),
                    title: Text(
                      '${index + 1}. ${task.label}',
                    ),
                    subtitle: const Text(
                      'يمكنك تعليمها كمكتملة للتجربة',
                    ),
                    value: task.isCompleted,
                    onChanged: (_) {
                      routineController.toggleRoutine(index);
                    },
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class ParentProgress extends StatelessWidget {
  const ParentProgress({
    super.key,
    required this.store,
  });

  // نحتفظ به مؤقتًا حتى لا نغيّر استدعاءات ParentShell.
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final routineController = Get.find<RoutineController>();
    final aacController = Get.find<AacController>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'تقرير الأنشطة',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'هذا عرض تجريبي لمتابعة إنجاز الأنشطة، وليس تقييمًا أو تشخيصًا طبيًا.',
        ),
        const SizedBox(height: 24),
        Obx(() {
          final completed = routineController.completedCount;
          final total = routineController.routine.length;

          return KCard(
            child: Column(
              children: [
                const Icon(
                  Icons.insights,
                  color: KColors.primary,
                  size: 50,
                ),
                const SizedBox(height: 12),
                Text(
                  '$completed / $total',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('خطوات الروتين المنجزة'),
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: routineController.progress,
                  minHeight: 12,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 15),
        Obx(() {
          final cardCount = aacController.cards.length;

          return KCard(
            child: Column(
              children: [
                const Text(
                  'بطاقات التواصل المتاحة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$cardCount',
                  style: const TextStyle(
                    fontSize: 36,
                    color: KColors.primary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ParentSettings extends StatelessWidget {
  const ParentSettings({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(20), children: [
        const Text('الإعدادات',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _Shortcut(
            icon: Icons.child_care_outlined,
            title: 'إدارة ملفات الأطفال',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChildProfilesScreen(store: store)))),
        _Shortcut(
            icon: Icons.devices_other_outlined,
            title: 'الأجهزة المرتبطة (عرض توضيحي)',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ParentPairScreen()))),
        const KCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('الخصوصية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
              'تسجيل ولي الأمر وملفات الأطفال مرتبطة بـFirebase. بطاقات AAC والروتين لا تزال تجريبية ومحلية، وربط جهاز الطفل غير مؤمّن بعد. استخدم بيانات أطفال وهمية خلال التطوير.')
        ])),
        const SizedBox(height: 12),
        KButton(
            label: 'تسجيل خروج ولي الأمر',
            outlined: true,
            onPressed: () async {
              final authController = Get.find<AuthController>();
              final succeeded = await authController.signOut();
              if (succeeded) {
                Get.find<ChildrenController>().clearSession();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authController.errorMessage.value ??
                        'تعذّر تسجيل الخروج. حاول مجددًا.'),
                  ),
                );
              }
            }),
        const SizedBox(height: 10),
        const KCard(
            child: Text(
                'تفضيلات الطفل الحسية، إدارة الأجهزة الحقيقية والإشعارات ستُفعّل في المراحل التالية.')),
      ]);
}

class ParentPairScreen extends StatelessWidget {
  const ParentPairScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('ربط جهاز الطفل')),
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.phonelink_setup,
                size: 100, color: KColors.primary),
            const SizedBox(height: 20),
            const Text('رمز الربط التجريبي',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('482916',
                style: TextStyle(
                    fontSize: 48,
                    letterSpacing: 9,
                    fontWeight: FontWeight.bold,
                    color: KColors.primary)),
            const SizedBox(height: 15),
            const Text(
                'الرمز للعرض فقط، وليس رمز أمان صالحًا أو نظام ربط حقيقيًا.',
                textAlign: TextAlign.center),
            const SizedBox(height: 30),
            KButton(label: 'فهمت', onPressed: () => Navigator.pop(context)),
          ])));
}

class ChildPairScreen extends StatefulWidget {
  const ChildPairScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<ChildPairScreen> createState() => _ChildPairScreenState();
}

class _ChildPairScreenState extends State<ChildPairScreen> {
  final code = TextEditingController();
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('ربط جهاز الطفل')),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phonelink_ring_outlined,
                        size: 100, color: KColors.primary),
                    const SizedBox(height: 18),
                    const Text('أدخل رمز الربط',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('اطلب الرمز من ولي الأمر'),
                    const SizedBox(height: 18),
                    TextField(
                        controller: code,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 27, letterSpacing: 9),
                        decoration: const InputDecoration(
                            hintText: '••••••', counterText: '')),
                    if (error != null)
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 18),
                    KButton(
                        label: 'متابعة',
                        large: true,
                        onPressed: () {
                          if (code.text == '482916') {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ChildShell(store: widget.store)));
                          } else {
                            setState(
                                () => error = 'للتجربة استخدم الرمز 482916');
                          }
                        }),
                    const SizedBox(height: 10),
                    const Text(
                        'محاكاة محلية؛ في الإصدار الحقيقي يلزم تأكيد ولي الأمر.'),
                  ]))));
}

class ChildShell extends StatefulWidget {
  const ChildShell({super.key, required this.store});
  final DemoStore store;
  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) => Scaffold(
            appBar: AppBar(
                title: Obx(() => Text(
                    '${Get.find<SelectedChildController>().childName.value} • خطوة'))),
            body: [
              ChildHome(
                  store: widget.store,
                  openTab: (index) => setState(() => tab = index)),
              ChildAac(store: widget.store),
              ChildRoutine(store: widget.store),
              const ChildActivities()
            ][tab],
            bottomNavigationBar: NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (value) => setState(() => tab = value),
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
                  NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline), label: 'أتواصل'),
                  NavigationDestination(
                      icon: Icon(Icons.checklist_outlined), label: 'روتيني'),
                  NavigationDestination(
                      icon: Icon(Icons.extension_outlined), label: 'ألعابي'),
                ]),
          ));
}

class ChildHome extends StatelessWidget {
  const ChildHome({super.key, required this.store, required this.openTab});
  final DemoStore store;
  final ValueChanged<int> openTab;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        Obx(() => Text(
            'أهلًا يا ${Get.find<SelectedChildController>().childName.value}!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        const Text('ماذا تريد أن تفعل اليوم؟',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 28),
        _ChildEntry(
            title: 'أتواصل',
            icon: Icons.chat_bubble_outline,
            color: KColors.soft,
            onTap: () => openTab(1)),
        _ChildEntry(
            title: 'روتيني',
            icon: Icons.calendar_today_outlined,
            color: const Color(0xFFFFF1D0),
            onTap: () => openTab(2)),
        _ChildEntry(
            title: 'ألعابي',
            icon: Icons.extension_outlined,
            color: const Color(0xFFE8EFFA),
            onTap: () => openTab(3)),
      ]);
}

class _ChildEntry extends StatelessWidget {
  const _ChildEntry(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(24)),
            child: Row(children: [
              Icon(icon, size: 58, color: KColors.primary),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold))),
              const Icon(Icons.arrow_back_ios_new, color: KColors.primary)
            ]),
          )));
}

class ChildAac extends StatelessWidget {
  const ChildAac({super.key, required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final aacController = Get.find<AacController>();

    return Obx(() {
      final cards = aacController.cards;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'أتواصل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'اختر ما تريد قوله',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'اخترت: ${card.label} • النطق الصوتي سيُضاف لاحقًا',
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        index.isEven ? KColors.soft : const Color(0xFFFFF1D0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        card.symbol,
                        size: 66,
                        color: KColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        card.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

class ChildRoutine extends StatelessWidget {
  const ChildRoutine({super.key, required this.store});

  // نحتفظ به مؤقتًا حتى لا نغيّر استدعاءات ChildShell.
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final routineController = Get.find<RoutineController>();

    return Obx(() {
      final tasks = routineController.routine;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'روتيني اليوم',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => routineController.toggleRoutine(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(minHeight: 92),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: KColors.border),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: KColors.soft,
                        child: Icon(
                          task.symbol,
                          color: KColors.primary,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          task.label,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            task.isCompleted ? Colors.green : Colors.blueGrey,
                        size: 34,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class ChildActivities extends StatelessWidget {
  const ChildActivities({super.key});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        const Text('ألعابي',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _ChildEntry(
            title: 'الألوان والأشكال',
            icon: Icons.palette_outlined,
            color: const Color(0xFFFFF1D0),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ColorGameScreen()))),
        _ChildEntry(
            title: 'قصصي',
            icon: Icons.auto_stories_outlined,
            color: KColors.soft,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StoryScreen()))),
        const KCard(
            child: Text(
                'الألعاب الأخرى ستضاف تدريجيًا بعد تجربة هذا المسار الأساسي.')),
      ]);
}

class ColorGameScreen extends StatefulWidget {
  const ColorGameScreen({super.key});
  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen> {
  int? selected;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('الألوان والأشكال')),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Text('اختر الدائرة الحمراء',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              children: [Colors.blue, Colors.red, Colors.green, Colors.orange]
                  .asMap()
                  .entries
                  .map((entry) => InkWell(
                        onTap: () => setState(() => selected = entry.key),
                        child: Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected == entry.key
                                  ? KColors.text
                                  : Colors.transparent,
                              width: 5,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const Spacer(),
            if (selected != null)
              Text(
                  selected == 1
                      ? 'أحسنت! اخترت الدائرة الحمراء.'
                      : 'حاول مرة أخرى.',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            KButton(
                label: 'إنهاء النشاط',
                large: true,
                onPressed: () => Navigator.pop(context)),
          ])));
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('قصصي')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 20),
        const Icon(Icons.auto_stories, color: KColors.primary, size: 130),
        const SizedBox(height: 20),
        const Text('قصة الذهاب إلى المدرسة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const KCard(
            child: Text(
                'أرتدي حقيبتي، وأذهب إلى المدرسة. ألتقي بأصدقائي، وأتعلم أشياء جديدة.',
                style: TextStyle(fontSize: 22, height: 1.8),
                textAlign: TextAlign.center)),
        const SizedBox(height: 25),
        KButton(
            label: 'العودة إلى ألعابي',
            large: true,
            onPressed: () => Navigator.pop(context)),
      ]));
}
