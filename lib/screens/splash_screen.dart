import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _permissionsGranted = false;
  bool _backendInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Solicitar permisos
    await _requestPermissions();
    
    // Simular inicialización del backend
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _backendInitialized = true;
    });

    // Verificar si el usuario ya está autenticado
    if (_permissionsGranted && _backendInitialized) {
      await _checkAuth();
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.notification,
      Permission.storage,
      Permission.location,
    ];

    Map<Permission, PermissionStatus> statuses = {};
    
    for (var permission in permissions) {
      if (await permission.isDenied) {
        final status = await permission.request();
        statuses[permission] = status;
      } else {
        statuses[permission] = await permission.status;
      }
    }

    setState(() {
      _permissionsGranted = true;
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación Lottie
              Lottie.asset(
                'Y2K Icon.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                repeat: true,
              ),
              const SizedBox(height: 40),
              
              // Logo con fade
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFBF40BF),
                      Color(0xFFFF6B35),
                      Color(0xFF39FF14),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'myEvent',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Indicador de carga
              if (!_permissionsGranted || !_backendInitialized)
                Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Color(0xFFBF40BF),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      !_permissionsGranted 
                          ? 'Solicitando permisos...' 
                          : 'Inicializando...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
