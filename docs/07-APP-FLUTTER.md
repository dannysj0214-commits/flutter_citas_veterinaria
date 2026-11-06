# Arquitectura Flutter

## Stack
- Flutter 3.x / Dart 3.3+
- Riverpod (estado)
- GoRouter (navegacion)
- Dio (HTTP)
- flutter_secure_storage (JWT)

## Estructura lib/
- `main.dart`: Punto de entrada, envuelve en ProviderScope y MaterialApp.router
- `core/`: Configuracion, red, router, storage, tema, utils
- `features/`: 10 modulos (admin, auth, citas, dashboard, disponibilidad, historias, notificaciones, perfil, rescate, servicios)
- `shared/`: Widgets reutilizables

## Capas por Feature
- `data/`: Llamadas a API (ej. `reportes_rescate_api.dart`)
- `domain/`: Modelos (ej. `reporte_rescate_model.dart`)
- `presentation/`: Pantallas y providers (ej. `reporte_detalle_screen.dart`)

## Navegacion (GoRouter)
26 rutas organizadas por rol. Redireccion automatica a `/welcome` si no hay auth. Redireccion al dashboard segun rol si ya esta autenticado.

## Tema
Claro (`AppTheme.lightTheme`). Fondo `#F5F7FA`, surface `#FFFFFF`, accent `#0284C7`, texto `#1E293B`. Google Fonts Poppins.

## Red (DioClient)
- Base URL: `https://veterinaria-backend-s64b.onrender.com/api`
- Interceptor: Anade `Authorization: Bearer <token>`
- Si error 401: limpia el storage (fuerza logout)
