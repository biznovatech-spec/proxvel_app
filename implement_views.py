import os

base_dir = r"c:\Users\danie\Documents\Proyectos\proxvell_app\lib"

files = {
    "views/intro/intro_screen.dart": """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PROXVEL INTRO', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
""",
    "views/auth/welcome_screen.dart": """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to PROXVEL'),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Iniciar Sesión'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/register'),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
""",
    "views/auth/login_screen.dart": """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await context.read<AuthController>().login('test', 'test');
            if(context.mounted) context.go('/main');
          },
          child: const Text('Simular Login'),
        ),
      ),
    );
  }
}
""",
    "views/auth/register_screen.dart": """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/onboarding'),
          child: const Text('Ir a Onboarding'),
        ),
      ),
    );
  }
}
""",
    "views/onboarding/onboarding_profile_screen.dart": """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingProfileScreen extends StatelessWidget {
  const OnboardingProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil Viajero')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/main'),
          child: const Text('Finalizar y ver Home'),
        ),
      ),
    );
  }
}
""",
    "views/main/main_layout.dart": """import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../for_you/for_you_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ForYouScreen(),
    const Center(child: Text('Favoritos')),
    const Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Para Ti'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
""",
    "views/home/home_screen.dart": """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_controller.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadDestinations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: controller.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: controller.destinations.length,
            itemBuilder: (context, index) {
              final dest = controller.destinations[index];
              return ListTile(
                title: Text(dest.name),
                subtitle: Text(dest.city),
                onTap: () => context.push('/destination/${dest.id}'),
              );
            },
          ),
    );
  }
}
""",
    "views/for_you/for_you_screen.dart": """import 'package:flutter/material.dart';

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para Ti')),
      body: const Center(child: Text('Recomendaciones Simuladas')),
    );
  }
}
""",
    "views/destination/destination_detail_screen.dart": """import 'package:flutter/material.dart';

class DestinationDetailScreen extends StatelessWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle: $destinationId')),
      body: Center(child: Text('Detalle del destino: $destinationId')),
    );
  }
}
""",
    "views/search/search_results_screen.dart": """import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: const Center(child: Text('Resultados de Búsqueda')),
    );
  }
}
"""
}

for rel_path, content in files.items():
    with open(os.path.join(base_dir, rel_path), "w", encoding="utf-8") as f:
        f.write(content)

print("Vistas base implementadas.")
