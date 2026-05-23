import 'dart:io';

class ApiEndpoints {
  static String get baseUrl {
    // Return to the physical device Wi-Fi IP address
    return 'http://192.168.0.73:5000/api';
  }
    
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // Check-ins
  // static const String checkins = '/checkins';
  
  // Habits
  static const String habits = '/habits';
  static String toggleHabit(String id) => '/habits/$id/complete';
  
  // Family / GharLog
  static const String members = '/gharlog/members';
  static String doctorVisits(String memberId) => '/visits/$memberId';
  static const String addVisit = '/visits';
  static String symptoms(String memberId) => '/symptoms/$memberId';
  static const String addSymptom = '/symptoms';
  static const String addMedicineLog = '/medicine/log';

  // Daily Log / Check-in
  static const String checkins = '/dailylog';
}
