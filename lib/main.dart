import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/children/controllers/selected_child_controller.dart';
import 'core/bindings/app_binding.dart';
import 'features/auth/controllers/auth_controller.dart';
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

class KButton extends StatelessWidget {
  const KButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.outlined = false,
      this.large = false});
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool large;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: large ? 72 : 52,
        width: double.infinity,
        child: outlined
            ? OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: KColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(large ? 24 : 14))),
                child: Text(label,
                    style: TextStyle(
                        fontSize: large ? 20 : 16,
                        fontWeight: FontWeight.bold)))
            : FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                    backgroundColor: KColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(large ? 24 : 14))),
                child: Text(label,
                    style: TextStyle(
                        fontSize: large ? 20 : 16,
                        fontWeight: FontWeight.bold))),
      );
}

class KCard extends StatelessWidget {
  const KCard(
      {super.key,
      required this.child,
      this.tint = Colors.white,
      this.padding = 16});
  final Widget child;
  final Color tint;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: KColors.border)),
        child: child,
      );
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

class ParentAuthScreen extends StatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  bool _register = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (authController.isLoading.value || !_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_register) {
      await authController.register(email: email, password: password);
    } else {
      await authController.signIn(email: email, password: password);
    }
    // ParentAuthGate listens to auth changes and presents ParentShell.
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      authController.errorMessage.value =
          'اكتب بريدك الإلكتروني أولًا لإرسال رابط الاستعادة.';
      return;
    }

    final succeeded = await authController.resetPassword(email);
    if (succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'إذا كان البريد مرتبطًا بحساب، ستصلك رسالة استعادة كلمة المرور.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_register ? 'إنشاء حساب ولي الأمر' : 'دخول ولي الأمر'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/khatwa_logo.png', height: 150),
                    const SizedBox(height: 16),
                    Text(
                      _register ? 'أنشئ حسابك في خطوة' : 'أهلًا بك في خطوة',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: KColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'حساب ولي الأمر فقط • لا يحتاج الطفل إلى بريد إلكتروني',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) =>
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch((value ?? '').trim())
                              ? null
                              : 'أدخل بريدًا إلكترونيًا صحيحًا',
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hidePassword = !_hidePassword,
                          ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value ?? '').length >= 6
                          ? null
                          : 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Obx(() {
                      final message = authController.errorMessage.value;
                      if (message == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Obx(() {
                      final busy = authController.isLoading.value;
                      return KButton(
                        label: busy
                            ? 'جارٍ المعالجة...'
                            : (_register ? 'إنشاء حساب' : 'تسجيل الدخول'),
                        onPressed: busy ? null : _submit,
                      );
                    }),
                    const SizedBox(height: 10),
                    Obx(() {
                      final busy = authController.isLoading.value;
                      return TextButton(
                        onPressed: busy
                            ? null
                            : () {
                                authController.errorMessage.value = null;
                                setState(() => _register = !_register);
                              },
                        child: Text(_register
                            ? 'لديك حساب بالفعل؟ تسجيل الدخول'
                            : 'ليس لديك حساب؟ إنشاء حساب جديد'),
                      );
                    }),
                    if (!_register)
                      Obx(() => TextButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : _resetPassword,
                            child: const Text('نسيت كلمة المرور؟'),
                          )),
                    const SizedBox(height: 12),
                    const Text(
                      'هذه نسخة تطويرية. لا تُدخل معلومات شخصية حقيقية عن الأطفال قبل اكتمال حماية البيانات.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

/// الملفات السحابية للأطفال تحت حساب ولي الأمر المصادق عليه فقط.
class ChildProfilesSection extends StatelessWidget {
  const ChildProfilesSection({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const KCard(child: Text('سجّل الدخول لإدارة ملفات الأطفال.'));
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .collection('children')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return KCard(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                  'تعذّر تحميل ملفات الأطفال. تحقق من الإنترنت والصلاحيات.'),
              const SizedBox(height: 8),
              KButton(
                  label: 'إدارة ملفات الأطفال',
                  outlined: true,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChildProfilesScreen(store: store)))),
            ],
          ));
        }
        if (!snapshot.hasData) {
          return const KCard(child: Center(child: CircularProgressIndicator()));
        }
        final docs = snapshot.data!.docs;
        final childController = Get.find<SelectedChildController>();
        return Obx(() {
          final selected = docs
              .where((d) => d.id == childController.selectedChildId.value)
              .toList();
          final activeName = selected.isEmpty
              ? 'لم يتم اختيار طفل'
              : (selected.first.data()['name'] as String? ?? 'طفل');
          return KCard(
            tint: KColors.soft,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                  radius: 29, child: Icon(Icons.child_care, size: 32)),
              title: Text(activeName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(docs.isEmpty
                  ? 'لا توجد ملفات أطفال بعد. أضف طفلًا تجريبيًا.'
                  : 'ملفات الأطفال: ${docs.length} • اضغط للإدارة أو اختيار طفل'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChildProfilesScreen(store: store))),
            ),
          );
        });
      },
    );
  }
}

