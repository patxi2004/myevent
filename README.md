## IMPORTANTE: Configuración del Backend

Esta aplicación necesita conectarse a un servidor backend. 

### Configurar la URL del servidor:

1. Abre el archivo: `lib/services/api_service.dart`
2. Busca la línea:
   ```dart
   static const String baseUrl = 'http://TU_IP:TU_PUERTO/api';
   ```
3. Reemplaza `TU_IP` y `TU_PUERTO` con la dirección IP y puerto de tu servidor casero.

Ejemplo:
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

### Para hacer tu servidor accesible desde cualquier parte del mundo:

1. **Configurar port forwarding en tu router**:
   - Accede a la configuración de tu router
   - Redirige el puerto de tu aplicación (ej: 3000) a la IP local de tu laptop

2. **Usar servicios de túnel (recomendado para pruebas)**:
   - ngrok: `ngrok http 3000`
   - localtunnel: `lt --port 3000`
   - Cloudflare Tunnel

3. **Obtener IP pública**:
   - Usa un servicio DDNS si tu IP cambia frecuentemente

### Estructura esperada del Backend:

El backend debe implementar los siguientes endpoints:

#### Auth
- POST `/api/auth/login` - Iniciar sesión
- POST `/api/auth/register` - Registrarse

#### Events
- GET `/api/events/popular` - Obtener eventos populares
- GET `/api/events/user/:userId` - Obtener eventos de usuario
- POST `/api/events` - Crear evento
- PUT `/api/events/:eventId` - Actualizar evento
- DELETE `/api/events/:eventId` - Eliminar evento

#### Tickets
- POST `/api/tickets/purchase` - Comprar boleto
- POST `/api/tickets/validate` - Validar QR
- GET `/api/tickets/user/:userId` - Obtener boletos de usuario

#### Messages
- GET `/api/messages/conversations/:userId` - Obtener conversaciones
- GET `/api/messages/:conversationId` - Obtener mensajes
- POST `/api/messages` - Enviar mensaje

#### Users
- GET `/api/users/:userId` - Obtener perfil
- PUT `/api/users/:userId` - Actualizar perfil

### Ejecutar la aplicación:

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Construir para Android
flutter build apk

# Construir para iOS
flutter build ios
```

### Características implementadas:

✅ Splash screen animado con Lottie (usando tu archivo Y2K Icon.json)
✅ Sistema de autenticación (login/registro)
✅ Tema oscuro con colores neón (morado, naranja, verde, azul)
✅ Navegación con bottom navigation bar (5 pantallas)
✅ Widget global de eventos (reutilizable en todas las pantallas)
✅ Pantalla de eventos populares con filtros
✅ Pantalla de mis eventos (próximos, pasados, cancelados)
✅ Pantalla de crear evento (modo básico y avanzado)
✅ Sistema de QR (generación y escaneo)
✅ Escáner QR flotante (draggable)
✅ Sistema de mensajes y chat
✅ Pantalla de perfil
✅ Sistema de notificaciones
✅ Permisos de cámara, ubicación, etc.
✅ Compra de boletos con métodos de pago
✅ Validación de QR en tiempo real

### Notas:

- El archivo `Y2K Icon.json` se utiliza en el splash screen
- Todos los colores neón están configurados en `lib/config/theme.dart`
- Los widgets globales están en `lib/widgets/`
- El modo administrador debe implementarse en el servidor backend
- Las notificaciones están configuradas pero requieren Firebase para push notifications

### Próximos pasos recomendados:

1. Implementar el backend con Node.js/Express o tu framework preferido
2. Configurar Firebase para notificaciones push
3. Implementar upload de imágenes (AWS S3, Cloudinary, etc.)
4. Agregar tests unitarios y de integración
5. Implementar analytics y crashlytics

¡La aplicación está lista para conectarse a tu backend!
