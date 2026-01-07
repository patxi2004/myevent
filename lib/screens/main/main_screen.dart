import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/message_provider.dart';
import '../../config/theme.dart';
import '../../utils/bottom_sheet_utils.dart';
import '../../models/event.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import 'popular_events_screen.dart';
import 'my_events_screen.dart';
import '../event/create_event_screen.dart';
import '../event/event_detail_screen.dart';
import '../messages/messages_screen.dart';
import '../messages/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/qr_scanner_fab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const PopularEventsScreen(),
    const MyEventsScreen(),
    const CreateEventScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);

    if (authProvider.token != null && authProvider.currentUser != null) {
      try {
        await Future.wait([
          eventProvider.loadPopularEvents(authProvider.token!),
          eventProvider.loadMyEvents(authProvider.token!, authProvider.currentUser!.id),
          messageProvider.loadConversations(authProvider.token!, authProvider.currentUser!.id),
        ]);
      } catch (e) {
        print('Error cargando datos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showMenu(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
        leadingWidth: 120,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          
          // QR Scanner FAB flotante (solo visible en Mis eventos)
          if (_currentIndex == 1)
            const QRScannerFAB(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Populares',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Mis Eventos',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 28),
            ),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final unreadCount = messageProvider.unreadCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.message),
                    if (unreadCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    BottomSheetUtils.showAppBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: AppTheme.neonPurple),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                _showAbout(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: AppTheme.neonBlue),
              title: const Text('Ayuda'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: EventSearchDelegate(),
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
      ],
    );
  }

  void _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}

// Settings Screen Placeholder
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          ListTile(
            leading: const Icon(Icons.language, color: AppTheme.neonBlue),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppTheme.neonOrange),
            title: const Text('Privacidad'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Search Delegate
class EventSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.darkSurface,
        iconTheme: IconThemeData(color: AppTheme.neonPurple),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _GlobalSearchResults(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _GlobalSearchResults(query: query, isSearching: true);
  }
}

class _GlobalSearchResults extends StatefulWidget {
  final String query;
  final bool isSearching;

  const _GlobalSearchResults({
    required this.query,
    this.isSearching = false,
  });

  @override
  State<_GlobalSearchResults> createState() => _GlobalSearchResultsState();
}

