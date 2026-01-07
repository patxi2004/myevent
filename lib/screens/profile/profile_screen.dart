import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Center(child: Text('No hay usuario'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Foto de perfil
              GestureDetector(
                onTap: () => _changeProfilePicture(context, authProvider),
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.neonPurple, AppTheme.neonBlue],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPurple.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: user.profileImage != null
                          ? ClipOval(
                              child: Image.network(
                                user.profileImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                user.username[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.neonOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.darkBackground, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nombre de usuario
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      color: AppTheme.neonBlue,
                      size: 24,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Opciones de perfil
              _buildOptionCard(
                context,
                icon: Icons.person,
                title: 'Editar Perfil',
                subtitle: 'Cambia tu información personal',
                onTap: () => _editProfile(context, authProvider),
              ),
              
              const SizedBox(height: 16),
              
              _buildOptionCard(
                context,
                icon: Icons.settings,
                title: 'Configuración',
                subtitle: 'Preferencias de la aplicación',
                onTap: () => _showSettings(context),
              ),
              
              const SizedBox(height: 16),
              
              _buildOptionCard(
                context,
                icon: Icons.notifications,
                title: 'Notificaciones',
                subtitle: 'Gestiona tus notificaciones',
                onTap: () => _showNotificationSettings(context),
              ),
              
              const SizedBox(height: 16),
              
              _buildOptionCard(
                context,
                icon: Icons.help,
                title: 'Ayuda y Soporte',
                subtitle: '¿Necesitas ayuda?',
                onTap: () => _showHelp(context),
              ),
              
              const SizedBox(height: 16),
              
              _buildOptionCard(
                context,
                icon: Icons.info,
                title: 'Acerca de',
                subtitle: 'Información de la app',
                onTap: () => _showAbout(context),
              ),
              
              const SizedBox(height: 32),
              
              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context, authProvider),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.neonPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.neonPurple),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _changeProfilePicture(BuildContext context, AuthProvider authProvider) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Aquí se subiría la imagen al servidor
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función de cambio de foto en desarrollo')),
      );
    }
  }

  void _editProfile(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(authProvider: authProvider),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsDetailScreen()),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración de notificaciones en desarrollo')),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Ayuda y Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Necesitas ayuda?'),
            SizedBox(height: 16),
            Text('Email: soporte@myevent.com'),
            Text('Teléfono: +123 456 7890'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'myEvent',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.event, size: 48, color: AppTheme.neonPurple),
      children: [
        const Text('Aplicación integral para organizar, crear, vender y gestionar eventos.'),
        const SizedBox(height: 16),
        const Text('© 2025 myEvent. Todos los derechos reservados.'),
      ],
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

// Dialog para editar perfil
class EditProfileDialog extends StatefulWidget {
  final AuthProvider authProvider;

  const EditProfileDialog({super.key, required this.authProvider});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.authProvider.currentUser?.username,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkCard,
      title: const Text('Editar Perfil'),
      content: TextField(
        controller: _usernameController,
        decoration: const InputDecoration(
          labelText: 'Nombre de usuario',
          prefixIcon: Icon(Icons.person, color: AppTheme.neonPurple),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    try {
      await widget.authProvider.updateProfile({
        'username': _usernameController.text,
      });
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Pantalla de configuración detallada
class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications, color: AppTheme.neonPurple),
            title: const Text('Notificaciones'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: AppTheme.neonPurple,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: AppTheme.neonBlue),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppTheme.neonOrange),
            title: const Text('Tema Oscuro'),
            subtitle: const Text('Siempre activado'),
            trailing: Switch(
              value: true,
              onChanged: null,
              activeThumbColor: AppTheme.neonPurple,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppTheme.neonGreen),
            title: const Text('Privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
