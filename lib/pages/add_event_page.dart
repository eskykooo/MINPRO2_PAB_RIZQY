import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final lokasiController = TextEditingController();
  final deskripsiController = TextEditingController();
  final tanggalController = TextEditingController();

  String selectedKategori = 'Umum';
  final List<String> kategoriOptions = ['Umum', 'Seminar', 'Workshop', 'Konser', 'Olahraga', 'Sosial'];

  late AnimationController _formController;
  late List<Animation<double>> _fieldAnimations;

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fieldAnimations = List.generate(6, (i) {
      final start = i * 0.12;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _formController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      );
    });
    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    namaController.dispose();
    lokasiController.dispose();
    deskripsiController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> pilihTanggal() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF7C3AED)),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      setState(() {
        tanggalController.text = DateFormat('dd MMMM yyyy').format(pickedDate);
      });
    }
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'seminar': return const Color(0xFFEC4899);
      case 'workshop': return const Color(0xFF3B82F6);
      case 'konser': return const Color(0xFFD946EF);
      case 'olahraga': return const Color(0xFFEAB308);
      case 'sosial': return const Color(0xFF10B981);
      default: return const Color(0xFF7C3AED);
    }
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'seminar': return Icons.school;
      case 'workshop': return Icons.build;
      case 'konser': return Icons.music_note;
      case 'olahraga': return Icons.sports_soccer;
      case 'sosial': return Icons.people;
      default: return Icons.event;
    }
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return AnimatedBuilder(
      animation: _fieldAnimations[index],
      builder: (context, _) => Transform.translate(
        offset: Offset(0, 30 * (1 - _fieldAnimations[index].value)),
        child: Opacity(opacity: _fieldAnimations[index].value, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Event", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildAnimatedField(0, _buildSectionLabel("Informasi Event")),
            const SizedBox(height: 12),
            _buildAnimatedField(0, _buildField(
              controller: namaController,
              label: "Nama Event",
              icon: Icons.event_rounded,
              validator: (v) => v!.isEmpty ? "Nama event tidak boleh kosong" : null,
            )),
            const SizedBox(height: 12),
            _buildAnimatedField(1, _buildField(
              controller: tanggalController,
              label: "Tanggal Event",
              icon: Icons.calendar_today_rounded,
              readOnly: true,
              onTap: pilihTanggal,
              validator: (v) => v!.isEmpty ? "Pilih tanggal event" : null,
            )),
            const SizedBox(height: 12),
            _buildAnimatedField(2, _buildField(
              controller: lokasiController,
              label: "Lokasi / Tempat",
              icon: Icons.location_on_rounded,
              validator: (v) => v!.isEmpty ? "Lokasi tidak boleh kosong" : null,
            )),
            const SizedBox(height: 12),
            _buildAnimatedField(3, _buildField(
              controller: deskripsiController,
              label: "Deskripsi Event",
              icon: Icons.description_rounded,
              maxLines: 4,
              validator: (v) => v!.isEmpty ? "Deskripsi tidak boleh kosong" : null,
            )),
            const SizedBox(height: 24),
            _buildAnimatedField(4, _buildSectionLabel("Kategori")),
            const SizedBox(height: 12),
            _buildAnimatedField(4, _buildCategorySelector()),
            const SizedBox(height: 32),
            _buildAnimatedField(5, SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final tanggalTerpilih = DateFormat('dd MMMM yyyy').parse(tanggalController.text);
                    final eventBaru = EventModel(
                      nama: namaController.text,
                      tanggal: tanggalTerpilih,
                      lokasi: lokasiController.text,
                      deskripsi: deskripsiController.text,
                      kategori: selectedKategori,
                    );
                    Navigator.pop(context, eventBaru);
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text("Simpan Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: const Color(0xFF7C3AED).withOpacity(0.4),
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kategoriOptions.map((kategori) {
        final isSelected = selectedKategori == kategori;
        final color = _getCategoryColor(kategori);
        final icon = _getCategoryIcon(kategori);
        return GestureDetector(
          onTap: () => setState(() => selectedKategori = kategori),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: isSelected ? 2 : 1),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isSelected ? Colors.white : color),
                const SizedBox(width: 6),
                Text(
                  kategori,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}