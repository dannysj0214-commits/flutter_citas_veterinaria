import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/profesional_dashboard_screen.dart';
import '../../features/dashboard/presentation/cliente_dashboard_screen.dart';
import '../../features/rescate/presentation/categorias_list_screen.dart';
import '../../features/rescate/presentation/categoria_form_screen.dart';
import '../../features/rescate/presentation/reportes_list_screen.dart';
import '../../features/rescate/presentation/reporte_form_screen.dart';
import '../../features/rescate/presentation/reporte_detalle_screen.dart';
import '../../features/citas/presentation/screens/agendar_cita_screen.dart';
import '../../features/citas/presentation/screens/mis_citas_screen.dart';
import '../../features/citas/presentation/screens/detalle_cita_screen.dart';
import '../../features/citas/presentation/screens/citas_profesional_screen.dart';
import '../../features/disponibilidad/presentation/horarios_screen.dart';
import '../../features/historias/presentation/screens/mis_historias_screen.dart';
import '../../features/historias/presentation/screens/crear_historia_screen.dart';
import '../../features/admin/presentation/admin_citas_screen.dart';
import '../../features/admin/presentation/usuarios_list_screen.dart';
import '../../features/admin/presentation/usuario_form_screen.dart';
import '../../features/servicios/presentation/servicios_screen.dart'; // 🌟 NUEVO

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isAuth = auth.isAuthenticated;
      final loc = state.matchedLocation;
      
      final isAuthRoute = loc == '/login' || loc == '/register' || loc == '/welcome';

      if (!isAuth && !isAuthRoute) return '/welcome';
      
      if (isAuth && (loc == '/login' || loc == '/register')) {
        final rol = auth.user?.rol;
        if (rol == 'admin') return '/admin';
        if (rol == 'profesional') return '/profesional';
        return '/cliente';
      }
      return null;
    },
    routes: [
      // ============ AUTH ============
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // ============ ADMIN ============
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(
        path: '/admin/usuarios',
        builder: (_, __) => const UsuariosListScreen(),
      ),
      GoRoute(
        path: '/admin/usuarios/nuevo',
        builder: (_, __) => const UsuarioFormScreen(),
      ),
      GoRoute(
        path: '/admin/categorias',
        builder: (_, __) => const CategoriasListScreen(),
      ),
      GoRoute(
        path: '/admin/categorias/nueva',
        builder: (_, __) => const CategoriaFormScreen(),
      ),
      GoRoute(
        path: '/admin/categorias/:id/editar',
        builder: (_, state) => CategoriaFormScreen(id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/reportes',
        builder: (_, __) => const ReportesListScreen(),
      ),
      GoRoute(
        path: '/admin/citas',
        builder: (_, __) => const AdminCitasScreen(),
      ),

      // ============ PROFESIONAL ============
      GoRoute(
        path: '/profesional',
        builder: (_, __) => const ProfesionalDashboardScreen(),
      ),
      GoRoute(
        path: '/profesional/citas',
        builder: (_, __) => const CitasProfesionalScreen(),
      ),
      GoRoute(
        path: '/profesional/horarios',
        builder: (_, __) => const HorariosScreen(),
      ),
      GoRoute(
        path: '/profesional/historias',
        builder: (_, __) => const MisHistoriasScreen(),
      ),
      GoRoute(
        path: '/profesional/historias/nueva',
        builder: (_, __) => const CrearHistoriaScreen(),
      ),
      GoRoute(
        path: '/profesional/servicios', // 🌟 NUEVA RUTA
        builder: (_, __) => const ServiciosScreen(),
      ),

      // ============ CLIENTE ============
      GoRoute(
        path: '/cliente',
        builder: (_, __) => const ClienteDashboardScreen(),
      ),
      GoRoute(
        path: '/cliente/citas',
        builder: (_, __) => const MisCitasScreen(),
      ),
      GoRoute(
        path: '/cliente/agendar',
        builder: (_, __) => const AgendarCitaScreen(),
      ),
      GoRoute(
        path: '/cliente/historias',
        builder: (_, __) => const MisHistoriasScreen(),
      ),
      GoRoute(
        path: '/cliente/rescate',
        builder: (_, __) => const ReportesListScreen(),
      ),
      GoRoute(
        path: '/cliente/rescate/nuevo',
        builder: (_, __) => const ReporteFormScreen(),
      ),
      GoRoute(
        path: '/cliente/rescate/:id',
        builder: (_, state) => ReporteDetalleScreen(id: state.pathParameters['id']!),
      ),

      // ============ COMPARTIDO ============
      GoRoute(
        path: '/citas/:id',
        builder: (_, state) => DetalleCitaScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/reportes/:id',
        builder: (_, state) => ReporteDetalleScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});