// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'TourSup';

  @override
  String get navScan => 'Tara';

  @override
  String get navTaxi => 'Taksi';

  @override
  String get navEmergency => 'Acil';

  @override
  String get navProfile => 'Profil';

  @override
  String get scanTitle => 'Görsel Rehberlik';

  @override
  String get scanButton => 'Yapıyı Tanı';

  @override
  String get scanInitializing => 'Kamera başlatılıyor...';

  @override
  String get scanNotFound =>
      'Yapı tanınamadı. Kamerayı yapıya daha iyi odaklayın.';

  @override
  String scanConfidence(String score) {
    return 'Güven skoru: %$score';
  }

  @override
  String get landmarkAbout => 'Hakkında';

  @override
  String get landmarkLocation => 'Konum';

  @override
  String get landmarkSeeDetails => 'Detayları Gör';

  @override
  String get landmarkUnknownDesc =>
      'Bu yapı hakkında detaylı bilgi yakında eklenecektir.';

  @override
  String get taxiTitle => 'Taksi Takip';

  @override
  String taxiTariffInfo(String open, String km, String min) {
    return 'İstanbul tarifesi: Açılış ₺$open  · km başı ₺$km  · dk başı ₺$min';
  }

  @override
  String get taxiStart => 'Yolculuğu Başlat';

  @override
  String get taxiStop => 'Yolculuğu Durdur';

  @override
  String get taxiResume => 'Devam Et';

  @override
  String get taxiNew => 'Yeni Yolculuk';

  @override
  String get taxiDesc =>
      'GPS ile mesafe takibi yapılır ve güncel İstanbul tarifesine göre tahmini ücret hesaplanır.';

  @override
  String get taxiPrompt => 'Taksi yolculuğunuzu başlatın';

  @override
  String get taxiTracking => 'Takip aktif';

  @override
  String get taxiPaused => 'Takip duraklatıldı';

  @override
  String get taxiDistance => 'Mesafe';

  @override
  String get taxiDuration => 'Süre';

  @override
  String get taxiStart2 => 'Başlangıç';

  @override
  String get taxiAvgSpeed => 'Ortalama Hız';

  @override
  String get taxiFareLabel => 'Tahmini Ücret';

  @override
  String get taxiFareNote => 'İstanbul tarifesine göre hesaplanmıştır';

  @override
  String get taxiDeviationTitle => 'Güzergah Uyarısı';

  @override
  String get taxiDeviationBody =>
      'Taksi başlangıç noktanızdan beklenenden fazla uzaklaştı. Güzergahı şoföre teyit ettirmeniz önerilir.';

  @override
  String get taxiPermissionDenied =>
      'Konum izni verilmedi. Lütfen ayarlardan izin verin.';

  @override
  String get emergencyTitle => 'Acil Durum';

  @override
  String get emergencySubtitle =>
      'SOS butonuna basın — GPS koordinatlarınız anında paylaşılır.';

  @override
  String get emergencyPolice => 'Polis';

  @override
  String get emergencyAmbulance => 'Ambulans';

  @override
  String get emergencyTourism => 'Turizm';

  @override
  String get emergencyFireDept => 'İtfaiye';

  @override
  String get emergencyGendarmerie => 'Jandarma';

  @override
  String get emergencyCoastGuard => 'Sahil Güvenlik';

  @override
  String get emergencyTourismLine => 'ALO Turizm Danışma';

  @override
  String get emergencyNumbers => 'Acil Numaralar';

  @override
  String get emergencyLastSent => 'Son konum paylaşımı';

  @override
  String get emergencyShareTitle => 'Konum nasıl paylaşılsın?';

  @override
  String get emergencyShareSms => 'SMS ile Gönder';

  @override
  String get emergencyShareApp => 'Paylaş (WhatsApp, vb.)';

  @override
  String get emergencyShareMaps => 'Google Maps\'te Aç';

  @override
  String emergencyShareText(String coords, String lat, String lng) {
    return 'ACİL YARDIM GEREKİYOR!\nKonum: $coords\nHarita: https://maps.google.com/?q=$lat,$lng';
  }

  @override
  String emergencySmsText(String coords, String lat, String lng) {
    return 'ACİL YARDIM: Konumum: $coords — Google Maps: https://maps.google.com/?q=$lat,$lng';
  }

  @override
  String get emergencyGpsError =>
      'Konum alınamadı. GPS sinyalinizi kontrol edin.';

  @override
  String get emergencyPermissionDenied =>
      'Konum izni verilmedi. Lütfen ayarlardan izin verin.';

  @override
  String emergencyTimeLabel(String time) {
    return 'Saat $time';
  }

  @override
  String get understood => 'Anladım';

  @override
  String get minuteShort => 'dk';

  @override
  String get kmShort => 'km';

  @override
  String get kmPerHour => 'km/s';
}
