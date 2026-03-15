# Aplikasi Manajemen Event Organizer Kampus - RIZQY/2409116039/A'2024

## Deskripsi Aplikasi

Event Organizer Kampus adalah aplikasi mobile yang dibangun menggunakan Flutter untuk memudahkan mahasiswa dan pengelola kampus dalam mengelola dan mengorganisir acara kampus. Aplikasi ini menyediakan antarmuka yang intuitif dan menarik untuk membuat, mengedit, melihat, dan menghapus event dengan fitur kategorisasi yang komprehensif.

Aplikasi ini dirancang dengan fokus pada kemudahan penggunaan dan desain UI yang modern dengan menggunakan:

### Nilai Tambah
1. Dark Mode dan Light Mode

## Fitur Aplikasi

### 1. **Menambah Event Baru**
   - Pengguna dapat membuat event baru dengan mengisi informasi:
     - Nama Event
     - Tanggal Event (dengan date picker)
     - Lokasi/Tempat
     - Deskripsi Event
     - Kategori Event (Umum, Seminar, Workshop, Konser, Olahraga, Sosial)
   - Validasi form untuk memastikan semua field terisi dengan benar

### 2. **Melihat Daftar Event**
   - Menampilkan semua event dalam bentuk kartu yang menarik
   - Untuk setiap event ditampilkan:
     - Nama event
     - Tanggal event
     - Lokasi event
     - Preview deskripsi
     - Badge kategori dengan warna dan icon unik
   - Empty state yang informatif jika belum ada event

### 3. **Mengedit Event**
   - Pengguna dapat mengubah informasi event yang sudah dibuat
   - Mengubah kategori event
   - Update semua detail event (nama, tanggal, lokasi, deskripsi)

### 4. **Menghapus Event**
   - Menghapus event dengan konfirmasi dialog
   - Snackbar feedback setelah event dihapus
   - Data event langsung hilang dari daftar

### 5. **Kategorisasi Event**
   - **Umum** - Acara umum (ikon: event)
   - **Seminar** - Kegiatan seminar dan diskusi (ikon: school)
   - **Workshop** - Workshop dan training (ikon: build)
   - **Konser** - Pertunjukan musik/konser (ikon: music_note)
   - **Olahraga** - Acara olahraga (ikon: sports_soccer)
   - **Sosial** - Kegiatan sosial (ikon: people)

### 6. **Antarmuka Modern**
   - Gradient header dengan warna purple dan magenta
   - Material Design 3
   - Responsive design untuk berbagai ukuran layar
   - Animasi floating action button
   - Color-coded categories untuk identifikasi visual yang lebih baik

## Widget yang Digunakan

### Layout Widgets
- **Scaffold**
- **CustomScrollView**
- **SliverPadding**
- **SliverToBoxAdapter**
- **SliverList**
- **SliverFillRemaining**
- **Column**
- **Row**
- **Expanded**
- **Stack**
- **Positioned**

### Navigasi & Action
- **FloatingActionButton.extended**
- **ScaleTransition**
- **Navigator**
- **MaterialPageRoute**

### Input dan Form
- **TextFormField**
- **Form**
- **DatePicker**

### UI Components - Display
- **AppBar**
- **Icon**
- **Text**
- **Container**
- **Card**
- **Chip**
- **GestureDetector**
- **InkWell**
- **Material**

### Dekoratif
- **LinearGradient**
- **BoxDecoration**
- **BorderRadius**
- **Border**
- **BoxShadow**

### Dialog & Feedback
- **AlertDialog**
- **TextButton**
- **ScaffoldMessenger**
- **SnackBar**

### State Management
- **StatefulWidget**
- **StatelessWidget**
- **setState**
- **TickerProviderStateMixin**

### Animation
- **AnimationController**
- **CurvedAnimation**
- **Tween**

## Arsitektur Halaman

- `main.dart`: inisialisasi Supabase, theme, dan navigasi utama (MainShell)
- `HomePage`: daftar event, penyaringan, pencarian, CRUD data, statistik, slide Transitions
- `AddEventPage`: form tambah event dengan validasi dan seleksi kategori
- `EditEventPage`: form edit event dengan data awal dan simpan perubahan
- `SettingsPage`: pilih mode tema (System/Light/Dark)

## Model Data

- `EventModel`: id, nama, tanggal, lokasi, deskripsi, kategori, createdAt

## Layanan Data

- `SupabaseService`:
  - `fetchEvents()`
  - `addEvent(EventModel event)`
  - `updateEvent(String id, EventModel event)`
  - `deleteEvent(String id)`



