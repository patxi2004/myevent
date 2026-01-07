import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../config/theme.dart';

class QRScannerFAB extends StatefulWidget {
  const QRScannerFAB({super.key});

  @override
  State<QRScannerFAB> createState() => _QRScannerFABState();
}

class _QRScannerFABState extends State<QRScannerFAB> {
  Offset _position = const Offset(300, 500);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final viewPadding = MediaQuery.of(context).viewPadding;
    final fabSize = 56.0;
    final padding = 16.0;
    final bottomNavBarHeight = 80.0;
    
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              _position.dx + details.delta.dx,
              _position.dy + details.delta.dy,
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            // Constrain position to stay within screen bounds
            double newX = _position.dx;
            double newY = _position.dy;
            
            // Constrain X axis
            if (newX < padding) {
              newX = padding;
            } else if (newX > screenSize.width - fabSize - padding) {
              newX = screenSize.width - fabSize - padding;
            }
            
            // Constrain Y axis
            final topLimit = viewPadding.top + padding;
            final bottomLimit = screenSize.height - fabSize - bottomNavBarHeight - viewPadding.bottom - padding;
            
            if (newY < topLimit) {
              newY = topLimit;
            } else if (newY > bottomLimit) {
              newY = bottomLimit;
            }
            
            _position = Offset(newX, newY);
          });
        },
        child: _buildFab(),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
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
      child: FloatingActionButton(
        heroTag: 'qr_scanner',
        onPressed: _openScanner,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.qr_code_scanner, size: 30),
      ),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QRScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                return const Icon(Icons.flip_camera_ios);
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay con marco
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          
          // Instrucciones
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Coloca el código QR dentro del marco',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        await _validateQR(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _validateQR(String qrCode) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await ApiService.validateQR(authProvider.token!, qrCode);

      if (mounted) {
        Navigator.pop(context);
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al validar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final isValid = result['isValid'] ?? false;
    final isPaid = result['isPaid'] ?? false;
    final isUsed = result['isUsed'] ?? false;

    Color color;
    IconData icon;
    String title;
    String message;

    if (isValid && isPaid && !isUsed) {
      color = AppTheme.neonGreen;
      icon = Icons.check_circle;
      title = '✓ Boleto Válido';
      message = 'El boleto es válido y puede ingresar';
    } else if (isUsed) {
      color = Colors.orange;
      icon = Icons.warning;
      title = 'Boleto Usado';
      message = 'Este boleto ya fue utilizado';
    } else if (!isPaid) {
      color = Colors.red;
      icon = Icons.error;
      title = 'Pago Pendiente';
      message = 'El boleto no ha sido pagado';
    } else {
      color = Colors.red;
      icon = Icons.cancel;
      title = 'Boleto Inválido';
      message = 'El boleto no es válido';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        icon: Icon(icon, color: color, size: 64),
        title: Text(
          title,
          style: TextStyle(color: color),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (result['eventName'] != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Evento: ${result['eventName']}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
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

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = AppTheme.neonPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final frameSize = size.width * 0.7;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final frameRect = Rect.fromLTWH(left, top, frameSize, frameSize);

    // Dibujar overlay oscuro
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(20)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // Dibujar marco
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(20)),
      framePaint,
    );

    // Dibujar esquinas
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppTheme.neonPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Esquinas
    final corners = [
      // Top-left
      [Offset(left, top + cornerLength), Offset(left, top), Offset(left + cornerLength, top)],
      // Top-right
      [Offset(left + frameSize - cornerLength, top), Offset(left + frameSize, top), Offset(left + frameSize, top + cornerLength)],
      // Bottom-right
      [Offset(left + frameSize, top + frameSize - cornerLength), Offset(left + frameSize, top + frameSize), Offset(left + frameSize - cornerLength, top + frameSize)],
      // Bottom-left
      [Offset(left + cornerLength, top + frameSize), Offset(left, top + frameSize), Offset(left, top + frameSize - cornerLength)],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
