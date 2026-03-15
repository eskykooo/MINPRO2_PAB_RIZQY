import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class SupabaseService {
  SupabaseService._();

  static final _client = Supabase.instance.client;

  static Future<List<EventModel>> fetchEvents() async {
    final data = await _client
        .from('events')
        .select()
        .order('created_at', ascending: true);

    return (data as List)
        .map((item) => EventModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<EventModel> addEvent(EventModel event) async {
    final uuid = Uuid();
    final generatedId = event.id ?? uuid.v4();

    final data = await _client
        .from('events')
        .insert({
          'id': generatedId,
          'nama': event.nama,
          'tanggal': event.tanggal.toIso8601String(),
          'lokasi': event.lokasi,
          'deskripsi': event.deskripsi,
          'kategori': event.kategori,
        })
        .select()
        .single();

    return EventModel.fromJson(data);
  }

  static Future<EventModel> updateEvent(String id, EventModel event) async {
    final data = await _client
        .from('events')
        .update({
          'nama': event.nama,
          'tanggal': event.tanggal.toIso8601String(),
          'lokasi': event.lokasi,
          'deskripsi': event.deskripsi,
          'kategori': event.kategori,
        })
        .eq('id', id)
        .select()
        .single();

    return EventModel.fromJson(data);
  }

  static Future<void> deleteEvent(String id) async {
    await _client
        .from('events')
        .delete()
        .eq('id', id);
  }
}