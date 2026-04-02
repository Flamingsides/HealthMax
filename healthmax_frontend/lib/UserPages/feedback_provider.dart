import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackRecord {
  final String hospitalName; final String date; final String time;
  final String message; final String feedbackType; final Color typeColor;
  FeedbackRecord(this.hospitalName, this.date, this.time, this.message, this.feedbackType, this.typeColor);
}

class FeedbackProvider extends ChangeNotifier {
  List<FeedbackRecord> feedbackHistory = [];

  Future<void> fetchFeedback() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase.from('user_feedback').select().eq('user_id', user.id).order('created_at', ascending: false);
      
      feedbackHistory = data.map((row) {
        DateTime dt = DateTime.parse(row['created_at']);
        String formattedDate = "${dt.day} ${_getMonth(dt.month)} ${dt.year}";
        String formattedTime = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'pm' : 'am'}";
        
        Color parseColor(String colorString) {
           if (colorString == 'red') return Colors.redAccent;
           if (colorString == 'orange') return Colors.orange;
           if (colorString == 'blue') return Colors.blueAccent;
           return Colors.green;
        }

        return FeedbackRecord(row['hospital_name'], formattedDate, formattedTime, row['message'], row['feedback_type'], parseColor(row['type_color'] ?? 'blue'));
      }).toList();
      notifyListeners();
    } catch (e) { print("Error fetching feedback: $e"); }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}