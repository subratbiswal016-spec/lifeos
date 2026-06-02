import 'dart:io';

class ApiEndpoints {
  // static String get baseUrl {
  //   // For physical Android device: use your PC's WiFi IP
  //   // For Android emulator: use 10.0.2.2
  //   // For iOS Simulator / Web / Desktop: use localhost
  //   try {
  //     if (Platform.isAndroid) {
  //       return 'http://192.168.0.73:5000/api'; // Your PC's WiFi IP
  //     }
  //   } catch (_) {
  //     // Fallback for Web
  //   }
  //   return 'http://localhost:3000/api'; // iOS Simulator / Web / Desktop
  // }
  // Use the live Render URL
  static const String baseUrl = 'https://lifeos-backend-m5gl.onrender.com/api';
    
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // Dashboard & Profile
  static const String dashboard = '/user/dashboard';
  static const String profile = '/user/profile';
  
  // Check-ins
  static const String checkins = '/dailylog';
  static const String dailyLog = '/dailylog';
  
  // Habits
  static const String habits = '/habits';
  static String toggleHabit(String id) => '/habits/$id/complete';
  
  // Family / GharLog
  static const String gharlogBase = '/gharlog';
  static const String members = '/gharlog/members';
  static String doctorVisits(String memberId) => '/visits/$memberId';
  static const String addVisit = '/visits';
  static String symptoms(String memberId) => '/symptoms/$memberId';
  static const String addSymptom = '/symptoms';
  
  // Medicine
  static String medicines(String memberId) => '/medicine/$memberId';
  static const String addMedicine = '/medicine';
  static String toggleMedicine(String id) => '/medicine/$id/log';
  static const String medicinesDueToday = '/medicine/due-today';
  
  // PadhoAI
  static const String study = '/study';
  static const String subjects = '/subjects';

  // AI Coach
  static const String ai = '/ai';
  static const String aiChat = '/ai/chat';

  // Udhar
  static const String udhar = '/udhar';
}
