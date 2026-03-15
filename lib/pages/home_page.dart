import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/supabase_service.dart';
import 'add_event_page.dart';
import 'edit_event_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<EventModel> eventList = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Umum', 'Seminar', 'Workshop', 'Konser', 'Olahraga', 'Sosial'];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final events = await SupabaseService.fetchEvents();
      if (!mounted) return;
      setState(() {
        eventList = events;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat event: $e"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> tambahEvent(EventModel event) async {
    try {
      final created = await SupabaseService.addEvent(event);
      if (!mounted) return;
      setState(() => eventList.add(created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("Event berhasil ditambahkan"),
          ]),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menambah event: $e"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> updateEvent(int index, EventModel eventBaru) async {
    final current = eventList[index];
    if (current.id == null) return;
    try {
      final updated = await SupabaseService.updateEvent(current.id!, eventBaru);
      if (!mounted) return;
      setState(() => eventList[index] = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.edit, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("Event berhasil diperbarui"),
          ]),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui event: $e"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> hapusEvent(int index) async {
    final target = eventList[index];
    if (target.id == null) return;
    try {
      await SupabaseService.deleteEvent(target.id!);
      if (!mounted) return;
      setState(() => eventList.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.delete, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("Event berhasil dihapus"),
          ]),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus event: $e"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void konfirmasiHapus(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text("Hapus Event"),
          ]),
          content: const Text("Yakin ingin menghapus event ini? Tindakan ini tidak bisa dibatalkan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await hapusEvent(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Hapus"),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case "seminar": return const Color(0xFFEC4899);
      case "workshop": return const Color(0xFF3B82F6);
      case "konser": return const Color(0xFFD946EF);
      case "olahraga": return const Color(0xFFEAB308);
      case "sosial": return const Color(0xFF10B981);
      default: return const Color(0xFF7C3AED);
    }
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case "seminar": return Icons.school;
      case "workshop": return Icons.build;
      case "konser": return Icons.music_note;
      case "olahraga": return Icons.sports_soccer;
      case "sosial": return Icons.people;
      default: return Icons.event;
    }
  }

  List<EventModel> get _filteredAndSortedEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var filtered = eventList.where((event) {
      final matchSearch = event.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.lokasi.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFilter = _selectedFilter == 'Semua' || event.kategori == _selectedFilter;
      return matchSearch && matchFilter;
    }).toList();

    final upcoming = filtered.where((e) {
      final d = DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day);
      return !d.isBefore(today);
    }).toList()..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    final past = filtered.where((e) {
      final d = DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day);
      return d.isBefore(today);
    }).toList()..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return [...upcoming, ...past];
  }

  int get _upcomingCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return eventList.where((e) {
      final d = DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day);
      return !d.isBefore(today);
    }).length;
  }

  int get _pastCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return eventList.where((e) {
      final d = DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day);
      return d.isBefore(today);
    }).length;
  }

  Widget _buildAppBar() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? "Selamat Pagi" : now.hour < 17 ? "Selamat Siang" : "Selamat Malam";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF9F67FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isScrolled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        const Text("Campus Event Organizer", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text("Universitas Mulawarman · Samarinda", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                      ],
                    ),
                    GestureDetector(
                      onTap: _loadEvents,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(icon: Icons.event_available_rounded, label: "Mendatang", value: "$_upcomingCount", color: const Color(0xFF34D399)),
                    const SizedBox(width: 10),
                    _buildStatCard(icon: Icons.history_rounded, label: "Selesai", value: "$_pastCount", color: Colors.white60),
                    const SizedBox(width: 10),
                    _buildStatCard(icon: Icons.event_note_rounded, label: "Total", value: "${eventList.length}", color: const Color(0xFFFBBF24)),
                  ],
                ),
              ],
            ),
          ),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(
              children: [
                const Text("Campus Event", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                _buildCompactStat(Icons.event_available_rounded, "$_upcomingCount", const Color(0xFF34D399)),
                const SizedBox(width: 8),
                _buildCompactStat(Icons.history_rounded, "$_pastCount", Colors.white60),
                const SizedBox(width: 8),
                _buildCompactStat(Icons.event_note_rounded, "${eventList.length}", const Color(0xFFFBBF24)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loadEvents,
                  child: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Cari event atau lokasi...",
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7C3AED)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.transparent
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.transparent
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              final filter = _filterOptions[index];
              final isSelected = _selectedFilter == filter;
              final color = filter == 'Semua' ? const Color(0xFF7C3AED) : _getCategoryColor(filter);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color, width: isSelected ? 2 : 1),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter != 'Semua') ...[
                          Icon(_getCategoryIcon(filter), size: 13, color: isSelected ? Colors.white : color),
                          const SizedBox(width: 5),
                        ],
                        Text(filter, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : color)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEventListContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7C3AED)),
            SizedBox(height: 16),
            Text("Memuat event...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final sorted = _filteredAndSortedEvents;

    if (sorted.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 24),
            const Text("Tidak ada event ditemukan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Coba ubah kata kunci atau filter", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstPastIndex = sorted.indexWhere((e) {
      final d = DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day);
      return d.isBefore(today);
    });

    final List<Widget> items = [];
    for (int i = 0; i < sorted.length; i++) {
      final event = sorted[i];
      final originalIndex = eventList.indexOf(event);
      if (i == firstPastIndex) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                const Text("Event Selesai", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
                const SizedBox(width: 8),
                Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
              ],
            ),
          ),
        );
      }
      items.add(_buildEventCard(event, originalIndex, _getCategoryColor(event.kategori)));
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: const Color(0xFF7C3AED),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
        children: items,
      ),
    );
  }

  Widget _buildEventCard(EventModel event, int index, Color color) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(event.tanggal.year, event.tanggal.month, event.tanggal.day);
    final isSelesai = eventDate.isBefore(today);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: isSelesai
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(children: [
                        Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text("Event yang sudah selesai tidak dapat diubah"),
                      ]),
                      backgroundColor: Colors.grey[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              : () async {
                  final hasil = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, animation, __) => EditEventPage(event: event),
                      transitionsBuilder: (_, animation, __, child) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    ),
                  );
                  if (hasil != null) updateEvent(index, hasil);
                },
          child: Opacity(
            opacity: isSelesai ? 0.55 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isSelesai
                      ? [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)]
                      : [color.withOpacity(0.12), color.withOpacity(0.04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: isSelesai ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isSelesai ? Colors.grey.withOpacity(0.05) : color.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelesai ? Colors.grey.withOpacity(0.15) : color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelesai ? Colors.grey.withOpacity(0.4) : color.withOpacity(0.4)),
                      ),
                      child: Icon(_getCategoryIcon(event.kategori), color: isSelesai ? Colors.grey : color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.nama,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              decoration: isSelesai ? TextDecoration.lineThrough : null,
                              color: isSelesai ? Colors.grey : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(DateFormat('dd MMM yyyy').format(event.tanggal), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.lokasi,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelesai ? Colors.grey.withOpacity(0.15) : color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  event.kategori,
                                  style: TextStyle(fontSize: 10, color: isSelesai ? Colors.grey : color, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (isSelesai) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_outline_rounded, size: 10, color: Colors.grey),
                                      SizedBox(width: 3),
                                      Text("Selesai", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      onPressed: () => konfirmasiHapus(index),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchAndFilter(),
          Expanded(child: _buildEventListContent()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: FloatingActionButton.extended(
            onPressed: () async {
              final hasil = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const AddEventPage(),
                  transitionsBuilder: (_, animation, __, child) => SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ),
              );
              if (hasil != null) tambahEvent(hasil);
            },
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text("Tambah Event", style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 8,
          ),
        ),
      ),
    );
  }
}