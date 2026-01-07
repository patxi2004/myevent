import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/event_widget.dart';
import '../../config/theme.dart';
import '../../models/event.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de tabs tipo slider
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.neonPurple,
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Próximos'),
              Tab(text: 'Pasados'),
              Tab(text: 'Cancelados'),
            ],
          ),
        ),
        
        // Contenido de tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEventsList(EventStatus.upcoming),
              _buildEventsList(EventStatus.past),
              _buildEventsList(EventStatus.cancelled),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(EventStatus status) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.neonPurple,
      child: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.neonPurple),
            );
          }

          List<dynamic> events;
          switch (status) {
            case EventStatus.upcoming:
              events = [...eventProvider.myCreatedEvents, ...eventProvider.upcomingEvents]
                  .where((e) => e.status == EventStatus.upcoming)
                  .toSet()
                  .toList();
              break;
            case EventStatus.past:
              events = eventProvider.pastEvents;
              break;
            case EventStatus.cancelled:
              events = eventProvider.cancelledEvents;
              break;
          }

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyMessage(status),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final isCreator = events[index].creatorId == authProvider.currentUser?.id;
              
              return EventWidget(
                event: events[index],
                showEditButton: isCreator,
              );
            },
          );
        },
      ),
    );
  }

  String _getEmptyMessage(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return 'No tienes eventos próximos\n¡Crea o compra un boleto!';
      case EventStatus.past:
        return 'No hay eventos pasados';
      case EventStatus.cancelled:
        return 'No hay eventos cancelados';
    }
  }

  Future<void> _refresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.token != null && authProvider.currentUser != null) {
      await eventProvider.loadMyEvents(authProvider.token!, authProvider.currentUser!.id);
    }
  }
}
