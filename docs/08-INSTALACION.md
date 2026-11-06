# Instalacion y Configuracion

## Requisitos
- Flutter SDK 3.x
- Backend en Render (ya desplegado)

## Pasos
1. Clonar el repo:
   git clone https://github.com/dannysj0214-commits/flutter_citas_veterinaria.git
2. Entrar a la carpeta:
   cd flutter_citas_veterinaria
3. Instalar dependencias:
   flutter pub get
4. Ejecutar en Chrome:
   flutter run -d chrome
   O en Windows:
   flutter run -d windows

## Backend
URL: https://veterinaria-backend-s64b.onrender.com/api
No requiere configuracion local (DioClient ya apunta a Render).

## Build APK
flutter build apk --release
El APK se genera en: build/app/outputs/flutter-apk/app-release.apk
