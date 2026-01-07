// ============================================
// DEBUG CODE - REMOVE BEFORE PRODUCTION
// ============================================
// This file contains debug functionality for development and testing.
// To remove debug features:
// 1. Delete this file (debug_service.dart)
// 2. Remove the debug button from login_screen.dart (search for "DEBUG BUTTON")
// 3. Remove the import of this file from login_screen.dart
// 4. Search codebase for "DEBUG" comments and remove related code
// ============================================

import '../models/user.dart';
import '../models/event.dart';

class DebugService {
  // Debug user that bypasses authentication
  static User getDebugUser() {
    return User(
      id: 'debug_user_001',
      email: 'debug@myevent.com',
      username: 'Debug User',
      profileImage: 'https://i.pravatar.cc/150?img=33',
      isVerified: true,
      createdAt: DateTime.now(),
    );
  }

  // Common payment methods for demo events
  static List<PaymentMethod> _freePayment() => [
    PaymentMethod(id: 'free', name: 'Free', isOnline: false),
  ];

  static List<PaymentMethod> _standardPayments() => [
    PaymentMethod(id: 'credit', name: 'Credit Card', isOnline: true),
    PaymentMethod(id: 'paypal', name: 'PayPal', isOnline: true),
  ];

  static List<PaymentMethod> _allPayments() => [
    PaymentMethod(id: 'credit', name: 'Credit Card', isOnline: true),
    PaymentMethod(id: 'paypal', name: 'PayPal', isOnline: true),
    PaymentMethod(id: 'crypto', name: 'Cryptocurrency', isOnline: true),
    PaymentMethod(id: 'bank', name: 'Bank Transfer', isOnline: true),
  ];

  static List<PaymentMethod> _cashPayments() => [
    PaymentMethod(id: 'credit', name: 'Credit Card', isOnline: true),
    PaymentMethod(id: 'cash', name: 'Cash', isOnline: false),
  ];

