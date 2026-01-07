import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
// DEBUG CODE - REMOVE BEFORE PRODUCTION
import '../services/debug_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> _myCreatedEvents = [];
  List<Event> _myAttendingEvents = [];
  List<Ticket> _myTickets = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  List<Event> get myCreatedEvents => _myCreatedEvents;
  List<Event> get myAttendingEvents => _myAttendingEvents;
  List<Ticket> get myTickets => _myTickets;
  bool get isLoading => _isLoading;

  List<Event> get upcomingEvents => _myAttendingEvents
      .where((e) => e.status == EventStatus.upcoming)
      .toList();
  
  List<Event> get pastEvents => _myAttendingEvents
      .where((e) => e.status == EventStatus.past)
      .toList();
  
  List<Event> get cancelledEvents => _myAttendingEvents
      .where((e) => e.status == EventStatus.cancelled)
      .toList();

  Future<void> loadPopularEvents(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await ApiService.getPopularEvents(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMyEvents(String token, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allEvents = await ApiService.getMyEvents(token, userId);
      _myCreatedEvents = allEvents.where((e) => e.creatorId == userId).toList();
      
      // Cargar tickets para eventos en los que asiste
      _myTickets = await ApiService.getUserTickets(token, userId);
      _myAttendingEvents = allEvents
          .where((e) => _myTickets.any((t) => t.eventId == e.id))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Event> createEvent(String token, Map<String, dynamic> eventData) async {
    try {
      final newEvent = await ApiService.createEvent(token, eventData);
      _events.add(newEvent);
      _myCreatedEvents.add(newEvent);
      notifyListeners();
      return newEvent;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String token, String eventId) async {
    try {
      await ApiService.deleteEvent(token, eventId);
      _events.removeWhere((e) => e.id == eventId);
      _myCreatedEvents.removeWhere((e) => e.id == eventId);
      _myAttendingEvents.removeWhere((e) => e.id == eventId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> updateEvent(String token, String eventId, Map<String, dynamic> eventData) async {
    try {
      final updatedEvent = await ApiService.updateEvent(token, eventId, eventData);
      
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) _events[index] = updatedEvent;
      
      final createdIndex = _myCreatedEvents.indexWhere((e) => e.id == eventId);
      if (createdIndex != -1) _myCreatedEvents[createdIndex] = updatedEvent;
      
      notifyListeners();
      return updatedEvent;
    } catch (e) {
      rethrow;
    }
  }

  Future<Ticket> purchaseTicket(String token, String eventId, String paymentMethod) async {
    try {
      final ticket = await ApiService.purchaseTicket(token, eventId, paymentMethod);
      _myTickets.add(ticket);
      
      // Agregar evento a mis eventos de asistencia
      final event = _events.firstWhere((e) => e.id == eventId);
      if (!_myAttendingEvents.any((e) => e.id == eventId)) {
        _myAttendingEvents.add(event);
      }
      
      notifyListeners();
      return ticket;
    } catch (e) {
      rethrow;
    }
  }

  Ticket? getTicketForEvent(String eventId) {
    try {
      return _myTickets.firstWhere((t) => t.eventId == eventId);
    } catch (e) {
      return null;
    }
  }

  bool hasTicketForEvent(String eventId) {
    return _myTickets.any((t) => t.eventId == eventId);
  }

  // DEBUG CODE - REMOVE BEFORE PRODUCTION
  // This method loads demo events for testing
  void loadDemoEvents() {
    _events = DebugService.generateDemoEvents();
    _myCreatedEvents = _events; // All demo events are created by debug user
    _myAttendingEvents = [];
    _myTickets = [];
    notifyListeners();
  }
}
