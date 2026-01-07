import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/event.dart';
import '../models/ticket.dart';
import '../models/message.dart';

class ApiService {
  // Using ngrok tunnel - accessible from anywhere
  // Mock server at: https://22e8497861b9.ngrok-free.app
  static const String baseUrl = 'https://22e8497861b9.ngrok-free.app';
  
  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Bypass ngrok browser warning
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Mock server: find user by email and password
    final response = await http.get(
      Uri.parse('$baseUrl/users?email=$email&password=$password'),
      headers: _headers(null),
    );
    
    if (response.statusCode == 200) {
      final users = jsonDecode(response.body) as List;
      if (users.isNotEmpty) {
        final user = users[0];
        return {
          'user': user,
          'token': user['token'],
        };
      } else {
        throw Exception('Credenciales incorrectas');
      }
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  static Future<Map<String, dynamic>> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(null),
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrarse');
    }
  }

  // Events
  static Future<List<Event>> getPopularEvents(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/popular'),
      headers: _headers(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener eventos');
    }
  }

  static Future<List<Event>> getMyEvents(String token, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/user/$userId'),
      headers: _headers(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener mis eventos');
    }
  }

  static Future<Event> createEvent(String token, Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: _headers(token),
      body: jsonEncode(eventData),
    );
    
    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear evento');
    }
  }

  static Future<void> deleteEvent(String token, String eventId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: _headers(token),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar evento');
    }
  }

  static Future<Event> updateEvent(String token, String eventId, Map<String, dynamic> eventData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: _headers(token),
      body: jsonEncode(eventData),
    );
    
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar evento');
    }
  }

  // Tickets
  static Future<Ticket> purchaseTicket(String token, String eventId, String paymentMethod) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets/purchase'),
      headers: _headers(token),
      body: jsonEncode({
        'eventId': eventId,
        'paymentMethod': paymentMethod,
      }),
    );
    
    if (response.statusCode == 201) {
      return Ticket.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al comprar boleto');
    }
  }

  static Future<Map<String, dynamic>> validateQR(String token, String qrCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets/validate'),
      headers: _headers(token),
      body: jsonEncode({'qrCode': qrCode}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al validar QR');
    }
  }

  static Future<List<Ticket>> getUserTickets(String token, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tickets/user/$userId'),
      headers: _headers(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Ticket.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener boletos');
    }
  }

  // Messages
  static Future<List<Conversation>> getConversations(String token, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations/$userId'),
      headers: _headers(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener conversaciones');
    }
  }

  static Future<List<Message>> getMessages(String token, String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: _headers(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener mensajes');
    }
  }

  static Future<Message> sendMessage(String token, String receiverId, String content, {String? imageUrl}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: _headers(token),
      body: jsonEncode({
        'receiverId': receiverId,
        'content': content,
        'imageUrl': imageUrl,
      }),
    );
    
    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al enviar mensaje');
    }
  }

  // User
  static Future<User> getUserProfile(String token, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers(token),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener perfil');
    }
  }

  static Future<User> updateUserProfile(String token, String userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers(token),
      body: jsonEncode(userData),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar perfil');
    }
  }
}
