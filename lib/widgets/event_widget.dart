import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../utils/bottom_sheet_utils.dart';
import '../screens/event/event_detail_screen.dart';
import '../screens/event/qr_display_screen.dart';

class EventWidget extends StatelessWidget {
  final Event event;
  final bool showEditButton;

  const EventWidget({
    super.key,
    required this.event,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final hasTicket = eventProvider.hasTicketForEvent(event.id);
    final isCreator = event.creatorId == authProvider.currentUser?.id;

    return GestureDetector(
      onTap: () => _handleTap(context, hasTicket),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Imagen del evento
            AspectRatio(
              aspectRatio: 1,
              child: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            // Overlay gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            
            // Información básica
            Positioned(
              bottom: 50,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppTheme.neonPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (event.price != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$${event.price!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Barra de acciones
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.95),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Eliminar
                    if (isCreator)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _handleDelete(context),
                      ),
                    
                    // Más información
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: AppTheme.neonBlue, size: 20),
                      onPressed: () => _showMoreInfo(context),
                    ),
                    
                    // Editar (solo si es creador)
                    if (isCreator && showEditButton)
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.neonOrange, size: 20),
                        onPressed: () => _handleEdit(context),
                      ),
                  ],
                ),
              ),
            ),
            
            // Badge de comprado
            if (hasTicket)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        'Comprado',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.darkCard,
      child: const Center(
        child: Icon(
          Icons.event,
          size: 60,
          color: AppTheme.neonPurple,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleTap(BuildContext context, bool hasTicket) {
    if (hasTicket) {
      // Mostrar QR
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final ticket = eventProvider.getTicketForEvent(event.id);
      if (ticket != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QRDisplayScreen(ticket: ticket, event: event),
          ),
        );
      }
    } else {
      // Mostrar detalle del evento
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event),
        ),
      );
    }
  }

  void _showMoreInfo(BuildContext context) {
    BottomSheetUtils.showScrollableBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              event.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, _formatDate(event.date)),
            if (event.time != null)
              _buildInfoRow(Icons.access_time, event.time!),
            if (event.location != null)
              _buildInfoRow(Icons.location_on, event.location!),
            if (event.price != null)
              _buildInfoRow(Icons.attach_money, '\$${event.price!.toStringAsFixed(2)}'),
            if (event.capacity != null)
              _buildInfoRow(Icons.people, 'Cupo: ${event.capacity}'),
            if (event.description != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Descripción:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description!,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.neonBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Eliminar evento'),
        content: const Text('¿Estás seguro de que quieres eliminar este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        await eventProvider.deleteEvent(authProvider.token!, event.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento eliminado exitosamente'),
              backgroundColor: AppTheme.neonGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleEdit(BuildContext context) {
    // Navegar a pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de edición en desarrollo')),
    );
  }
}
