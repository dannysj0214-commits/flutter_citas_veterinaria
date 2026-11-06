# Publicacion en Google Play (Opcional)

## Requisitos
1. Cuenta de Google Play Developer (25 USD unico).
2. APK firmado (release).
3. Icono de 512x512.
4. Capturas de pantalla (minimo 2).
5. Politica de privacidad (URL publica).

## Pasos
1. Generar keystore:
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
2. Configurar `android/key.properties`.
3. Configurar `android/app/build.gradle`.
4. Generar App Bundle:
   flutter build appbundle
5. Subir el `.aab` a Google Play Console.
6. Completar ficha (descripcion, capturas).
7. Enviar a revision.