  // Generate comprehensive demo events showcasing all features
  static List<Event> generateDemoEvents() {
    final now = DateTime.now();
    
    return [
      // Event 1: Free community event with online streaming
      Event(
        id: 'demo_event_001',
        creatorId: 'debug_user_001',
        name: '🎉 Community Tech Meetup',
        date: now.add(const Duration(days: 7)),
        time: '18:00',
        location: 'https://meet.google.com/abc-defg-hij',
        locationText: 'Online via Google Meet',
        price: 0.0,
        capacity: 100,
        imageUrl: 'https://picsum.photos/400/300?random=1',
        description: 'Join us for a free community tech meetup! Learn about the latest trends in web development, network with fellow developers, and share your experiences. This is a virtual event accessible to everyone worldwide.',
        status: EventStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 10)),
        ticketsSold: 45,
        mapLink: null,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_001_general',
            name: 'Free Admission',
            price: 0.0,
            quantity: 55,
          ),
        ],
        allowedPaymentMethods: _freePayment(),
        advancedConfig: {
          'isOnline': true,
          'category': 'Technology',
          'tags': ['tech', 'community', 'free', 'online'],
        },
      ),

      // Event 2: Premium concert with VIP options
      Event(
        id: 'demo_event_002',
        creatorId: 'debug_user_001',
        name: '🎸 Rock Festival 2025',
        date: now.add(const Duration(days: 30)),
        time: '20:00',
        location: '40.7128,-74.0060',
        locationText: 'Madison Square Garden, New York',
        mapLink: 'https://maps.google.com/?q=40.7128,-74.0060',
        price: 150.0,
        capacity: 500,
        imageUrl: 'https://picsum.photos/400/300?random=2',
        description: 'The biggest rock festival of the year! Featuring top international bands, spectacular light shows, and unforgettable performances. VIP packages include backstage access and meet & greet opportunities.',
        status: EventStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 20)),
        ticketsSold: 320,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_002_general',
            name: 'General Admission',
            price: 150.0,
            quantity: 120,
          ),
          TicketTypeOption(
            id: 'ticket_002_vip',
            name: 'VIP Package',
            price: 450.0,
            quantity: 40,
          ),
          TicketTypeOption(
            id: 'ticket_002_early',
            name: 'Early Bird',
            price: 100.0,
            quantity: 20,
          ),
        ],
        dynamicPricing: {
          now.add(const Duration(days: 15)): 180.0,
          now.add(const Duration(days: 25)): 200.0,
        },
        allowedPaymentMethods: _allPayments(),
        advancedConfig: {
          'category': 'Music',
          'tags': ['rock', 'concert', 'festival', 'live music'],
          'ageRestriction': '18+',
        },
      ),

      // Event 3: Workshop with limited capacity
      Event(
        id: 'demo_event_003',
        creatorId: 'debug_user_001',
        name: '🎨 Digital Art Workshop',
        date: now.add(const Duration(days: 5)),
        time: '14:00',
        location: '51.5074,-0.1278',
        locationText: 'Creative Hub, London',
        mapLink: 'https://maps.google.com/?q=51.5074,-0.1278',
        price: 75.0,
        capacity: 20,
        imageUrl: 'https://picsum.photos/400/300?random=3',
        description: 'Hands-on workshop for aspiring digital artists. Learn professional techniques, get personalized feedback, and take home your creations. Materials included. Small group for individual attention.',
        status: EventStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 5)),
        ticketsSold: 18,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_003_general',
            name: 'Workshop Pass',
            price: 75.0,
            quantity: 2,
          ),
        ],
        allowedPaymentMethods: _standardPayments(),
        advancedConfig: {
          'category': 'Workshop',
          'tags': ['art', 'workshop', 'creative', 'learning'],
          'requirements': 'Bring your own laptop',
        },
      ),

      // Event 4: Charity gala with donation tiers
      Event(
        id: 'demo_event_004',
        creatorId: 'debug_user_001',
        name: '💝 Annual Charity Gala',
        date: now.add(const Duration(days: 60)),
        time: '19:00',
        location: '34.0522,-118.2437',
        locationText: 'Beverly Hilton, Los Angeles',
        mapLink: 'https://maps.google.com/?q=34.0522,-118.2437',
        price: 250.0,
        capacity: 300,
        imageUrl: 'https://picsum.photos/400/300?random=4',
        description: 'Join us for an elegant evening supporting local children\'s education. Features live auction, performances, and a gourmet dinner. All proceeds benefit the Education First Foundation.',
        status: EventStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 30)),
        ticketsSold: 150,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_004_supporter',
            name: 'Supporter',
            price: 250.0,
            quantity: 100,
          ),
          TicketTypeOption(
            id: 'ticket_004_patron',
            name: 'Patron',
            price: 500.0,
            quantity: 40,
          ),
          TicketTypeOption(
            id: 'ticket_004_benefactor',
            name: 'Benefactor',
            price: 1000.0,
            quantity: 10,
          ),
        ],
        allowedPaymentMethods: _allPayments(),
        advancedConfig: {
          'category': 'Charity',
          'tags': ['charity', 'gala', 'fundraiser', 'formal'],
          'dresscode': 'Black Tie',
        },
      ),

      // Event 5: Sports tournament
      Event(
        id: 'demo_event_005',
        creatorId: 'debug_user_001',
        name: '⚽ City Soccer Championship',
        date: now.add(const Duration(days: 14)),
        time: '10:00',
        location: '48.8566,2.3522',
        locationText: 'Parc des Princes, Paris',
        mapLink: 'https://maps.google.com/?q=48.8566,2.3522',
        price: 45.0,
        capacity: 1000,
        imageUrl: 'https://picsum.photos/400/300?random=5',
        description: 'Annual city soccer championship featuring local teams. Full day tournament with food vendors, kids activities, and live commentary. Family-friendly event.',
        status: EventStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 15)),
        ticketsSold: 600,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_005_single',
            name: 'Single Day Pass',
            price: 45.0,
            quantity: 300,
          ),
          TicketTypeOption(
            id: 'ticket_005_family',
            name: 'Family Pack (4)',
            price: 150.0,
            quantity: 100,
          ),
        ],
        allowedPaymentMethods: _cashPayments(),
        advancedConfig: {
          'category': 'Sports',
          'tags': ['sports', 'soccer', 'tournament', 'family'],
        },
      ),

      // Event 6: Past event (completed)
      Event(
        id: 'demo_event_006',
        creatorId: 'debug_user_001',
        name: '🎭 Theater Performance - Romeo & Juliet',
        date: now.subtract(const Duration(days: 5)),
        time: '19:30',
        location: '41.9028,12.4964',
        locationText: 'Teatro dell\'Opera, Rome',
        mapLink: 'https://maps.google.com/?q=41.9028,12.4964',
        price: 80.0,
        capacity: 250,
        imageUrl: 'https://picsum.photos/400/300?random=6',
        description: 'A stunning rendition of Shakespeare\'s timeless classic. This event has already taken place.',
        status: EventStatus.past,
        createdAt: now.subtract(const Duration(days: 40)),
        ticketsSold: 250,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_006_general',
            name: 'Standard Seating',
            price: 80.0,
            quantity: 0,
          ),
        ],
        allowedPaymentMethods: _standardPayments(),
        advancedConfig: {
          'category': 'Theater',
          'tags': ['theater', 'performance', 'shakespeare'],
        },
      ),

      // Event 7: Cancelled event
      Event(
        id: 'demo_event_007',
        creatorId: 'debug_user_001',
        name: '🎪 Circus Spectacular',
        date: now.add(const Duration(days: 3)),
        time: '15:00',
        location: '52.5200,13.4050',
        locationText: 'Tempodrom, Berlin',
        mapLink: 'https://maps.google.com/?q=52.5200,13.4050',
        price: 60.0,
        capacity: 400,
        imageUrl: 'https://picsum.photos/400/300?random=7',
        description: 'Unfortunately, this event has been cancelled due to unforeseen circumstances. Refunds are being processed.',
        status: EventStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 25)),
        ticketsSold: 85,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_007_general',
            name: 'General Admission',
            price: 60.0,
            quantity: 0,
          ),
        ],
        allowedPaymentMethods: _standardPayments(),
        advancedConfig: {
          'category': 'Entertainment',
          'tags': ['circus', 'family', 'cancelled'],
        },
      ),

      // Event 8: Conference with early bird pricing
      Event(
        id: 'demo_event_008',
        creatorId: 'debug_user_001',
        name: '💼 Global Tech Conference 2025',
        date: now.add(const Duration(days: 90)),
        time: '09:00',
        location: '37.7749,-122.4194',
        locationText: 'Moscone Center, San Francisco',
        mapLink: 'https://maps.google.com/?q=37.7749,-122.4194',
        price: 299.0,
        capacity: 2000,
        imageUrl: 'https://picsum.photos/400/300?random=8',
        description: 'The premier tech conference of the year. 3 days of keynotes, workshops, and networking with industry leaders. Early bird pricing available!',
        status: EventStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 60)),
        ticketsSold: 450,
        ticketTypes: [
          TicketTypeOption(
            id: 'ticket_008_early',
            name: 'Early Bird (ends soon)',
            price: 199.0,
            quantity: 100,
          ),
          TicketTypeOption(
            id: 'ticket_008_general',
            name: 'Standard Pass',
            price: 299.0,
            quantity: 1200,
          ),
          TicketTypeOption(
            id: 'ticket_008_vip',
            name: 'VIP Pass',
            price: 599.0,
            quantity: 250,
          ),
        ],
        dynamicPricing: {
          now.add(const Duration(days: 60)): 349.0,
          now.add(const Duration(days: 80)): 399.0,
        },
        allowedPaymentMethods: _allPayments(),
        advancedConfig: {
          'category': 'Conference',
          'tags': ['tech', 'conference', 'networking', 'business'],
          'includes': ['Conference bag', 'Lunch', 'Coffee breaks', 'Certificate'],
        },
      ),
    ];
  }

  // Get mock token for debug mode
  static String getDebugToken() {
    return 'debug_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}
