# Manual de Usuario

## Roles
- **Admin**: control total.
- **Profesional**: veterinario.
- **Cliente**: usuario general.

## Admin
1. Login en `/login`.
2. Dashboard en `/admin`.
3. Gestionar usuarios en `/admin/usuarios`.
4. Gestionar categorias en `/admin/categorias`.
5. Ver todos los reportes en `/admin/reportes`.
6. Gestionar citas en `/admin/citas`.

## Profesional
1. Login.
2. Dashboard en `/profesional`.
3. Ver citas asignadas en `/profesional/citas`.
4. Configurar horarios en `/profesional/horarios`.
5. Ver historias en `/profesional/historias`.
6. Gestionar servicios en `/profesional/servicios`.

## Cliente
1. Login.
2. Dashboard en `/cliente`.
3. Ver mis citas en `/cliente/citas`.
4. Agendar cita en `/cliente/agendar`.
5. Ver historias en `/cliente/historias`.
6. Ver reportes de rescate en `/cliente/rescate`.
7. Crear reporte en `/cliente/rescate/nuevo`.

## Cambio de estado de reportes
Admin, Profesional y el creador del reporte pueden cambiar el estado.
Estados: activo, en_proceso, resuelto, cerrado.