class _GlobalSearchResultsState extends State<_GlobalSearchResults> {
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }
    
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final messageProvider = Provider.of<MessageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (widget.query.isEmpty) {
      return Container(
        color: AppTheme.darkBackground,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              const Text(
                'Búsquedas recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonPurple,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final recentQuery = _recentSearches[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.white54),
                    title: Text(recentQuery),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () async {
                        setState(() => _recentSearches.removeAt(index));
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList('recent_searches', _recentSearches);
                      },
                    ),
                    onTap: () {
                      // Update query in search delegate
                      // This will be handled by the parent
                    },
                  );
                },
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Ingresa un término de búsqueda',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Save search when user is actively searching
    if (!widget.isSearching) {
      _saveSearch(widget.query);
    }

    // Perform search across all events
    final allEvents = [
      ...eventProvider.events,
      ...eventProvider.myCreatedEvents,
      ...eventProvider.myAttendingEvents,
    ].toSet().toList();

    final eventResults = <SearchResult>[];
    final query = widget.query.toLowerCase();

    for (final event in allEvents) {
      // Search in event name
      if (event.name.toLowerCase().contains(query)) {
        eventResults.add(SearchResult(
          type: SearchResultType.eventName,
          event: event,
          matchedText: event.name,
          highlightQuery: widget.query,
        ));
      }

      // Search in description
      if (event.description != null && event.description!.toLowerCase().contains(query)) {
        eventResults.add(SearchResult(
          type: SearchResultType.eventDescription,
          event: event,
          matchedText: event.description!,
          highlightQuery: widget.query,
        ));
      }

      // Search in location
      if (event.location != null && event.location!.toLowerCase().contains(query)) {
        eventResults.add(SearchResult(
          type: SearchResultType.eventLocation,
          event: event,
          matchedText: event.location!,
          highlightQuery: widget.query,
        ));
      }

      // Search in location text
      if (event.locationText != null && event.locationText!.toLowerCase().contains(query)) {
        eventResults.add(SearchResult(
          type: SearchResultType.eventLocation,
          event: event,
          matchedText: event.locationText!,
          highlightQuery: widget.query,
        ));
      }
    }

    // Search in messages
    final messageResults = <SearchResult>[];
    final conversations = messageProvider.conversations;

    for (final conversation in conversations) {
      final messages = messageProvider.getMessages(conversation.id);
      for (final message in messages) {
        if (message.content.toLowerCase().contains(query)) {
          messageResults.add(SearchResult(
            type: SearchResultType.message,
            message: message,
            conversation: conversation,
            matchedText: message.content,
            highlightQuery: widget.query,
          ));
        }
      }
    }

    if (eventResults.isEmpty && messageResults.isEmpty) {
      return Container(
        color: AppTheme.darkBackground,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.darkBackground,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event results
          if (eventResults.isNotEmpty) ...[
            _buildSectionHeader('Eventos', eventResults.length),
            const SizedBox(height: 12),
            ...eventResults.map((result) => _buildEventResultTile(context, result)),
            const SizedBox(height: 24),
          ],

          // Message results
          if (messageResults.isNotEmpty) ...[
            _buildSectionHeader('Mensajes', messageResults.length),
            const SizedBox(height: 12),
            ...messageResults.map((result) => _buildMessageResultTile(context, result, authProvider)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.neonPurple,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.neonPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventResultTile(BuildContext context, SearchResult result) {
    String typeLabel = '';
    IconData typeIcon = Icons.event;

    switch (result.type) {
      case SearchResultType.eventName:
        typeLabel = 'Nombre';
        typeIcon = Icons.event;
        break;
      case SearchResultType.eventDescription:
        typeLabel = 'Descripción';
        typeIcon = Icons.description;
        break;
      case SearchResultType.eventLocation:
        typeLabel = 'Ubicación';
        typeIcon = Icons.location_on;
        break;
      default:
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
          child: Icon(typeIcon, color: AppTheme.neonPurple, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                result.event!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                typeLabel,
                style: const TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: _buildHighlightedText(result.matchedText, result.highlightQuery),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: result.event!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageResultTile(BuildContext context, SearchResult result, AuthProvider authProvider) {
    final conversation = result.conversation!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.neonBlue.withOpacity(0.2),
          child: conversation.otherUserImage != null
              ? ClipOval(
                  child: Image.network(
                    conversation.otherUserImage!,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                )
              : const Icon(Icons.person, color: AppTheme.neonBlue),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.otherUserName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Mensaje',
                style: TextStyle(
                  color: AppTheme.neonBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: _buildHighlightedText(result.matchedText, result.highlightQuery),
        onTap: () {
          // Create a User object for the chat screen
          final otherUser = User(
            id: conversation.otherUserId,
            email: '',
            username: conversation.otherUserName,
            profileImage: conversation.otherUserImage,
            createdAt: DateTime.now(),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conversation.id,
                otherUser: otherUser,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(
            text: text.substring(start),
            style: const TextStyle(color: Colors.white70),
          ));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(color: Colors.white70),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          color: AppTheme.neonPurple,
          fontWeight: FontWeight.bold,
          backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

enum SearchResultType {
  eventName,
  eventDescription,
  eventLocation,
  message,
}

class SearchResult {
  final SearchResultType type;
  final Event? event;
  final Message? message;
  final Conversation? conversation;
  final String matchedText;
  final String highlightQuery;

  SearchResult({
    required this.type,
    this.event,
    this.message,
    this.conversation,
    required this.matchedText,
    required this.highlightQuery,
  });
}
