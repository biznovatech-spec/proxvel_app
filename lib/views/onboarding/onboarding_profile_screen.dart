import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/onboarding_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../core/navigation/home_entry_coordinator.dart';
import '../../models/traveler_profile_model.dart';
import '../../core/widgets/buttons/proxvel_button.dart';
import '../../core/widgets/buttons/shimmer_button.dart';
import 'package:google_fonts/google_fonts.dart';

const _kDark = Color(0xFF2B323B);
const _kGray = Color(0xFF6B7280);
const _kLightGray = Color(0xFFF3F4F6);
const _kAmber = Color(0xFFF59E0B);
const _kBorder = Color(0xFFE5E7EB);

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});
  @override
  State<OnboardingProfileScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingProfileScreen> with TickerProviderStateMixin {
  final PageController _pc = PageController();
  int _page = 0; // 0=intro,1=presupuesto,2=clima,3=comodidad,4=intereses
  
  late final AnimationController _shimmerCtrl;

  String? _budget;
  int _days = 1;
  String? _climate;
  String? _comfort;
  final Set<String> _interests = {};

  bool _done = false;
  int _cd = 5;
  Timer? _timer;

  static const _interestData = [
    ('palm_tree.svg', 'Naturaleza'), ('museum.svg', 'Cultura'),
    ('pot_of_food.svg', 'Gastronomía'), ('shopping_cart.svg', 'Compras'),
    ('hiking_boot.svg', 'Aventura'), ('beach_20.svg', 'Playa'),
    ('cityscape.svg', 'Urbano'), ('farm.svg', 'Rural'),
    ('briefcase.svg', 'Negocios'), ('man_student_2.svg', 'Académico'),
    ('spa.svg', 'Relax'), ('family.svg', 'Familiar'),
  ];

  bool get _canProceed {
    switch (_page) {
      case 0: return true;
      case 1: return _budget != null;
      case 2: return _climate != null;
      case 3: return _comfort != null;
      case 4: return _interests.isNotEmpty;
      default: return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  void _next() {
    if (!_canProceed) return;
    if (_page < 4) {
      _pc.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      setState(() => _page++);
    } else { _saveAndComplete(); }
  }

  void _prev() {
    if (_page > 0) {
      _pc.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      setState(() => _page--);
    }
  }

  Future<void> _saveAndComplete() async {
    final user = context.read<AuthController>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error: No hay usuario activo.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final selectedInterests = _interests.toList();
    final tipoInteres = selectedInterests.isEmpty
        ? 'mixto'
        : (selectedInterests.length == 1 ? selectedInterests.first.toLowerCase() : 'mixto');

    final profile = TravelerProfileModel(
      presupuesto: _budget?.toLowerCase() ?? 'medio',
      diasViaje: _days,
      climaPreferido: _climate?.toLowerCase() ?? 'templado',
      tipoInteres: tipoInteres,
      intereses: selectedInterests.map((i) => i.toLowerCase()).toList(),
      toleranciaMultitudes: _comfort?.toLowerCase() ?? 'moderado',
      // The weights will just use defaults for now, as UI doesn't set them yet
    );

    final success = await context.read<OnboardingController>().saveProfile(profile, user.id);
    
    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (success) {
      // Invalidar y recargar recomendaciones con el perfil recién creado.
      if (mounted) {
        final recCtrl = context.read<RecommendationController>();
        recCtrl.invalidate();
        recCtrl.loadRecommendations(forceRefresh: true);
      }
      _complete();
    } else {
      if (mounted) {
        final err = context.read<OnboardingController>().error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err ?? 'Error desconocido'),
          backgroundColor: Colors.red.shade600,
        ));
      }
    }
  }

  void _complete() {
    setState(() => _done = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cd <= 1) { 
        t.cancel(); 
        if (mounted) {
          final user = context.read<AuthController>().currentUser;
          if (user != null) {
            HomeEntryCoordinator.goToPreparedHome(context);
          }
        } 
      }
      else { setState(() => _cd--); }
    });
  }

  @override
  void dispose() { 
    _timer?.cancel(); 
    _pc.dispose(); 
    _shimmerCtrl.dispose();
    super.dispose(); 
  }

  static const _titles = [
    'Personalicemos tu perfil', 'Ajusta presupuesto y días.',
    'Clima preferido.', 'Comodidad del viaje.', 'Intereses principales.',
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark,
    ));
    if (_done) return _completionView();
    final isIntro = _page == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Soft premium iOS native background
      body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isIntro) _header(_page) 
          else const SizedBox(height: 48), // Top breathing room for intro
          
          Padding(
            padding: EdgeInsets.fromLTRB(32, isIntro ? 16 : 4, 32, 0),
            child: Text(
              _titles[_page], 
              textAlign: isIntro ? TextAlign.center : TextAlign.left,
              style: GoogleFonts.poppins(fontSize: isIntro ? 32 : 28, fontWeight: FontWeight.w700, color: _kDark, letterSpacing: -0.5, height: 1.2)
            ),
          ),
          if (isIntro) Padding(
            padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
            child: Text(
              'Ajustaremos tus preferencias para sugerirte destinos precisos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: _kGray, height: 1.5)
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: PageView(
            controller: _pc, physics: const NeverScrollableScrollPhysics(),
            children: [_introView(), _budgetView(), _climateView(), _comfortView(), _interestsView()],
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: isIntro ? _introButtons() : _stepButtons(),
          ),
        ],
      )),
    );
  }

  Widget _header(int step) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
    child: Row(children: [
      _backBtn(_prev), const SizedBox(width: 12),
      Expanded(child: Column(children: [
        Text('$step de 4', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGray)),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
          value: step / 4, minHeight: 5, backgroundColor: _kLightGray,
          valueColor: const AlwaysStoppedAnimation<Color>(_kDark),
        )),
      ])),
      const SizedBox(width: 48),
    ]),
  );

  Widget _backBtn(VoidCallback onTap) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(20),
    child: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _kBorder, width: 1.5)),
      child: const Icon(Icons.arrow_back, size: 20, color: _kDark)),
  );

  Widget _introButtons() => Column(children: [
    ShimmerButton(
      shimmer: _shimmerCtrl,
      baseColor: _kAmber,
      hoverColor: const Color(0xFFD97706),
      text: 'Comenzar',
      onPressed: _next,
    ),
    const SizedBox(height: 20),
    GestureDetector(
      onTap: () => HomeEntryCoordinator.goToPreparedHome(context),
      child: Text('Omitir por ahora', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kGray)),
    )
  ]);

  Widget _stepButtons() => Column(children: [
    ProxvelButton(text: _page == 4 ? 'Terminar' : 'Siguiente  →', onPressed: _canProceed ? _next : null),
    const SizedBox(height: 12),
    ProxvelButton(text: '←  Volver', isSecondary: true, onPressed: _prev),
  ]);

  // ── INTRO ──
  Widget _introView() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      const SizedBox(height: 24),
      SizedBox(
        height: 240, 
        child: Image.asset(
          'assets/images/clean_luggage_3d.png', 
          fit: BoxFit.contain,
          color: const Color(0xFFF9FAFB),
          colorBlendMode: BlendMode.multiply,
        )
      ),
      const SizedBox(height: 48),
      Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
        _floatingChip('💰', 'Presupuesto'), _floatingChip('💬', 'Intereses'), _floatingChip('🌤️', 'Clima'),
      ]),
      const SizedBox(height: 36),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))
           ]
        ),
        child: RichText(textAlign: TextAlign.center, text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 13, color: _kGray, height: 1.6),
          children: const [
            TextSpan(text: 'Ahorra tiempo: ', style: TextStyle(fontWeight: FontWeight.w700, color: _kDark)),
            TextSpan(text: 'Recomendaciones más precisas.\n'),
            TextSpan(text: 'Filtra destinos ', style: TextStyle(fontWeight: FontWeight.w700, color: _kDark)),
            TextSpan(text: 'según tu estilo de viaje.'),
          ],
        )),
      ),
      const SizedBox(height: 24),
    ]),
  );

  Widget _floatingChip(String emoji, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(24), 
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))
      ]
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 8),
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kDark)),
    ]),
  );

  // ── PRESUPUESTO Y DÍAS ──
  Widget _budgetView() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      const SizedBox(height: 8),
      Text('¿Cuál es tu presupuesto aproximado?', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _kDark)),
      const SizedBox(height: 6),
      Text('Esto nos ayuda a ajustar las recomendaciones.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: _kGray)),
      const SizedBox(height: 24),
      _opt('Bajo', _budget == 'Bajo', () => setState(() => _budget = 'Bajo')),
      const SizedBox(height: 14),
      _opt('Medio', _budget == 'Medio', () => setState(() => _budget = 'Medio')),
      const SizedBox(height: 14),
      _opt('Alto', _budget == 'Alto', () => setState(() => _budget = 'Alto')),
      const SizedBox(height: 12),
      Text('Podrás cambiarlo después.', style: GoogleFonts.poppins(fontSize: 13, color: _kAmber.withValues(alpha: 0.9))),
      const SizedBox(height: 36),
      Text('¿Cuántos días planeas viajar?', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _kDark)),
      const SizedBox(height: 6),
      Text('Puedes cambiarlo después.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: _kGray)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _dayBtn(Icons.remove, () { if (_days > 1) setState(() => _days--); }),
        const SizedBox(width: 24),
        Container(width: 110, height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), 
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))]
          ),
          alignment: Alignment.center,
          child: Text(_days.toString().padLeft(2, '0'), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: _kDark)),
        ),
        const SizedBox(width: 24),
        _dayBtn(Icons.add, () { if (_days < 30) setState(() => _days++); }),
      ]),
      const SizedBox(height: 12),
      Text('Podrás cambiarlo después.', style: GoogleFonts.poppins(fontSize: 13, color: _kAmber.withValues(alpha: 0.9))),
    ]),
  );

  // ── CLIMA ──
  Widget _climateView() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      const SizedBox(height: 8),
      Text('¿Qué clima prefieres para viajar?', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _kDark)),
      const SizedBox(height: 6),
      Text('Esto nos ayuda a sugerirte destinos ideales.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: _kGray)),
      const SizedBox(height: 24),
      _optDesc('❄️  Frío', 'Montañas, nieve y paisajes frescos', _climate == 'Frío', () => setState(() => _climate = 'Frío')),
      const SizedBox(height: 14),
      _optDesc('🌤️  Templado', 'Clima agradable y equilibrado', _climate == 'Templado', () => setState(() => _climate = 'Templado')),
      const SizedBox(height: 14),
      _optDesc('☀️  Cálido', 'Sol, playas y destinos tropicales', _climate == 'Cálido', () => setState(() => _climate = 'Cálido')),
      const SizedBox(height: 16),
      Text('Podrás cambiarlo después.', style: GoogleFonts.poppins(fontSize: 13, color: _kAmber.withValues(alpha: 0.9))),
    ]),
  );

  // ── COMODIDAD ──
  Widget _comfortView() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      const SizedBox(height: 8),
      Text('¿Qué tan cómodo te sientes\ncon multitudes?', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _kDark)),
      const SizedBox(height: 6),
      Text('Esto nos ayuda a sugerirte lugares más\ntranquilos o más movidos.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: _kGray)),
      const SizedBox(height: 24),
      _optDesc('Bajo', 'Prefiere lugares tranquilos', _comfort == 'Bajo', () => setState(() => _comfort = 'Bajo')),
      const SizedBox(height: 14),
      _optDesc('Medio', 'Me adapto a cualquier entorno', _comfort == 'Medio', () => setState(() => _comfort = 'Medio')),
      const SizedBox(height: 14),
      _optDesc('Alto', 'Me encantan las zonas concurridas', _comfort == 'Alto', () => setState(() => _comfort = 'Alto')),
      const SizedBox(height: 16),
      Text('Podrás cambiarlo después.', style: GoogleFonts.poppins(fontSize: 13, color: _kAmber.withValues(alpha: 0.9))),
    ]),
  );

  // ── INTERESES ──
  Widget _interestsView() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      const SizedBox(height: 8),
      Text('¿Qué experiencias prefieres?', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _kDark)),
      const SizedBox(height: 6),
      Text('Recomendado: elige al menos 3.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: _kAmber.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
      const SizedBox(height: 24),
      Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _interestData.map((item) {
        final sel = _interests.contains(item.$2);
        return GestureDetector(
          onTap: () => setState(() => sel ? _interests.remove(item.$2) : _interests.add(item.$2)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? _kAmber : Colors.white, 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!sel) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4)),
                if (sel) BoxShadow(color: _kAmber.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
              ]
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SvgPicture.asset('assets/icons/${item.$1}', width: 20, height: 20,
                colorFilter: sel ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null),
              const SizedBox(width: 8),
              Text(item.$2, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? Colors.white : _kDark)),
            ]),
          ),
        );
      }).toList()),
      const SizedBox(height: 24),
      Center(child: Text('Podrás cambiarlo después.', style: GoogleFonts.poppins(fontSize: 13, color: _kAmber.withValues(alpha: 0.9)))),
    ]),
  );

  // ── FELICIDADES (PREMIUM) ──
  Widget _completionView() => Scaffold(
    backgroundColor: _kLightGray,
    body: SafeArea(child: Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Spacer(flex: 2),
        Container(width: 140, height: 140,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _kAmber.withValues(alpha: 0.1)),
          alignment: Alignment.center,
          child: Container(width: 110, height: 110,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _kAmber.withValues(alpha: 0.15)),
            alignment: Alignment.center,
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kAmber, _kAmber.withValues(alpha: 0.8)]),
                boxShadow: [BoxShadow(color: _kAmber.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44)),
          ),
        ),
        const SizedBox(height: 32),
        const Text('¡Felicidades!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _kDark)),
        const SizedBox(height: 12),
        Text('Tu perfil ha sido configurado\ncorrectamente. Prepárate para descubrir\nlos mejores destinos.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: _kGray.withValues(alpha: 0.9), height: 1.5)),
        const SizedBox(height: 40),
        SizedBox(width: 56, height: 56, child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: _cd / 5, strokeWidth: 3, backgroundColor: _kLightGray, valueColor: AlwaysStoppedAnimation<Color>(_kAmber)),
          Text('$_cd', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDark)),
        ])),
        const SizedBox(height: 12),
        Text('Redirigiendo...', style: TextStyle(fontSize: 13, color: _kGray.withValues(alpha: 0.7))),
        const SizedBox(height: 16),
        GestureDetector(onTap: () => HomeEntryCoordinator.goToPreparedHome(context),
          child: const Text('Ir ahora', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark))),
        const Spacer(flex: 3),
      ]),
    ))));

  // ── SHARED WIDGETS ──
  Widget _opt(String label, bool sel, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), width: double.infinity, height: 56, alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sel ? _kAmber : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!sel) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
          if (sel) BoxShadow(color: _kAmber.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))
        ]
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: sel ? Colors.white : _kDark))
    ),
  );

  Widget _optDesc(String label, String desc, bool sel, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16), alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sel ? _kAmber : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!sel) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
          if (sel) BoxShadow(color: _kAmber.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))
        ]
      ),
      child: Column(children: [
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: sel ? Colors.white : _kDark)),
        const SizedBox(height: 4),
        Text(desc, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: sel ? Colors.white.withValues(alpha: 0.9) : _kGray)),
      ])
    ),
  );

  Widget _dayBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Container(width: 48, height: 48,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3))]
      ),
      alignment: Alignment.center, child: Icon(icon, color: _kDark, size: 20)),
  );
}
