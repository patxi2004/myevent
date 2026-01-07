import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  bool _isAdvancedMode = false;
  final _formKey = GlobalKey<FormState>();
  
  // Basic fields
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  
  // Advanced fields
  final _locationTextController = TextEditingController();
  String? _mapLink;
  bool _allowOnlinePayment = true;
  bool _allowPhysicalPayment = true;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _locationTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Crear Evento',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonPurple,
                ),
              ),
              const SizedBox(height: 8),
              
              // Toggle de modo
              Row(
                children: [
                  const Text('Modo:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Básico'),
                    selected: !_isAdvancedMode,
                    onSelected: (selected) {
                      setState(() => _isAdvancedMode = false);
                    },
                    selectedColor: AppTheme.neonPurple,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Avanzado'),
                    selected: _isAdvancedMode,
                    onSelected: (selected) {
                      setState(() => _isAdvancedMode = true);
                    },
                    selectedColor: AppTheme.neonOrange,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Campos básicos
              _buildBasicFields(),
              
              // Campos avanzados
              if (_isAdvancedMode) ...[
                const SizedBox(height: 24),
                const Divider(color: AppTheme.neonPurple),
                const SizedBox(height: 16),
                const Text(
                  'Opciones Avanzadas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonOrange,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAdvancedFields(),
              ],
              
              const SizedBox(height: 32),
              
              // Botón de crear
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createEvent,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Crear Evento',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del evento *',
            prefixIcon: Icon(Icons.event, color: AppTheme.neonPurple),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Fecha
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha *',
              prefixIcon: Icon(Icons.calendar_today, color: AppTheme.neonPurple),
            ),
            child: Text(
              _selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                  : 'Seleccionar fecha',
              style: TextStyle(
                color: _selectedDate != null ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Hora
        InkWell(
          onTap: _selectTime,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Hora',
              prefixIcon: Icon(Icons.access_time, color: AppTheme.neonBlue),
            ),
            child: Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'Seleccionar hora (opcional)',
              style: TextStyle(
                color: _selectedTime != null ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Ubicación
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Ubicación',
            prefixIcon: Icon(Icons.location_on, color: AppTheme.neonGreen),
          ),
        ),
        const SizedBox(height: 16),
        
        // Precio
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Precio',
            prefixIcon: Icon(Icons.attach_money, color: AppTheme.neonGreen),
          ),
        ),
        const SizedBox(height: 16),
        
        // Capacidad
        TextFormField(
          controller: _capacityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Capacidad',
            prefixIcon: Icon(Icons.people, color: AppTheme.neonBlue),
          ),
        ),
        const SizedBox(height: 16),
        
        // Imagen
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(_imageUrl != null ? 'Imagen seleccionada' : 'Seleccionar imagen'),
        ),
        const SizedBox(height: 16),
        
        // Descripción
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ubicación detallada
        TextFormField(
          controller: _locationTextController,
          decoration: const InputDecoration(
            labelText: 'Descripción de ubicación',
            prefixIcon: Icon(Icons.map, color: AppTheme.neonOrange),
          ),
        ),
        const SizedBox(height: 16),
        
        // Link de mapa
        OutlinedButton.icon(
          onPressed: _selectMapLocation,
          icon: const Icon(Icons.share_location),
          label: Text(_mapLink != null ? 'Ubicación compartida' : 'Compartir ubicación'),
        ),
        const SizedBox(height: 16),
        
        // Métodos de pago
        const Text(
          'Métodos de pago permitidos:',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Pago en línea'),
          value: _allowOnlinePayment,
          onChanged: (value) {
            setState(() => _allowOnlinePayment = value ?? true);
          },
          activeColor: AppTheme.neonPurple,
        ),
        CheckboxListTile(
          title: const Text('Pago físico'),
          value: _allowPhysicalPayment,
          onChanged: (value) {
            setState(() => _allowPhysicalPayment = value ?? true);
          },
          activeColor: AppTheme.neonPurple,
        ),
        const SizedBox(height: 16),
        
        // Más opciones
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función de precio dinámico en desarrollo')),
            );
          },
          icon: const Icon(Icons.trending_up),
          label: const Text('Configurar precio dinámico'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonPurple,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonPurple,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageUrl = image.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen seleccionada')),
      );
    }
  }

  void _selectMapLocation() {
    // Aquí se implementaría la integración con Google Maps
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de ubicación en desarrollo')),
    );
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final eventData = {
      'name': _nameController.text,
      'date': _selectedDate!.toIso8601String(),
      'time': _selectedTime?.format(context),
      'location': _locationController.text.isEmpty ? null : _locationController.text,
      'price': _priceController.text.isEmpty ? null : double.tryParse(_priceController.text),
      'capacity': _capacityController.text.isEmpty ? null : int.tryParse(_capacityController.text),
      'imageUrl': _imageUrl,
      'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
      'locationText': _isAdvancedMode ? _locationTextController.text : null,
      'mapLink': _isAdvancedMode ? _mapLink : null,
      'allowedPaymentMethods': _isAdvancedMode ? [
        if (_allowOnlinePayment) {'id': '1', 'name': 'Online', 'isOnline': true},
        if (_allowPhysicalPayment) {'id': '2', 'name': 'Físico', 'isOnline': false},
      ] : null,
    };

    try {
      await eventProvider.createEvent(authProvider.token!, eventData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento creado exitosamente'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
        
        // Limpiar formulario
        _formKey.currentState!.reset();
        _nameController.clear();
        _locationController.clear();
        _priceController.clear();
        _capacityController.clear();
        _descriptionController.clear();
        _locationTextController.clear();
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _imageUrl = null;
          _mapLink = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear evento: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
