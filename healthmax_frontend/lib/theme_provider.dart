import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Settings
      'preferences': 'PREFERENCES', 'language': 'Language', 'font_size': 'Font Size', 'account_info': 'Account Information', 'notifications': 'Notifications', 'manage_hp': 'Manage Healthcare Providers', 'connected_devices': 'Connected Devices', 'health_goals': 'Health Goals', 'dark_mode': 'Dark Mode', 'privacy': 'Privacy & Security', 'actions': 'ACTIONS', 'verify_email': 'VERIFY EMAIL', 'export_data': 'EXPORT HEALTH DATA', 'log_out': 'LOG OUT', 'manage': 'Manage', 'on': 'On', 'connected': 'Connected',
      // Homepage
      'hi': 'Hi,', 'last_updated': 'Last Updated :', 'live_syncing': 'Live Syncing...', 'steps_label': 'Steps:', 'quick_action': 'Quick Action', 'feedback': 'Feedback', 'burned_calories': 'Burned Calories', 'kcal_burned': 'kcal burned today', 'cancel': 'Cancel', 'reschedule': 'Reschedule', 'status_normal': 'Normal', 'status_quiet': 'Quiet',
      // Calorie Page & History
      'calorie_intake': 'Calorie Intake.', 'today': 'Today', 'eaten': 'Eaten', 'burned': 'Burned', 'kcal_left': 'kcal left.', 'intake_breakdown': 'Intake Breakdown','calories' : 'Calories', 'carbohydrates': 'Carbohydrates', 'protein': 'Protein', 'fats': 'Fats', 'summary': 'Summary', 'log_food': 'Log Food', 'remaining': 'remaining', 'detailed_breakdown': 'Detailed macronutrient breakdown for', 'daily_breakdown': 'Daily Breakdown', 'total_intake': 'Total Intake',
      // Target Page
      'your_target': 'Your Target.', 'main_goal': 'MAIN GOAL', 'no_goal_yet': 'No Goal Yet', 'set_goal_desc': 'Set a main health goal to let AI personalize your experience.', 'target_label': 'Target:', 'your_score': 'Your Score :', 'daily_goals': 'DAILY GOALS', 'ranking': 'Ranking', 'set_new_target': 'Set New Target',
      // Statistics Page
      'live_record': 'LIVE RECORD', 'latest_record': 'LATEST RECORD', 'sync_cloud_data': 'Sync Cloud Data', 'syncing': 'Syncing...', 'data_breakdown': 'DATA BREAKDOWN', 'todays_record': 'Today\'s Record', 'daily_avg': 'Daily Avg', 'compare_data': 'Compare Data', 'request_feedback': 'Request Feedback', 'cloud_sync_complete': 'Cloud Sync Complete!', 'failed_to_connect': 'Failed to connect.',
      // Log Food Page
      'ai_assist': 'AI Assist', 'manual_write': 'Manual Write', 'upload_or_take': 'upload or take a picture', 'retake_picture': 'Retake picture', 'describe_meal': 'or describe your meal here', 'ai_estimation': 'AI Estimation', 'ai_analysis_notes': 'AI Analysis Notes', 'meal_name': 'Meal Name', 'enter_in_gram': 'Enter in gram', 'add_a_comment': 'add a comment..', 'add_to_intake': 'Add to My Intake',
      // Manage HP
      'providers': 'Providers.', 'search_hp': 'Search for Healthcare Provider', 'no_connected_hp': 'You have no connected healthcare providers.', 'no_pending_requests': 'You have no pending requests.', 'contact': 'Contact', 'remove': 'Remove', 'request_to_connect': 'Request to Connect', 'connect_to': 'Connect to:', 'select_data_accessed': 'Select Data To Be Accessed:', 'determine_timeframe': 'Determine Timeframe:', 'connect': 'Connect', 'Hearing Data': 'Hearing Data', 'requests': 'Requests',
      // Doctor Analytics
      'analytics_overview': 'ANALYTICS OVERVIEW', 'trends': 'Trends', 'based_on_live_data': 'Based on live data from', 'connected_patients': 'connected patients.', 'recent_patient_alerts': 'RECENT PATIENT ALERTS', 'system_health_ok': 'All hospital systems are operational. Device sync is at 98% efficiency.', 'connected_users': 'Connected Users', 'need_attention': 'NEED\nATTENTION', 'clinic_preferences': 'CLINIC PREFERENCES', 'clinic_info': 'Clinic Information', 'verified': 'Verified', 'alerts_notifications': 'Alerts & Notifications', 'urgent_only': 'Urgent Only', 'patient_data_access': 'Patient Data Access', 'security': 'Security', 'generate_clinic_report': 'GENERATE CLINIC REPORT', 'users': 'Users.', 'search_patients_hint': 'Search patients by name or ID...', 'active_patients': 'ACTIVE PATIENTS', 'total': 'Total', 'no_patients_found': 'No patients found.', 'sort_patients': 'Sort Patients', 'device': 'Device',
      // Premium & Devices
      'premium_member' : 'HealthMax Premium Member', 'premium_desc': 'Enjoy an ad-free experience, personalized insights, and priority support with HealthMax Premium.', 'upgrade': 'Upgrade Now',
      'manage_devices': 'Manage Devices', 'no_devices_connected': 'No devices connected.', 'connect_new_device': 'Connect New Device', 'disconnect': 'Disconnect', 'target_name': 'Target Name',
      // Alerts & Actions
      'preparing_export': 'Preparing export...', 'logout_confirm': 'Are you sure you want to log out?',
      
    },
    'ms': {
      'home': 'Utama', 'history': 'Sejarah', 'calorie': 'Kalori', 'statistics': 'Statistik', 'target': 'Sasaran', 'edit': 'Sunting', 'close': 'Tutup', 'status': 'Status',
      'Day': 'Hari', 'Week': 'Minggu', 'Month': 'Bulan', 'Year': 'Tahun',
      'Heart Rate': 'Kadar Jantung', 'Steps': 'Langkah', 'Calories': 'Kalori', 'Blood Glucose': 'Glukosa Darah', 'Env. Noise': 'Bunyi Sekitar',
      'preferences': 'KEUTAMAAN', 'language': 'Bahasa', 'font_size': 'Saiz Tulisan', 'account_info': 'Maklumat Akaun', 'notifications': 'Pemberitahuan', 'manage_hp': 'Urus Penyedia Penjagaan Kesihatan', 'connected_devices': 'Peranti Disambungkan', 'health_goals': 'Matlamat Kesihatan', 'dark_mode': 'Mod Gelap', 'privacy': 'Privasi & Keselamatan', 'actions': 'TINDAKAN', 'verify_email': 'SAHKAN E-MEL', 'export_data': 'EKSPORT DATA KESIHATAN', 'log_out': 'LOG KELUAR', 'manage': 'Urus', 'on': 'Hidup', 'connected': 'Bersambung',
      'hi': 'Hai,', 'last_updated': 'Kemas Kini Terakhir :', 'live_syncing': 'Penyegerakan...', 'steps_label': 'Langkah:', 'quick_action': 'Tindakan Pantas', 'feedback': 'Maklum Balas', 'burned_calories': 'Kalori Dibakar', 'kcal_burned': 'kcal dibakar', 'cancel': 'Batal', 'reschedule': 'Jadual Semula', 'status_normal': 'Normal', 'status_quiet': 'Senyap',
      'calorie_intake': 'Pengambilan Kalori.', 'today': 'Hari Ini', 'eaten': 'Dimakan', 'burned': 'Dibakar', 'kcal_left': 'kcal baki.', 'intake_breakdown': 'Pecahan Pengambilan','calories' : 'Kalori', 'carbohydrates': 'Karbohidrat', 'protein': 'Protein', 'fats': 'Lemak', 'summary': 'Ringkasan', 'log_food': 'Log Makanan', 'remaining': 'baki', 'detailed_breakdown': 'Pecahan makronutrien terperinci untuk', 'daily_breakdown': 'Pecahan Harian', 'total_intake': 'Jumlah Pengambilan',
      'your_target': 'Sasaran Anda.', 'main_goal': 'MATLAMAT UTAMA', 'no_goal_yet': 'Belum Ada Matlamat', 'set_goal_desc': 'Tetapkan matlamat untuk membenarkan AI mengubahsuai pengalaman anda.', 'target_label': 'Sasaran:', 'your_score': 'Skor Anda :', 'daily_goals': 'MATLAMAT HARIAN', 'ranking': 'Kedudukan', 'set_new_target': 'Tetapkan Sasaran Baru',
      'live_record': 'REKOD LANGSUNG', 'latest_record': 'REKOD TERKINI', 'sync_cloud_data': 'Segerak Data Awan', 'syncing': 'Menyegerak...', 'data_breakdown': 'PECAHAN DATA', 'todays_record': 'Rekod Hari Ini', 'daily_avg': 'Purata Harian', 'compare_data': 'Bandingkan Data', 'request_feedback': 'Minta Maklum Balas', 'cloud_sync_complete': 'Segerak Awan Selesai!', 'failed_to_connect': 'Gagal menyambung.',
      'ai_assist': 'Bantuan AI', 'manual_write': 'Tulis Manual', 'upload_or_take': 'muat naik atau ambil gambar', 'retake_picture': 'Ambil semula gambar', 'describe_meal': 'atau terangkan hidangan anda', 'ai_estimation': 'Anggaran AI', 'ai_analysis_notes': 'Nota Analisis AI', 'meal_name': 'Nama Hidangan', 'enter_in_gram': 'Masukkan dalam gram', 'add_a_comment': 'tambah komen..', 'add_to_intake': 'Tambah ke Pengambilan',
      'providers': 'Penyedia.', 'search_hp': 'Cari Penyedia Penjagaan Kesihatan', 'no_connected_hp': 'Anda tiada penyedia penjagaan kesihatan yang disambungkan.', 'no_pending_requests': 'Anda tiada permintaan yang belum selesai.', 'contact': 'Hubungi', 'remove': 'Buang', 'request_to_connect': 'Minta untuk Menyambung', 'connect_to': 'Sambung ke:', 'select_data_accessed': 'Pilih Data Untuk Diakses:', 'determine_timeframe': 'Tentukan Tempoh Masa:', 'connect': 'Sambung', 'Hearing Data': 'Data Pendengaran', 'requests': 'Permintaan',
      'analytics_overview': 'TINJAUAN ANALITIK', 'trends': 'Trend', 'based_on_live_data': 'Berdasarkan data langsung daripada', 'connected_patients': 'pesakit yang bersambung.', 'recent_patient_alerts': 'AMARAN PESAKIT TERKINI', 'system_health_ok': 'Semua sistem hospital beroperasi. Penyegerakan peranti pada kecekapan 98%.', 'connected_users': 'Pengguna Bersambung', 'need_attention': 'PERLU\nPERHATIAN', 'clinic_preferences': 'KEUTAMAAN KLINIK', 'clinic_info': 'Maklumat Klinik', 'verified': 'Disahkan', 'alerts_notifications': 'Amaran & Pemberitahuan', 'urgent_only': 'Kecemasan Sahaja', 'patient_data_access': 'Akses Data Pesakit', 'security': 'Keselamatan', 'generate_clinic_report': 'JANA LAPORAN KLINIK', 'users': 'Pengguna.', 'search_patients_hint': 'Cari pesakit melalui nama atau ID...', 'active_patients': 'PESAKIT AKTIF', 'total': 'Jumlah', 'no_patients_found': 'Tiada pesakit ditemui.', 'sort_patients': 'Susun Pesakit', 'device': 'Peranti',
      'premium_member' : 'Ahli Premium HealthMax', 'premium_desc': 'Nikmati pengalaman tanpa iklan, wawasan yang dipersonalisasi, dan sokongan prioritas dengan HealthMax Premium.', 'upgrade': 'Tingkatkan Sekarang',
      'manage_devices': 'Urus Peranti', 'no_devices_connected': 'Tiada peranti disambungkan.', 'connect_new_device': 'Sambungkan Peranti Baru', 'disconnect': 'Putus Sambungan', 'target_name': 'Nama Sasaran',
      'preparing_export': 'Menyediakan eksport...', 'logout_confirm': 'Adakah anda pasti ingin log keluar?',
    },
    'zh': {
      'home': '首页', 'history': '历史', 'calorie': '卡路里', 'statistics': '统计', 'target': '目标', 'edit': '编辑', 'close': '关闭', 'status': '状态',
      'Day': '日', 'Week': '周', 'Month': '月', 'Year': '年',
      'Heart Rate': '心率', 'Steps': '步数', 'Calories': '卡路里', 'Blood Glucose': '血糖', 'Env. Noise': '环境噪音',
      'preferences': '偏好设置', 'language': '语言', 'font_size': '字体大小', 'account_info': '账户信息', 'notifications': '通知', 'manage_hp': '管理医疗保健提供者', 'connected_devices': '已连接的设备', 'health_goals': '健康目标', 'dark_mode': '深色模式', 'privacy': '隐私与安全', 'actions': '操作', 'verify_email': '验证电子邮件', 'export_data': '导出健康数据', 'log_out': '登出', 'manage': '管理', 'on': '开启', 'connected': '已连接',
      'hi': '你好，', 'last_updated': '最后更新：', 'live_syncing': '实时同步中...', 'steps_label': '步数：', 'quick_action': '快速操作', 'feedback': '反馈', 'burned_calories': '消耗的卡路里', 'kcal_burned': '今日消耗的千卡', 'cancel': '取消', 'reschedule': '重新安排', 'status_normal': '正常', 'status_quiet': '安静',
      'calorie_intake': '卡路里摄入。', 'today': '今天', 'eaten': '已吃', 'burned': '已燃烧', 'kcal_left': '剩余千卡。', 'intake_breakdown': '摄入细分', 'calories' : '卡路里', 'carbohydrates': '碳水化合物', 'protein': '蛋白质', 'fats': '脂肪', 'summary': '总结', 'log_food': '记录食物', 'remaining': '剩余', 'detailed_breakdown': '详细的宏量营养素细分为', 'daily_breakdown': '每日细分', 'total_intake': '总摄入量',
      'your_target': '您的目标。', 'main_goal': '主要目标', 'no_goal_yet': '暂无目标', 'set_goal_desc': '设定一个主要健康目标，让AI为您提供个性化体验。', 'target_label': '目标：', 'your_score': '您的得分：', 'daily_goals': '每日目标', 'ranking': '排名', 'set_new_target': '设定新目标',
      'live_record': '实时记录', 'latest_record': '最新记录', 'sync_cloud_data': '同步云数据', 'syncing': '同步中...', 'data_breakdown': '数据细分', 'todays_record': '今日记录', 'daily_avg': '日平均', 'compare_data': '比较数据', 'request_feedback': '请求反馈', 'cloud_sync_complete': '云同步完成！', 'failed_to_connect': '连接失败。',
      'ai_assist': 'AI 辅助', 'manual_write': '手动输入', 'upload_or_take': '上传或拍照', 'retake_picture': '重新拍照', 'describe_meal': '或在此描述您的膳食', 'ai_estimation': 'AI 估算', 'ai_analysis_notes': 'AI 分析说明', 'meal_name': '膳食名称', 'enter_in_gram': '以克为单位输入', 'add_a_comment': '添加评论...', 'add_to_intake': '添加到我的摄入量',
      'providers': '提供者。', 'search_hp': '搜索医疗保健提供者', 'no_connected_hp': '您没有连接的医疗保健提供者。', 'no_pending_requests': '您没有待处理的请求。', 'contact': '联系', 'remove': '移除', 'request_to_connect': '请求连接', 'connect_to': '连接到：', 'select_data_accessed': '选择要访问的数据：', 'determine_timeframe': '确定时间范围：', 'connect': '连接', 'Hearing Data': '听力数据', 'requests': '请求',
      'analytics_overview': '分析概览', 'trends': '趋势', 'based_on_live_data': '基于实时数据', 'connected_patients': '已连接的患者。', 'recent_patient_alerts': '最近患者警报', 'system_health_ok': '所有医院系统运行正常。设备同步效率为98%。', 'connected_users': '已连接用户', 'need_attention': '需要注意', 'clinic_preferences': '诊所偏好', 'clinic_info': '诊所信息', 'verified': '已验证', 'alerts_notifications': '警报和通知', 'urgent_only': '仅限紧急', 'patient_data_access': '患者数据访问', 'security': '安全', 'generate_clinic_report': '生成诊所报告', 'users': '用户。', 'search_patients_hint': '按姓名或ID搜索患者...', 'active_patients': '活跃患者', 'total': '总计', 'no_patients_found': '未找到患者。', 'sort_patients': '患者排序', 'device': '设备',
      'premium_member' : 'HealthMax 高级会员', 'premium_desc': '享受无广告体验、个性化见解和优先支持。', 'upgrade': '立即升级',
      'manage_devices': '管理设备', 'no_devices_connected': '未连接设备。', 'connect_new_device': '连接新设备', 'disconnect': '断开连接', 'target_name': '目标名称',
      'preparing_export': '准备导出...', 'logout_confirm': '您确定要登出吗？',
    },
    'ta': {
      'home': 'முகப்பு', 'history': 'வரலாறு', 'calorie': 'கலோரி', 'statistics': 'புள்ளிவிவரங்கள்', 'target': 'இலக்கு', 'edit': 'திருத்து', 'close': 'மூடு', 'status': 'நிலை',
      'Day': 'நாள்', 'Week': 'வாரம்', 'Month': 'மாதம்', 'Year': 'ஆண்டு',
      'Heart Rate': 'இதயத் துடிப்பு', 'Steps': 'படிகள்', 'Calories': 'கலோரிகள்', 'Blood Glucose': 'இரத்த சர்க்கரை', 'Env. Noise': 'சுற்றுச்சூழல் சத்தம்',
      'preferences': 'விருப்பங்கள்', 'language': 'மொழி', 'font_size': 'எழுத்துரு அளவு', 'account_info': 'கணக்கு தகவல்', 'notifications': 'அறிவிப்புகள்', 'manage_hp': 'சுகாதார வழங்குநர்களை நிர்வகி', 'connected_devices': 'இணைக்கப்பட்ட சாதனங்கள்', 'health_goals': 'சுகாதார இலக்குகள்', 'dark_mode': 'இருண்ட பயன்முறை', 'privacy': 'தனியுரிமை மற்றும் பாதுகாப்பு', 'actions': 'செயல்கள்', 'verify_email': 'மின்னஞ்சலைச் சரிபார்க்கவும்', 'export_data': 'சுகாதாரத் தரவை ஏற்றுமதி செய்', 'log_out': 'வெளியேறு', 'manage': 'நிர்வகி', 'on': 'ஆன்', 'connected': 'இணைக்கப்பட்டுள்ளது',
      'hi': 'வணக்கம்,', 'last_updated': 'கடைசியாக புதுப்பிக்கப்பட்டது :', 'live_syncing': 'நேரலை ஒத்திசைவு...', 'steps_label': 'படிகள்:', 'quick_action': 'விரைவான செயல்', 'feedback': 'பின்னூட்டம்', 'burned_calories': 'எரிக்கப்பட்ட கலோரிகள்', 'kcal_burned': 'இன்று எரிக்கப்பட்ட கிலோகலோரிகள்', 'cancel': 'ரத்துசெய்', 'reschedule': 'மாற்றி அமை', 'status_normal': 'வழக்கமான', 'status_quiet': 'அமைதியான',
      'calorie_intake': 'கலோரி உட்கொள்ளல்.', 'today': 'இன்று', 'eaten': 'உண்ணப்பட்டவை', 'burned': 'எரிக்கப்பட்டவை', 'kcal_left': 'மீதமுள்ள கிலோகலோரிகள்.', 'intake_breakdown': 'உட்கொள்ளல் முறிவு', 'calories' : 'கலோரிகள்', 'carbohydrates': 'கார்போஹைட்ரேட்டுகள்', 'protein': 'புரதம்', 'fats': 'கொழுப்புகள்', 'summary': 'சுருக்கம்', 'log_food': 'உணவை பதிவு செய்', 'remaining': 'மீதமுள்ளவை', 'detailed_breakdown': 'விரிவான மேக்ரோநியூட்ரியண்ட் முறிவு', 'daily_breakdown': 'தினசரி முறிவு', 'total_intake': 'மொத்த உட்கொள்ளல்',
      'your_target': 'உங்கள் இலக்கு.', 'main_goal': 'முக்கிய இலக்கு', 'no_goal_yet': 'இலக்கு இல்லை', 'set_goal_desc': 'AI உங்கள் அனுபவத்தை தனிப்பயனாக்க ஒரு முக்கிய சுகாதார இலக்கை அமைக்கவும்.', 'target_label': 'இலக்கு:', 'your_score': 'உங்கள் மதிப்பெண் :', 'daily_goals': 'தினசரி இலக்குகள்', 'ranking': 'தரவரிசை', 'set_new_target': 'புதிய இலக்கை அமை',
      'live_record': 'நேரலை பதிவு', 'latest_record': 'சமீபத்திய பதிவு', 'sync_cloud_data': 'கிளவுட் தரவை ஒத்திசை', 'syncing': 'ஒத்திசைக்கிறது...', 'data_breakdown': 'தரவு முறிவு', 'todays_record': 'இன்றைய பதிவு', 'daily_avg': 'தினசரி சராசரி', 'compare_data': 'தரவை ஒப்பிடுக', 'request_feedback': 'பின்னூட்டத்தைக் கோரு', 'cloud_sync_complete': 'கிளவுட் ஒத்திசைவு முடிந்தது!', 'failed_to_connect': 'இணைக்க முடியவில்லை.',
      'ai_assist': 'AI உதவி', 'manual_write': 'கைமுறையாக எழுது', 'upload_or_take': 'பதிவேற்று அல்லது புகைப்படம் எடு', 'retake_picture': 'மீண்டும் புகைப்படம் எடு', 'describe_meal': 'அல்லது உங்கள் உணவை இங்கே விவரிக்கவும்', 'ai_estimation': 'AI மதிப்பீடு', 'ai_analysis_notes': 'AI பகுப்பாய்வு குறிப்புகள்', 'meal_name': 'உணவின் பெயர்', 'enter_in_gram': 'கிராமில் உள்ளிடவும்', 'add_a_comment': 'ஒரு கருத்தைச் சேர்க்கவும்..', 'add_to_intake': 'எனது உட்கொள்ளலில் சேர்',
      'providers': 'வழங்குநர்கள்.', 'search_hp': 'சுகாதார வழங்குநரைத் தேடுக', 'no_connected_hp': 'உங்களுக்கு இணைக்கப்பட்ட சுகாதார வழங்குநர்கள் இல்லை.', 'no_pending_requests': 'நிலுவையில் உள்ள கோரிக்கைகள் எதுவும் இல்லை.', 'contact': 'தொடர்பு கொள்', 'remove': 'அகற்று', 'request_to_connect': 'இணைக்க கோரிக்கை', 'connect_to': 'இதற்கு இணைக்க:', 'select_data_accessed': 'அணுக வேண்டிய தரவைத் தேர்ந்தெடுக்கவும்:', 'determine_timeframe': 'காலக்கெடுவை தீர்மானிக்கவும்:', 'connect': 'இணை', 'Hearing Data': 'கேட்டல் தரவு', 'requests': 'கோரிக்கைகள்',
      'analytics_overview': 'பகுப்பாய்வு கண்ணோட்டம்', 'trends': 'போக்குகள்', 'based_on_live_data': 'நேரலைத் தரவின் அடிப்படையில்', 'connected_patients': 'இணைக்கப்பட்ட நோயாளிகள்.', 'recent_patient_alerts': 'சமீபத்திய நோயாளி எச்சரிக்கைகள்', 'system_health_ok': 'அனைத்து மருத்துவமனை அமைப்புகளும் செயல்படுகின்றன. சாதன ஒத்திசைவு 98% செயல்திறனில் உள்ளது.', 'connected_users': 'இணைக்கப்பட்ட பயனர்கள்', 'need_attention': 'கவனம் தேவை', 'clinic_preferences': 'கிளினிக் விருப்பங்கள்', 'clinic_info': 'கிளினிக் தகவல்', 'verified': 'சரிபார்க்கப்பட்டது', 'alerts_notifications': 'எச்சரிக்கைகள் மற்றும் அறிவிப்புகள்', 'urgent_only': 'அவசரம் மட்டுமே', 'patient_data_access': 'நோயாளி தரவு அணுகல்', 'security': 'பாதுகாப்பு', 'generate_clinic_report': 'கிளினிக் அறிக்கையை உருவாக்கு', 'users': 'பயனர்கள்.', 'search_patients_hint': 'பெயர் அல்லது ஐடி மூலம் நோயாளிகளைத் தேடுக...', 'active_patients': 'செயலில் உள்ள நோயாளிகள்', 'total': 'மொத்தம்', 'no_patients_found': 'நோயாளிகள் காணப்படவில்லை.', 'sort_patients': 'நோயாளிகளை வரிசைப்படுத்து', 'device': 'சாதனம்',
      'premium_member' : 'HealthMax பிரீமியம் உறுப்பினர்', 'premium_desc': 'HealthMax பிரீமியம் மூலம் விளம்பரமில்லா அனுபவம், தனிப்பயனாக்கப்பட்ட நுண்ணறிவுகள் மற்றும் முன்னுரிமை ஆதரவை அனுபவிக்கவும்.', 'upgrade': 'இப்போதே மேம்படுத்து',
      'manage_devices': 'சாதனங்களை நிர்வகி', 'no_devices_connected': 'சாதனங்கள் எதுவும் இணைக்கப்படவில்லை.', 'connect_new_device': 'புதிய சாதனத்தை இணை', 'disconnect': 'துண்டி', 'target_name': 'இலக்கின் பெயர்',
      'preparing_export': 'ஏற்றுமதி தயாராகிறது...', 'logout_confirm': 'நீங்கள் நிச்சயமாக வெளியேற வேண்டுமா?',
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

  Future<void> resetToDefault() async {
    // Reset internal variables to default
    fontScale = 1.0; 
    themeMode = ThemeMode.light;
    currentLanguage = 'en'; 
    
    // Notify the UI to shrink the text back down
    notifyListeners(); 

    // Wipe the saved preferences from device storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fontScale'); 
    await prefs.remove('isDarkMode');
    await prefs.remove('currentLanguage'); 
  }
}
