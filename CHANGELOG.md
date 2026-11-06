# Changelog

## [Unreleased]
### Pendiente
- Generar APK release firmado
- Fix boton retroceso (`context.go` por rol)
- Permisos `CALL_PHONE` en `AndroidManifest.xml`
- Migrar `api_config.dart` a Render
- Anadir endpoints de rescate en `ApiConfig`

## [1.2.0] - 2026-11-05
### Anadido
- Modulo Servicios (`/profesional/servicios`)
- Provider `estadisticas_provider.dart`
- Integracion con Render: `https://veterinaria-backend-s64b.onrender.com/api`
- Interceptor JWT en `DioClient`

### Cambiado
- Tema oscuro a claro (`AppTheme.lightTheme`, paleta azul `#0284C7`)
- 26 rutas organizadas por rol
- Providers movidos a `presentation/providers/`

### Corregido
- `reporte_rescate_model.dart`: getter `idUsuarioString`
- `reporte_detalle_screen.dart`: permisos Admin/Pro/dueno
- `dio_client.dart`: timeout 30s

## [1.1.0] - 2026-10-24
### Anadido
- Modulo completo Rescate de Animales (6 categorias)
- CRUD reportes, seguimientos, estadisticas
- Botones Llamar/WhatsApp
- Ruta `/cliente/rescate/:id`

## [1.0.0] - 2026-10-01
### Anadido
- Migracion de React a Flutter
- JWT + `flutter_secure_storage`
- GoRouter con guardas
- Modulos: Auth, Dashboard, Citas, Historias, Disponibilidad, Notificaciones, Admin
- Graficas con `fl_chart`
- Generacion de PDF

## [0.1.0] - 2026-08-29
### Anadido
- Definicion inicial del proyecto (Tutoria 3)
- Stack: Flutter + Node + MongoDB
