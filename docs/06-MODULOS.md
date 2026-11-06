# Modulos del Sistema

## 1. Auth
Login, registro, welcome.
- Rutas API: `/api/auth/login`, `/api/auth/register`
- Pantallas: `login_screen.dart`, `register_screen.dart`, `welcome_screen.dart`

## 2. Dashboard
Panel por rol.
- Pantallas: `admin_dashboard_screen.dart`, `profesional_dashboard_screen.dart`, `cliente_dashboard_screen.dart`

## 3. Rescate (Nucleo del TCC)
Reportes de animales.
- Rutas API: `/api/reportes-rescate`, `/api/categorias-rescate`
- Pantallas: `reportes_list_screen.dart`, `reporte_form_screen.dart`, `reporte_detalle_screen.dart`, `categorias_list_screen.dart`

## 4. Citas
Agendar y gestionar citas.
- Rutas API: `/api/appointments`
- Pantallas: `agendar_cita_screen.dart`, `mis_citas_screen.dart`, `detalle_cita_screen.dart`, `citas_profesional_screen.dart`

## 5. Historias
Historias clinicas.
- Rutas API: `/api/medical-records`
- Pantallas: `mis_historias_screen.dart`, `crear_historia_screen.dart`

## 6. Disponibilidad
Horarios del profesional.
- Rutas API: `/api/availability`
- Pantallas: `horarios_screen.dart`

## 7. Notificaciones
Campana con badge.
- Rutas API: `/api/notifications`
- Provider: `notificaciones_provider.dart`

## 8. Admin
CRUD usuarios, categorias, citas.
- Rutas API: `/api/admin/usuarios`
- Pantallas: `usuarios_list_screen.dart`, `usuario_form_screen.dart`, `admin_citas_screen.dart`

## 9. Servicios
Servicios veterinarios.
- Pantallas: `servicios_screen.dart`

## 10. Perfil
Perfil del usuario (pendiente).
