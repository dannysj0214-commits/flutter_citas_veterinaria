import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/profesional_dashboard_screen.dart';
import '../../features/dashboard/presentation/cliente_dashboard_screen.dart';
import '../../features/rescate/presentation/categorias_list_screen.dart';
import '../../features/rescate/presentation/categoria_form_screen.dart';
import '../../features/rescate/presentation/reportes_list_screen.dart';
import '../../features/rescate/presentation/reporte_form_screen.dart';
import '../../features/rescate/presentation/reporte_detalle_screen.dart';
import '../../features/admin/presentation/usuarios_list_screen.dart';
import '../../features/admin/presentation/usuario_form_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isAuth = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) {
        final rol = auth.user?.rol;
        if (rol == 'admin') return '/admin';
        if (rol == 'profesional') return '/profesional';
        return '/cliente';
      }
      return null;
    },
    routes: [
      // ===== AUTH =====
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // ===== DASHBOARDS =====
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(
        path: '/profesional',
        builder: (_, __) => const ProfesionalDashboardScreen(),
      ),
      GoRoute(
        path: '/cliente',
        builder: (_, __) => const ClienteDashboardScreen(),
      ),

      // ===== ADMIN: USUARIOS =====
      GoRoute(
        path: '/admin/usuarios',
        builder: (_, __) => const UsuariosListScreen(),
      ),
      GoRoute(
        path: '/admin/usuarios/nuevo',
        builder: (_, __) => const UsuarioFormScreen(),
      ),
      GoRoute(
        path: '/admin/usuarios/:id/editar',
        builder: (_, state) =>
            UsuarioFormScreen(id: state.pathParameters['id']),
      ),

      // ===== RESCATE: CATEGORÍAS =====
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
        builder: (_, state) =>
            CategoriaFormScreen(id: state.pathParameters['id']),
      ),

      // ===== RESCATE: REPORTES =====
      GoRoute(
        path: '/admin/reportes',
        builder: (_, __) => const ReportesListScreen(),
      ),
      GoRoute(
        path: '/admin/reportes/nuevo',
        builder: (_, __) => const ReporteFormScreen(),
      ),
      GoRoute(
        path: '/admin/reportes/:id',
        builder: (_, state) =>
            ReporteDetalleScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});