class ChildProfilesScreen extends StatelessWidget {
  const ChildProfilesScreen({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final childController = Get.find<SelectedChildController>();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('ملفات الأطفال')),
          body: const Center(child: Text('يجب تسجيل دخول ولي الأمر.')));
    }
    final collection = FirebaseFirestore.instance
        .collection('parents')
        .doc(user.uid)
        .collection('children');
    return Scaffold(
      appBar: AppBar(title: const Text('ملفات الأطفال')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        'تعذّر تحميل البيانات. تحقق من الإنترنت وقواعد Firestore.')));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) => (a.data()['name'] as String? ?? '')
                .compareTo(b.data()['name'] as String? ?? ''));
          return Obx(() =>
              ListView(padding: const EdgeInsets.all(20), children: [
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
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChildProfileEditor(store: store)))),
                const SizedBox(height: 18),
                if (docs.isEmpty)
                  const KCard(
                      child: Text(
                          'لا توجد ملفات أطفال حاليًا. اضغط «إضافة طفل جديد» للبدء.')),
                ...docs.map((doc) {
                  final data = doc.data();
                  final name = data['name'] as String? ?? 'طفل';
                  final birthYear = data['birthYear'];
                  final isSelected =
                      childController.selectedChildId.value == doc.id;
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
                            size: 32),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(birthYear is int
                            ? 'سنة الميلاد: $birthYear'
                            : 'سنة الميلاد غير محددة'),
                        onTap: () {
                          childController.selectChild(doc.id, name);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('تم اختيار $name للواجهة التجريبية.')));
                        },
                        trailing: IconButton(
                          tooltip: 'تعديل الملف',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChildProfileEditor(
                                        store: store,
                                        childId: doc.id,
                                        initialName: name,
                                        initialBirthYear:
                                            birthYear is int ? birthYear : null,
                                      ))),
                        ),
                      ),
                    ),
                  );
                }),
              ]));
        },
      ),
    );
  }
}

class ChildProfileEditor extends StatefulWidget {
  const ChildProfileEditor(
      {super.key,
      required this.store,
      this.childId,
      this.initialName,
      this.initialBirthYear});
  final DemoStore store;
  final String? childId;
  final String? initialName;
  final int? initialBirthYear;

  @override
  State<ChildProfileEditor> createState() => _ChildProfileEditorState();
}

