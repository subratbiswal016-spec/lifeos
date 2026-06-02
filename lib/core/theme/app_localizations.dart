import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_provider.dart';

class AppLocalizations {
  final AppLanguage language;
  
  AppLocalizations(this.language);

  static final Map<String, Map<AppLanguage, String>> _translations = {
    // Navigation
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.hindi: 'होम',
      AppLanguage.odia: 'ହୋମ',
      AppLanguage.tamil: 'முகப்பு',
    },
    'padho_ai': {
      AppLanguage.english: 'Padho AI',
      AppLanguage.hindi: 'पढ़ो AI',
      AppLanguage.odia: 'ପଢ଼ୋ AI',
      AppLanguage.tamil: 'பதோ AI',
    },
    'ghar_log': {
      AppLanguage.english: 'My Family',
      AppLanguage.hindi: 'घर लॉग',
      AppLanguage.odia: 'ଘର ଲଗ୍',
      AppLanguage.tamil: 'கார் லாக்',
    },
    'my_life': {
      AppLanguage.english: 'My Life',
      AppLanguage.hindi: 'मेरा जीवन',
      AppLanguage.odia: 'ମୋ ଜୀବନ',
      AppLanguage.tamil: 'என் வாழ்க்கை',
    },
    
    // Home Screen
    'today': {
      AppLanguage.english: 'Today',
      AppLanguage.hindi: 'आज',
      AppLanguage.odia: 'ଆଜି',
      AppLanguage.tamil: 'இன்று',
    },
    'upcoming': {
      AppLanguage.english: 'Upcoming',
      AppLanguage.hindi: 'आगामी',
      AppLanguage.odia: 'ଆଗାମୀ',
      AppLanguage.tamil: 'வரவிருக்கும்',
    },
    'quick_access': {
      AppLanguage.english: 'Quick Access',
      AppLanguage.hindi: 'त्वरित पहुंच',
      AppLanguage.odia: 'ଶୀଘ୍ର ଆକ୍ସେସ୍',
      AppLanguage.tamil: 'விரைவான அணுகல்',
    },
    'ai_daily_tip': {
      AppLanguage.english: 'AI Daily Tip',
      AppLanguage.hindi: 'AI दैनिक टिप',
      AppLanguage.odia: 'AI ଦୈନିକ ଟିପ୍',
      AppLanguage.tamil: 'AI தினசரி குறிப்பு',
    },
    'daily_checkin': {
      AppLanguage.english: 'Daily Check-in',
      AppLanguage.hindi: 'दैनिक चेक-इन',
      AppLanguage.odia: 'ଦୈନିକ ଚେକ୍-ଇନ୍',
      AppLanguage.tamil: 'தினசரி செக்-இன்',
    },
    'log_mood': {
      AppLanguage.english: 'Log your mood, sleep & energy',
      AppLanguage.hindi: 'अपना मूड, नींद और ऊर्जा दर्ज करें',
      AppLanguage.odia: 'ଆପଣଙ୍କ ମୂଡ୍, ନିଦ୍ରା ଓ ଶକ୍ତି ଲଗ୍ କରନ୍ତୁ',
      AppLanguage.tamil: 'உங்கள் மனநிலை, தூக்கம் & ஆற்றலை பதிவு செய்யவும்',
    },
    'mark_as_taken': {
      AppLanguage.english: 'Mark as Taken',
      AppLanguage.hindi: 'लिया गया',
      AppLanguage.odia: 'ନିଆଯାଇଛି',
      AppLanguage.tamil: 'எடுக்கப்பட்டது',
    },
    'delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.hindi: 'हटाएं',
      AppLanguage.odia: 'ଡିଲିଟ୍',
      AppLanguage.tamil: 'நீக்கு',
    },
    'ai_coach': {
      AppLanguage.english: 'AI Coach',
      AppLanguage.hindi: 'AI कोच',
      AppLanguage.odia: 'AI କୋଚ୍',
      AppLanguage.tamil: 'AI கோச்',
    },
    
    // Profile & Settings
    'profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.hindi: 'प्रोफ़ाइल',
      AppLanguage.odia: 'ପ୍ରୋଫାଇଲ୍',
      AppLanguage.tamil: 'சுயவிவரம்',
    },
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.hindi: 'सेटिंग्स',
      AppLanguage.odia: 'ସେଟିଂସ',
      AppLanguage.tamil: 'அமைப்புகள்',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.hindi: 'भाषा',
      AppLanguage.odia: 'ଭାଷା',
      AppLanguage.tamil: 'மொழி',
    },
    'theme': {
      AppLanguage.english: 'Theme',
      AppLanguage.hindi: 'थीम',
      AppLanguage.odia: 'ଥିମ୍',
      AppLanguage.tamil: 'தீம்',
    },
    
    // Udhar Screen
    'udhar_manager': {
      AppLanguage.english: 'Money Manager',
      AppLanguage.hindi: 'मनी मैनेजर',
      AppLanguage.odia: 'ଟଙ୍କା ମ୍ୟାନେଜର',
      AppLanguage.tamil: 'பண மேலாளர்',
    },
    'gave': {
      AppLanguage.english: 'Gave',
      AppLanguage.hindi: 'दिया',
      AppLanguage.odia: 'ଦେଲି',
      AppLanguage.tamil: 'கொடுத்தேன்',
    },
    'took': {
      AppLanguage.english: 'Took',
      AppLanguage.hindi: 'लिया',
      AppLanguage.odia: 'ନେଲି',
      AppLanguage.tamil: 'எடுத்தேன்',
    },
    'net_balance': {
      AppLanguage.english: 'Net Balance',
      AppLanguage.hindi: 'कुल शेष',
      AppLanguage.odia: 'ନେଟ୍ ବାଲାନ୍ସ',
      AppLanguage.tamil: 'நிகர இருப்பு',
    },
    // Family Relations
    'rel_self': {
      AppLanguage.english: 'Self',
      AppLanguage.hindi: 'स्वयं',
      AppLanguage.odia: 'ନିଜେ',
      AppLanguage.tamil: 'சுய',
    },
    'rel_papa': {
      AppLanguage.english: 'Father',
      AppLanguage.hindi: 'पापा',
      AppLanguage.odia: 'ବାପା',
      AppLanguage.tamil: 'அப்பா',
    },
    'rel_maa': {
      AppLanguage.english: 'Mother',
      AppLanguage.hindi: 'माँ',
      AppLanguage.odia: 'ମା',
      AppLanguage.tamil: 'அம்மா',
    },
    'rel_dadi': {
      AppLanguage.english: 'Grand Mother',
      AppLanguage.hindi: 'दादी',
      AppLanguage.odia: 'ଜେଜେମା',
      AppLanguage.tamil: 'பாட்டி',
    },
    'rel_nana': {
      AppLanguage.english: 'Grand Father',
      AppLanguage.hindi: 'नाना',
      AppLanguage.odia: 'ଅଜା',
      AppLanguage.tamil: 'தாத்தா',
    },
    'rel_child': {
      AppLanguage.english: 'Child',
      AppLanguage.hindi: 'बच्चा',
      AppLanguage.odia: 'ପିଲା',
      AppLanguage.tamil: 'குழந்தை',
    },
    'rel_spouse': {
      AppLanguage.english: 'Spouse',
      AppLanguage.hindi: 'पति/पत्नी',
      AppLanguage.odia: 'ସ୍ୱାମୀ/ସ୍ତ୍ରୀ',
      AppLanguage.tamil: 'கணவன்/மனைவி',
    },
    'rel_other': {
      AppLanguage.english: 'Other',
      AppLanguage.hindi: 'अन्य',
      AppLanguage.odia: 'ଅନ୍ୟ',
      AppLanguage.tamil: 'மற்றவை',
    },
  };

  String translate(String key) {
    if (_translations.containsKey(key)) {
      return _translations[key]![language] ?? _translations[key]![AppLanguage.english] ?? key;
    }
    return key;
  }
}

final localizationsProvider = Provider<AppLocalizations>((ref) {
  final language = ref.watch(languageProvider);
  return AppLocalizations(language);
});
