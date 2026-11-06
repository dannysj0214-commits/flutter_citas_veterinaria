# Citas Veterinaria - App Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.5-40C4FF?logo=flutter&logoColor=white)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/GoRouter-14.2-6E56CF?logo=flutter&logoColor=white)](https://pub.dev/packages/go_router)
[![Dio](https://img.shields.io/badge/Dio-5.5-0175C2?logo=flutter&logoColor=white)](https://pub.dev/packages/dio)
[![Backend](https://img.shields.io/badge/Backend-Render-46E3B7?logo=render&logoColor=white)](https://render.com)
[![License](https://img.shields.io/badge/License-Academica-blue)](#)

Aplicacion **Flutter** para la gestion de citas veterinarias y reportes de rescate animal, que consume la API REST del backend desplegado en **Render**. Proyecto academico **TCC 2026-2**.

> **Backend en produccion:** `https://veterinaria-backend-s64b.onrender.com/api`
>
> **Visualizacion actual:** PC (Chrome/Edge/Windows). El APK Android esta en proceso de build.

---

## Tabla de Contenidos

- [Descripcion](#-descripcion)
- [Roles del Sistema](#-roles-del-sistema)
- [Stack Tecnologico](#-stack-tecnologico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Modulos del Sistema](#-modulos-del-sistema)
- [Rutas de Navegacion](#-rutas-de-navegacion)
- [Documentacion](#-documentacion)
- [Como Ejecutar](#-como-ejecutar)
- [Entregables del TCC](#-entregables-del-tcc)

---

## Descripcion

App movil/escritorio desarrollada en **Flutter** que permite a los usuarios de una clinica veterinaria y comunidad:

- **Reportar incidencias de rescate animal** (perdidos, encontrados, en adopcion, maltrato, urgencias)
- **Dar seguimiento** a los casos con estados `activo`, `en_proceso`, `resuelto`, `cerrado`
- **Agendar citas veterinarias** con profesionales
- **Consultar historias clinicas**
- **Recibir notificaciones**
- **Ver dashboards** con estadisticas por rol

---

## Roles del Sistema

| Rol | Descripcion | Acceso |
|---|---|---|
| **Admin** | Administrador del sistema | `/admin` - CRUD usuarios, categorias, reportes, citas |
| **Profesional** | Veterinario / personal clinico | `/profesional` - Citas, horarios, historias, servicios |
| **Cliente** | Usuario general | `/cliente` - Agendar citas, historias, reportes de rescate |

---

## Stack Tecnologico

| Categoria | Paquete | Version |
|---|---|---|
| **Framework** | Flutter (Dart) | 3.x / Dart 3.3+ |
| **Estado** | `flutter_riverpod` | ^2.5.1 |
| **Navegacion** | `go_router` | ^14.2.0 |
| **HTTP** | `dio` | ^5.5.0 |
| **Almacenamiento seguro** | `flutter_secure_storage` | ^9.2.2 |
| **Preferencias** | `shared_preferences` | ^2.3.2 |
| **UI** | `google_fonts` + `cached_network_image` | ^6.2.1 / ^3.4.1 |
| **Fechas** | `intl` + `table_calendar` | ^0.19.0 / ^3.1.2 |
| **Graficas** | `fl_chart` | ^0.69.0 |
| **PDF** | `pdf` + `printing` + `path_provider` | ^3.11.1 / ^5.13.1 / ^2.1.4 |
| **Iconos** | `cupertino_icons` + `material_symbols_icons` | ^1.0.8 / ^4.2765.0 |
| **Contacto** | `url_launcher` | ^6.3.3 |
| **JSON** | `json_annotation` + `json_serializable` | ^4.9.0 / ^6.8.0 |
| **Launcher icon** | `flutter_launcher_icons` | ^0.13.1 |

> **Backend:** API REST en `https://veterinaria-backend-s64b.onrender.com/api` (Node + Express + MongoDB Atlas)

---

## Estructura del Proyecto

    flutter_citas_veterinaria/
    +-- lib/
    |   +-- main.dart
    |   +-- core/
    |   |   +-- config/api_config.dart
    |   |   +-- network/dio_client.dart
    |   |   +-- router/app_router.dart
    |   |   +-- storage/secure_storage_service.dart
    |   |   +-- theme/app_colors.dart + app_theme.dart
    |   |   +-- utils/
    |   +-- features/
    |   |   +-- admin/
    |   |   +-- auth/
    |   |   +-- citas/
    |   |   +-- dashboard/
    |   |   +-- disponibilidad/
    |   |   +-- historias/
    |   |   +-- notificaciones/
    |   |   +-- perfil/
    |   |   +-- rescate/
    |   |   +-- servicios/
    |   +-- shared/
    |       +-- utils/
    |       +-- widgets/
    +-- assets/images/logo.png
    +-- pubspec.yaml
    +-- README.md

---

## Modulos del Sistema

| # | Modulo | Descripcion |
|---|---|---|
| 1 | **Auth** | Login, registro, welcome |
| 2 | **Dashboard** | Panel por rol |
| 3 | **Rescate** | Reportes de animales (nucleo del TCC) |
| 4 | **Citas** | Agendar y gestionar citas |
| 5 | **Historias** | Historias clinicas |
| 6 | **Disponibilidad** | Horarios del profesional |
| 7 | **Notificaciones** | Campana con badge |
| 8 | **Admin** | CRUD usuarios, categorias, citas |
| 9 | **Servicios** | Servicios veterinarios |
| 10 | **Perfil** | Perfil del usuario |

---

## Rutas de Navegacion

### Publicas
- `/welcome` -> WelcomeScreen
- `/login` -> LoginScreen
- `/register` -> RegisterScreen

### Admin
- `/admin` -> AdminDashboardScreen
- `/admin/usuarios` -> UsuariosListScreen
- `/admin/usuarios/nuevo` -> UsuarioFormScreen
- `/admin/categorias` -> CategoriasListScreen
- `/admin/categorias/nueva` -> CategoriaFormScreen
- `/admin/categorias/:id/editar` -> CategoriaFormScreen
- `/admin/reportes` -> ReportesListScreen
- `/admin/citas` -> AdminCitasScreen

### Profesional
- `/profesional` -> ProfesionalDashboardScreen
- `/profesional/citas` -> CitasProfesionalScreen
- `/profesional/horarios` -> HorariosScreen
- `/profesional/historias` -> MisHistoriasScreen
- `/profesional/historias/nueva` -> CrearHistoriaScreen
- `/profesional/servicios` -> ServiciosScreen

### Cliente
- `/cliente` -> ClienteDashboardScreen
- `/cliente/citas` -> MisCitasScreen
- `/cliente/agendar` -> AgendarCitaScreen
- `/cliente/historias` -> MisHistoriasScreen
- `/cliente/rescate` -> ReportesListScreen
- `/cliente/rescate/nuevo` -> ReporteFormScreen
- `/cliente/rescate/:id` -> ReporteDetalleScreen

### Compartidas
- `/citas/:id` -> DetalleCitaScreen
- `/reportes/:id` -> ReporteDetalleScreen

---

## Documentacion

| Documento | Contenido |
|---|---|
| `docs/06-MODULOS.md` | Descripcion de los 10 modulos |
| `docs/07-APP-FLUTTER.md` | Arquitectura Flutter |
| `docs/08-INSTALACION.md` | Instalacion + build APK |
| `docs/09-MANUAL-USUARIO.md` | Guia por rol |
| `docs/11-ROADMAP-Y-PENDIENTES.md` | Estado real y pendientes |
| `docs/12-PUBLICACION-PLAY.md` | Guia Google Play |
| `PRESENTACION/GUION-DEMO.md` | Guion de demo |

---

## Como Ejecutar

    git clone https://github.com/dannysj0214-commits/flutter_citas_veterinaria.git
    cd flutter_citas_veterinaria
    flutter pub get
    flutter run -d chrome

La app se conecta automaticamente a `https://veterinaria-backend-s64b.onrender.com/api`.

### Build APK

    flutter build apk --release

---

## Entregables del TCC

| # | Entregable | Estado |
|---|---|---|
| 1 | Codigo fuente documentado | OK |
| 2 | Instrucciones de configuracion y uso | OK |
| 3 | APK generado y listo | En proceso |
| 4 | Publicacion en Google Play (opcional) | Opcional |
| 5 | Presentacion del proyecto | OK |

---

## Autor

**Danny SJ** - [@dannysj0214-commits](https://github.com/dannysj0214-commits)

Proyecto academico - TCC 2026-2