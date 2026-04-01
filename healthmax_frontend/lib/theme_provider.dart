import 'package:flutter/material.dart';

// ==========================================
// TRANSLATION DICTIONARY
// ==========================================
class AppTranslations {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      // Nav & General
      'home': 'Home', 'history': 'History', 'calorie': 'Calorie', 'statistics': 'Statistics', 'target': 'Target', 'edit': 'Edit', 'close': 'Close', 'status': 'Status',
      // Timeframes & Metrics
      'Day': 'Day', 'Week': 'Week', 'Month': 'Month', 'Year': 'Year',
      'Heart Rate': 'Heart Rate', 'Steps': 'Steps', 'Calories': 'Calories', 'Blood Glucose': 'Blood Glucose', 'Env. Noise': 'Env. Noise',
      // Settings (FIXED: 'connected' no longer has the '1')
      'preferences': 'PREFERENCES', 'language': 'Language', 'font_size': 'Font Size', 'account_info': 'Account Information', 'notifications': 'Notifications', 'manage_hp': 'Manage Healthcare Providers', 'connected_devices': 'Connected Devices', 'health_goals': 'Health Goals', 'dark_mode': 'Dark Mode', 'privacy': 'Privacy & Security', 'actions': 'ACTIONS', 'verify_email': 'VERIFY EMAIL', 'export_data': 'EXPORT HEALTH DATA', 'log_out': 'LOG OUT', 'manage': 'Manage', 'on': 'On', 'connected': 'Connected',
      // Homepage
      'hi': 'Hi,', 'last_updated': 'Last Updated :', 'live_syncing': 'Live Syncing...', 'steps_label': 'Steps:', 'quick_action': 'Quick Action', 'feedback': 'Feedback', 'burned_calories': 'Burned Calories', 'kcal_burned': 'kcal burned today', 'cancel': 'Cancel', 'reschedule': 'Reschedule', 'status_normal': 'Normal', 'status_quiet': 'Quiet',
      // Calorie Page & History
      'calorie_intake': 'Calorie Intake.', 'today': 'Today', 'eaten': 'Eaten', 'burned': 'Burned', 'kcal_left': 'kcal left.', 'intake_breakdown': 'Intake Breakdown', 'carbohydrates': 'Carbohydrates', 'protein': 'Protein', 'fats': 'Fats', 'summary': 'Summary', 'log_food': 'Log Food', 'remaining': 'remaining', 'detailed_breakdown': 'Detailed macronutrient breakdown for', 'daily_breakdown': 'Daily Breakdown', 'total_intake': 'Total Intake',
      // Target Page
      'your_target': 'Your Target.', 'main_goal': 'MAIN GOAL', 'no_goal_yet': 'No Goal Yet', 'set_goal_desc': 'Set a main health goal to let AI personalize your experience.', 'target_label': 'Target:', 'your_score': 'Your Score :', 'daily_goals': 'DAILY GOALS', 'ranking': 'Ranking', 'set_new_target': 'Set New Target',
      // Statistics Page
      'live_record': 'LIVE RECORD', 'latest_record': 'LATEST RECORD', 'sync_cloud_data': 'Sync Cloud Data', 'syncing': 'Syncing...', 'data_breakdown': 'DATA BREAKDOWN', 'todays_record': 'Today\'s Record', 'daily_avg': 'Daily Avg', 'compare_data': 'Compare Data', 'request_feedback': 'Request Feedback', 'cloud_sync_complete': 'Cloud Sync Complete!', 'failed_to_connect': 'Failed to connect.',
      // Log Food Page
      'ai_assist': 'AI Assist', 'manual_write': 'Manual Write', 'upload_or_take': 'upload or take a picture', 'retake_picture': 'Retake picture', 'describe_meal': 'or describe your meal here', 'ai_estimation': 'AI Estimation', 'ai_analysis_notes': 'AI Analysis Notes', 'meal_name': 'Meal Name', 'enter_in_gram': 'Enter in gram', 'add_a_comment': 'add a comment..', 'add_to_intake': 'Add to My Intake',
      // Manage HP
      'providers': 'Providers.', 'search_hp': 'Search for Healthcare Provider', 'no_connected_hp': 'You have no connected healthcare providers.', 'no_pending_requests': 'You have no pending requests.', 'contact': 'Contact', 'remove': 'Remove', 'request_to_connect': 'Request to Connect', 'connect_to': 'Connect to:', 'select_data_accessed': 'Select Data To Be Accessed:', 'determine_timeframe': 'Determine Timeframe:', 'connect': 'Connect', 'Hearing Data': 'Hearing Data', 'requests': 'Requests',
      'analytics_overview': 'ANALYTICS OVERVIEW', 'trends': 'Trends', 'based_on_live_data': 'Based on live data from', 'connected_patients': 'connected patients.', 'recent_patient_alerts': 'RECENT PATIENT ALERTS', 'system_health_ok': 'All hospital systems are operational. Device sync is at 98% efficiency.', 'connected_users': 'Connected Users', 'need_attention': 'NEED\nATTENTION', 'clinic_preferences': 'CLINIC PREFERENCES', 'clinic_info': 'Clinic Information', 'verified': 'Verified', 'alerts_notifications': 'Alerts & Notifications', 'urgent_only': 'Urgent Only', 'patient_data_access': 'Patient Data Access', 'security': 'Security', 'generate_clinic_report': 'GENERATE CLINIC REPORT', 'users': 'Users.', 'search_patients_hint': 'Search patients by name or ID...', 'active_patients': 'ACTIVE PATIENTS', 'total': 'Total', 'no_patients_found': 'No patients found.', 'sort_patients': 'Sort Patients', 'device': 'Device',
    },
    'ms': {
      'home': 'Utama', 'history': 'Sejarah', 'calorie': 'Kalori', 'statistics': 'Statistik', 'target': 'Sasaran', 'edit': 'Sunting', 'close': 'Tutup', 'status': 'Status',
      'Day': 'Hari', 'Week': 'Minggu', 'Month': 'Bulan', 'Year': 'Tahun',
      'Heart Rate': 'Kadar Jantung', 'Steps': 'Langkah', 'Calories': 'Kalori', 'Blood Glucose': 'Glukosa Darah', 'Env. Noise': 'Bunyi Sekitar',
      'preferences': 'KEUTAMAAN', 'language': 'Bahasa', 'font_size': 'Saiz Tulisan', 'account_info': 'Maklumat Akaun', 'notifications': 'Pemberitahuan', 'manage_hp': 'Urus Penyedia Penjagaan Kesihatan', 'connected_devices': 'Peranti Disambungkan', 'health_goals': 'Matlamat Kesihatan', 'dark_mode': 'Mod Gelap', 'privacy': 'Privasi & Keselamatan', 'actions': 'TINDAKAN', 'verify_email': 'SAHKAN E-MEL', 'export_data': 'EKSPORT DATA KESIHATAN', 'log_out': 'LOG KELUAR', 'manage': 'Urus', 'on': 'Hidup', 'connected': 'Bersambung',
      'hi': 'Hai,', 'last_updated': 'Kemas Kini Terakhir :', 'live_syncing': 'Penyegerakan...', 'steps_label': 'Langkah:', 'quick_action': 'Tindakan Pantas', 'feedback': 'Maklum Balas', 'burned_calories': 'Kalori Dibakar', 'kcal_burned': 'kcal dibakar', 'cancel': 'Batal', 'reschedule': 'Jadual Semula', 'status_normal': 'Normal', 'status_quiet': 'Senyap',
      'calorie_intake': 'Pengambilan Kalori.', 'today': 'Hari Ini', 'eaten': 'Dimakan', 'burned': 'Dibakar', 'kcal_left': 'kcal baki.', 'intake_breakdown': 'Pecahan Pengambilan', 'carbohydrates': 'Karbohidrat', 'protein': 'Protein', 'fats': 'Lemak', 'summary': 'Ringkasan', 'log_food': 'Log Makanan', 'remaining': 'baki', 'detailed_breakdown': 'Pecahan makronutrien terperinci untuk', 'daily_breakdown': 'Pecahan Harian', 'total_intake': 'Jumlah Pengambilan',
      'your_target': 'Sasaran Anda.', 'main_goal': 'MATLAMAT UTAMA', 'no_goal_yet': 'Belum Ada Matlamat', 'set_goal_desc': 'Tetapkan matlamat untuk membenarkan AI mengubahsuai pengalaman anda.', 'target_label': 'Sasaran:', 'your_score': 'Skor Anda :', 'daily_goals': 'MATLAMAT HARIAN', 'ranking': 'Kedudukan', 'set_new_target': 'Tetapkan Sasaran Baru',
      'live_record': 'REKOD LANGSUNG', 'latest_record': 'REKOD TERKINI', 'sync_cloud_data': 'Segerak Data Awan', 'syncing': 'Menyegerak...', 'data_breakdown': 'PECAHAN DATA', 'todays_record': 'Rekod Hari Ini', 'daily_avg': 'Purata Harian', 'compare_data': 'Bandingkan Data', 'request_feedback': 'Minta Maklum Balas', 'cloud_sync_complete': 'Segerak Awan Selesai!', 'failed_to_connect': 'Gagal menyambung.',
      'ai_assist': 'Bantuan AI', 'manual_write': 'Tulis Manual', 'upload_or_take': 'muat naik atau ambil gambar', 'retake_picture': 'Ambil semula gambar', 'describe_meal': 'atau terangkan hidangan anda', 'ai_estimation': 'Anggaran AI', 'ai_analysis_notes': 'Nota Analisis AI', 'meal_name': 'Nama Hidangan', 'enter_in_gram': 'Masukkan dalam gram', 'add_a_comment': 'tambah komen..', 'add_to_intake': 'Tambah ke Pengambilan',
      'providers': 'Penyedia.', 'search_hp': 'Cari Penyedia Penjagaan Kesihatan', 'no_connected_hp': 'Anda tiada penyedia penjagaan kesihatan yang disambungkan.', 'no_pending_requests': 'Anda tiada permintaan yang belum selesai.', 'contact': 'Hubungi', 'remove': 'Buang', 'request_to_connect': 'Minta untuk Menyambung', 'connect_to': 'Sambung ke:', 'select_data_accessed': 'Pilih Data Untuk Diakses:', 'determine_timeframe': 'Tentukan Tempoh Masa:', 'connect': 'Sambung', 'Hearing Data': 'Data Pendengaran', 'requests': 'Permintaan',
      'analytics_overview': 'TINJAUAN ANALITIK', 'trends': 'Trend', 'based_on_live_data': 'Berdasarkan data langsung daripada', 'connected_patients': 'pesakit yang bersambung.', 'recent_patient_alerts': 'AMARAN PESAKIT TERKINI', 'system_health_ok': 'Semua sistem hospital beroperasi. Penyegerakan peranti pada kecekapan 98%.', 'connected_users': 'Pengguna Bersambung', 'need_attention': 'PERLU\nPERHATIAN', 'clinic_preferences': 'KEUTAMAAN KLINIK', 'clinic_info': 'Maklumat Klinik', 'verified': 'Disahkan', 'alerts_notifications': 'Amaran & Pemberitahuan', 'urgent_only': 'Kecemasan Sahaja', 'patient_data_access': 'Akses Data Pesakit', 'security': 'Keselamatan', 'generate_clinic_report': 'JANA LAPORAN KLINIK', 'users': 'Pengguna.', 'search_patients_hint': 'Cari pesakit melalui nama atau ID...', 'active_patients': 'PESAKIT AKTIF', 'total': 'Jumlah', 'no_patients_found': 'Tiada pesakit ditemui.',('sort_patients'):('Susun Pesakit'),('device'):('Peranti'),
    },
    'zh': {
      'preferences': '偏好设置', 'language': '语言', 'font_size': '字体大小', 'account_info': '账户信息', 'notifications': '通知', 'manage_hp': '管理医疗保健提供者', 'connected_devices': '已连接的设备', 'health_goals': '健康目标', 'dark_mode': '深色模式', 'privacy': '隐私与安全', 'actions': '操作', 'verify_email': '验证电子邮件', 'export_data': '导出健康数据', 'log_out': '登出', 'manage': '管理', 'on': '开启', 'connected': '已连接',
      'home': '首页', 'history': '历史', 'calorie': '卡路里', 'statistics': '统计', 'target': '目标', 'edit': '编辑', 'close': '关闭',
    },
    'ta': {
      'preferences': 'விருப்பங்கள்', 'language': 'மொழி', 'font_size': 'எழுத்துரு அளவு', 'account_info': 'கணக்கு தகவல்', 'notifications': 'அறிவிப்புகள்', 'manage_hp': 'சுகாதார வழங்குநர்களை நிர்வகி', 'connected_devices': 'இணைக்கப்பட்ட சாதனங்கள்', 'health_goals': 'சுகாதார இலக்குகள்', 'dark_mode': 'இருண்ட பயன்முறை', 'privacy': 'தனியுரிமை மற்றும் பாதுகாப்பு', 'actions': 'செயல்கள்', 'verify_email': 'மின்னஞ்சலைச் சரிபார்க்கவும்', 'export_data': 'சுகாதாரத் தரவை ஏற்றுமதி செய்', 'log_out': 'வெளியேறு', 'manage': 'நிர்வகி', 'on': 'ஆன்', 'connected': 'இணைக்கப்பட்டுள்ளது',
      'home': 'முகப்பு', 'history': 'வரலாறு', 'calorie': 'கலோரி', 'statistics': 'புள்ளிவிவரங்கள்', 'target': 'இலக்கு', 'edit': 'திருத்து', 'close': 'மூடு',
    }
  };

  static String getText(String languageCode, String key) {
    return translations[languageCode]?[key] ?? translations['en']?[key] ?? key;
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  String currentLanguage = 'en';
  double fontScale = 1.0; 

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void changeLanguage(String langCode) {
    currentLanguage = langCode;
    notifyListeners();
  }

  void updateFontScale(double scale) {
    fontScale = scale;
    notifyListeners();
  }

  String translate(String key) {
    return AppTranslations.getText(currentLanguage, key);
  }

  static final lightTheme = ThemeData(
    fontFamily: "LexendExaNormal", 
    scaffoldBackgroundColor: const Color(0xFFF8F9FA), 
    primaryColor: const Color(0xFF8E33FF),            
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8E33FF),
      surface: Colors.white,           
      onSurface: Colors.black87,       
      secondary: Color(0xFFF8F9FA),    
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black87),
    dividerColor: Colors.grey.shade200,
  );

  static final darkTheme = ThemeData(
    fontFamily: "LexendExaNormal", 
    scaffoldBackgroundColor: const Color(0xFF09090B), 
    primaryColor: const Color(0xFF8E33FF),            
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8E33FF),
      surface: Color(0xFF18181B),      
      onSurface: Colors.white,         
      secondary: Color(0xFF2C2C2E),    
    ),
    cardColor: const Color(0xFF18181B),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white10,
  );
}