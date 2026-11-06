# Presentacion Tecnica del Proyecto

## 1. Introduccion
Sistema de gestion de citas veterinarias y reportes de rescate animal. Proyecto academico TCC 2026-2.

## 2. Stack Tecnologico
- **Frontend:** Flutter (Dart), Riverpod, GoRouter, Dio
- **Backend:** Node.js, Express, MongoDB Atlas
- **Despliegue:** Render (backend), APK (Android)
- **Autenticacion:** JWT

## 3. Arquitectura
Flutter (Dio) -> API REST (Render) -> MongoDB Atlas.

- El cliente envia peticiones HTTPS con JWT en el header `Authorization: Bearer <token>`.
- El backend valida el token con `middleware/auth.js`.
- MongoDB almacena los datos en colecciones.

## 4. Base de Datos (MongoDB)
### Colecciones principales
- `users`: Usuarios del sistema (admin, profesional, cliente)
- `reportesrescates`: Reportes de rescate animal
- `categoriarescates`: Categorias de rescate (Perdida, Encontrada, etc.)
- `appointments`: Citas veterinarias
- `services`: Servicios veterinarios
- `availability`: Horarios de profesionales
- `notifications`: Notificaciones
- `medicalrecords`: Historias clinicas

### Relaciones
- Un usuario puede tener muchos reportes y muchas citas.
- Un reporte pertenece a un usuario y a una categoria.
- Un reporte puede tener muchos seguimientos.
- Una cita pertenece a un cliente y a un profesional.

## 5. Modulos del Sistema
- **Auth:** Login, registro, perfil
- **Rescate:** CRUD de incidencias, seguimientos, estadisticas
- **Citas:** Agendar, ver, cambiar estado
- **Historias:** Crear y consultar historias clinicas
- **Disponibilidad:** Horarios del profesional
- **Notificaciones:** Campana con badge
- **Admin:** Gestion de usuarios y categorias
- **Servicios:** Servicios veterinarios

## 6. Seguridad
- Contrasenas hasheadas con bcryptjs
- JWT firmado con secreto
- CORS configurado
- Validacion de inputs con express-validator

## 7. Despliegue
- Backend: Render (`https://veterinaria-backend-s64b.onrender.com/api`)
- App: APK Android (69.7 MB)
- Base de datos: MongoDB Atlas

## 8. Demo Funcional (resumen)
1. Login como cliente.
2. Crear reporte de rescate.
3. Cambiar estado a "Resuelto".
4. Agendar cita.
5. Login como admin.
6. Ver dashboard con estadisticas.
7. Ver todos los reportes.

## 9. Conclusion
El sistema cumple con los requisitos del TCC: aplicacion movil funcional, backend en la nube, documentacion completa y APK listo para instalar.