class _ChildProfileEditorState extends State<ChildProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _birthYear;
  bool _saving = false;
  String? _error;

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
    if (_saving || !_formKey.currentState!.validate()) return;
    final childController = Get.find<SelectedChildController>();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'انتهت جلسة الدخول. سجّل الدخول مجددًا.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final collection = FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .collection('children');
      final name = _name.text.trim();
      final yearText = _birthYear.text.trim();
      final year = yearText.isEmpty ? null : int.parse(yearText);
      final fields = <String, dynamic>{
        'name': name,
        'birthYear': year,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.childId == null) {
        final ref = collection.doc();
        await ref.set({
          ...fields,
          'createdAt': FieldValue.serverTimestamp(),
        });
        childController.selectChild(ref.id, name);
      } else {
        await collection.doc(widget.childId).update(fields);
        if (childController.selectedChildId.value == widget.childId) {
          childController.selectChild(widget.childId!, name);
        }
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() => _error =
            'تعذّر حفظ الملف (${e.code}). تحقق من الاتصال وقواعد الأمان.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'حدث خطأ غير متوقع أثناء الحفظ.');
    } finally {
      if (mounted) setState(() => _saving = false);
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
                        prefixIcon: Icon(Icons.child_care_outlined)),
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
                        prefixIcon: Icon(Icons.calendar_today_outlined)),
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
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  KButton(
                      label: _saving ? 'جارٍ الحفظ...' : 'حفظ ملف الطفل',
                      onPressed: _saving ? null : _save),
                ],
              )),
        )),
      );
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key, required this.store, required this.navigate});
  final DemoStore store;
  final ValueChanged<int> navigate;
  @override
  Widget build(BuildContext context) {
    final completed = store.routine.where((e) => e.complete).length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('أهلًا بك في خطوة',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: KColors.text)),
      const SizedBox(height: 8),
      const Text('تابع رحلة طفلك، خطوة بخطوة'),
      const SizedBox(height: 20),
      ChildProfilesSection(store: store),
      const SizedBox(height: 20),
      KCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('روتين اليوم',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        LinearProgressIndicator(
            value: store.routine.isEmpty ? 0 : completed / store.routine.length,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 8),
        Text('$completed من ${store.routine.length} مهام مكتملة')
      ])),
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
                onSave: store.addCard)),
        const SizedBox(height: 12),
        ...store.cards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: KCard(
                child: ListTile(
                    leading:
                        Icon(card.symbol, color: KColors.primary, size: 32),
                    title: Text(card.label),
                    subtitle: Text(card.category))))),
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
  const ParentRoutineScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('إدارة الروتين')),
      body: AnimatedBuilder(
          animation: store,
          builder: (_, __) =>
              ListView(padding: const EdgeInsets.all(20), children: [
                KButton(
                    label: 'إضافة خطوة للروتين',
                    onPressed: () => showAddDialog(context,
                        title: 'خطوة جديدة',
                        hint: 'مثال: ارتداء الملابس',
                        onSave: store.addRoutine)),
                const SizedBox(height: 15),
                ...store.routine.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: KCard(
                        child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(entry.value.symbol,
                                color: KColors.primary),
                            title:
                                Text('${entry.key + 1}. ${entry.value.label}'),
                            subtitle:
                                const Text('يمكنك تعليمها كمكتملة للتجربة'),
                            value: entry.value.complete,
                            onChanged: (_) =>
                                store.toggleRoutine(entry.key))))),
              ])));
}

class ParentProgress extends StatelessWidget {
  const ParentProgress({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) {
    final completed = store.routine.where((item) => item.complete).length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('تقرير الأنشطة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const Text(
          'هذا عرض تجريبي لمتابعة إنجاز الأنشطة، وليس تقييمًا أو تشخيصًا طبيًا.'),
      const SizedBox(height: 24),
      KCard(
          child: Column(children: [
        const Icon(Icons.insights, color: KColors.primary, size: 50),
        const SizedBox(height: 12),
        Text('$completed / ${store.routine.length}',
            style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
        const Text('خطوات الروتين المنجزة'),
        const SizedBox(height: 15),
        LinearProgressIndicator(
            value: store.routine.isEmpty ? 0 : completed / store.routine.length,
            minHeight: 12)
      ])),
      const SizedBox(height: 15),
      KCard(
          child: Column(children: [
        const Text('بطاقات التواصل المتاحة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('${store.cards.length}',
            style: const TextStyle(fontSize: 36, color: KColors.primary))
      ])),
    ]);
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
                Get.find<SelectedChildController>().clearSelectedChild();
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
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        const Text('أتواصل',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        const Text('اختر ما تريد قوله',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 24),
        GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95),
            itemCount: store.cards.length,
            itemBuilder: (context, index) {
              final card = store.cards[index];
              return InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'اخترت: ${card.label} • النطق الصوتي سيُضاف لاحقًا'))),
                  child: Container(
                    decoration: BoxDecoration(
                        color: index.isEven
                            ? KColors.soft
                            : const Color(0xFFFFF1D0),
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(card.symbol, size: 66, color: KColors.primary),
                          const SizedBox(height: 12),
                          Text(card.label,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)
                        ]),
                  ));
            }),
      ]);
}

class ChildRoutine extends StatelessWidget {
  const ChildRoutine({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        const Text('روتيني اليوم',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...store.routine.asMap().entries.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
                onTap: () => store.toggleRoutine(item.key),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(minHeight: 92),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: KColors.border),
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(children: [
                    CircleAvatar(
                        backgroundColor: KColors.soft,
                        child: Icon(item.value.symbol, color: KColors.primary)),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Text(item.value.label,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold))),
                    Icon(
                        item.value.complete
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: item.value.complete
                            ? Colors.green
                            : Colors.blueGrey,
                        size: 34)
                  ]),
                )))),
      ]);
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
