# Changelog

## [Unreleased]
### Pendiente
- Generar APK release firmado
- Fix boton retroceso (`context.go` por rol)
- Permisos `CALL_PHONE` en `AndroidManifest.xml`
- Migrar `api_config.dart` a Render
- Anadir endpoints de rescate en `ApiConfig`

# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

## [1.3.0] - 2026-11-05

### Anadido
- Documentacion completa en `docs/` (06-MODULOS, 07-APP-FLUTTER, 08-INSTALACION, 09-MANUAL-USUARIO, 11-ROADMAP, 12-PUBLICACION-PLAY)
- Guion de presentacion en `PRESENTACION/GUION-DEMO.md`
- Seccion "Descargar APK" en el README
- APK release generado (`app-release.apk` - 69.7 MB)

### Cambiado
- README actualizado con enlaces a la documentacion y estado del APK
- Tabla de Entregables del TCC actualizada (APK: OK)

### Corregido
- Error de compilacion en `dio_client.dart` (`baseUrl: baseUrl:` duplicado)

---

## [1.2.0] - 2026-11-05

### Anadido
- Modulo Servicios (`/profesional/servicios`)
- Provider `estadisticas_provider.dart`
- Integracion completa con Render
- Interceptor JWT en `DioClient` con manejo de 401

### Cambiado
- Tema oscuro a claro (`AppTheme.lightTheme`, paleta azul)
- 26 rutas organizadas por rol
- Providers movidos a `presentation/providers/`

### Corregido
- `reporte_rescate_model.dart`: getter `idUsuarioString`
- `reporte_detalle_screen.dart`: permisos Admin/Pro/dueno
- `dio_client.dart`: timeout 30s

---

## [1.1.0] - 2026-10-24

### Anadido
- Modulo completo de Rescate de Animales (6 categorias)
- CRUD de reportes, seguimientos y estadisticas
- Botones Llamar/WhatsApp
- Ruta `/cliente/rescate/:id`

### Cambiado
- Permisos de cambio de estado: Admin, Profesional y Creador

---

## [1.0.0] - 2026-10-01

### Anadido
- Migracion de React a Flutter
- Autenticacion con JWT
- GoRouter con guardas por rol
- Modulos base (Auth, Dashboard, Citas, Historias, etc.)
- Graficas con `fl_chart`
- Generacion de PDF

---

## [0.1.0] - 2026-08-29

### Anadido
- Definicion inicial del proyecto (Tutoria 3)
- Stack: Flutter + Node + MongoDB