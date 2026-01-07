import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/event_widget.dart';
import '../../config/theme.dart';

class PopularEventsScreen extends StatefulWidget {
  const PopularEventsScreen({super.key});

  @override
  State<PopularEventsScreen> createState() => _PopularEventsScreenState();
}

class _PopularEventsScreenState extends State<PopularEventsScreen> {
  String _sortBy = 'recent'; // recent, price, type, location

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.neonPurple,
      child: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Recientes', 'recent'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Precio', 'price'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Tipo', 'type'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ubicación', 'location'),
                ],
              ),
            ),
          ),
          
          // Grid de eventos
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                if (eventProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.neonPurple),
                  );
                }

                final events = _getSortedEvents(eventProvider.events);

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay eventos disponibles',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return EventWidget(
                      event: events[index],
                      showEditButton: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: AppTheme.neonPurple.withOpacity(0.3),
      checkmarkColor: AppTheme.neonPurple,
      backgroundColor: AppTheme.darkCard,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.neonPurple : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  List<dynamic> _getSortedEvents(List<dynamic> events) {
    final sortedEvents = List.from(events);
    
    switch (_sortBy) {
      case 'recent':
        sortedEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price':
        sortedEvents.sort((a, b) {
          final priceA = a.price ?? double.infinity;
          final priceB = b.price ?? double.infinity;
          return priceA.compareTo(priceB);
        });
        break;
      case 'type':
        // Ordenar por nombre (podría ser por tipo si tuvieras ese campo)
        sortedEvents.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'location':
        sortedEvents.sort((a, b) {
          final locA = a.location ?? '';
          final locB = b.location ?? '';
          return locA.compareTo(locB);
        });
        break;
    }
    
    return sortedEvents;
  }

  Future<void> _refresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await eventProvider.loadPopularEvents(authProvider.token!);
    }
  }
}
