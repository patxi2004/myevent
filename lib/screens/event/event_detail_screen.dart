import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../utils/bottom_sheet_utils.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.darkCard,
                      child: const Center(
                        child: Icon(
                          Icons.event,
                          size: 80,
                          color: AppTheme.neonPurple,
                        ),
                      ),
                    ),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del evento
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonPurple,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Información del evento
                  _buildInfoCard(context),
                  
                  const SizedBox(height: 24),
                  
                  // Descripción
                  if (event.description != null) ...[
                    const Text(
                      'Sobre el evento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Botones de acción
                  _buildActionButtons(context),
                  
                  // Bottom padding for system UI
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              _formatDate(event.date),
            ),
            if (event.time != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.access_time,
                'Hora',
                event.time!,
              ),
            ],
            if (event.location != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.location_on,
                'Ubicación',
                event.location!,
              ),
            ],
            if (event.price != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.attach_money,
                'Precio',
                '\$${event.price!.toStringAsFixed(2)}',
              ),
            ],
            if (event.capacity != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.people,
                'Capacidad',
                '${event.capacity} personas',
              ),
            ],
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.confirmation_number,
              'Boletos vendidos',
              '${event.ticketsSold}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.neonPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.neonPurple, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        final hasTicket = eventProvider.hasTicketForEvent(event.id);
        
        return Column(
          children: [
            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasTicket
                    ? null
                    : () => _showPurchaseDialog(context, eventProvider, authProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: hasTicket ? Colors.grey : AppTheme.neonPurple,
                ),
                child: Text(
                  hasTicket ? 'Ya tienes un boleto' : 'Comprar Boleto',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Botón de más información
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Mostrar más información
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  'Más Información',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    EventProvider eventProvider,
    AuthProvider authProvider,
  ) {
    BottomSheetUtils.showAppBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comprar Boleto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Evento: ${event.name}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio: \$${event.price?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Método de pago:',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            
            // Opciones de pago
            ListTile(
              leading: const Icon(Icons.payment, color: AppTheme.neonPurple),
              title: const Text('Pago en línea'),
              onTap: () => _processPurchase(context, eventProvider, authProvider, 'online'),
            ),
            ListTile(
              leading: const Icon(Icons.money, color: AppTheme.neonOrange),
              title: const Text('Pago físico'),
              onTap: () => _processPurchase(context, eventProvider, authProvider, 'cash'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPurchase(
    BuildContext context,
    EventProvider eventProvider,
    AuthProvider authProvider,
    String paymentMethod,
  ) async {
    Navigator.pop(context); // Cerrar el modal

    try {
      await eventProvider.purchaseTicket(
        authProvider.token!,
        event.id,
        paymentMethod,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Boleto comprado exitosamente!'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
        
        // Navegar a la pantalla del QR
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al comprar boleto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
