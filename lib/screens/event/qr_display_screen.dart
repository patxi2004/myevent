import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ticket.dart';
import '../../models/event.dart';
import '../../config/theme.dart';

class QRDisplayScreen extends StatelessWidget {
  final Ticket ticket;
  final Event event;

  const QRDisplayScreen({
    super.key,
    required this.ticket,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Boleto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Información del evento
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // QR Code
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Presenta este código en la entrada',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: ticket.qrCode,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Estado del boleto
                    _buildStatusChip(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información del boleto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('ID del Boleto:', ticket.id),
                    const Divider(),
                    _buildDetailRow('Precio:', '\$${ticket.price.toStringAsFixed(2)}'),
                    if (ticket.paymentMethod != null) ...[
                      const Divider(),
                      _buildDetailRow('Método de Pago:', ticket.paymentMethod!),
                    ],
                    const Divider(),
                    _buildDetailRow('Fecha de Compra:', _formatDate(ticket.purchaseDate)),
                  ],
                ),
              ),
            ),
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

  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (ticket.isUsed) {
      bgColor = Colors.grey;
      textColor = Colors.white;
      text = 'Usado';
      icon = Icons.check_circle;
    } else if (ticket.isPaid) {
      bgColor = AppTheme.neonGreen;
      textColor = Colors.black;
      text = 'Válido';
      icon = Icons.verified;
    } else {
      bgColor = Colors.orange;
      textColor = Colors.black;
      text = 'Pendiente de Pago';
      icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
