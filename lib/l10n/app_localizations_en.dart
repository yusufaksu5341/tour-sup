// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TourSup';

  @override
  String get navScan => 'Scan';

  @override
  String get navTaxi => 'Taxi';

  @override
  String get navEmergency => 'SOS';

  @override
  String get navProfile => 'Profile';

  @override
  String get scanTitle => 'Visual Guide';

  @override
  String get scanButton => 'Identify Building';

  @override
  String get scanInitializing => 'Starting camera...';

  @override
  String get scanNotFound =>
      'Building not recognized. Point the camera more directly at it.';

  @override
  String scanConfidence(String score) {
    return 'Confidence: %$score';
  }

  @override
  String get landmarkAbout => 'About';

  @override
  String get landmarkLocation => 'Location';

  @override
  String get landmarkSeeDetails => 'See Details';

  @override
  String get landmarkUnknownDesc =>
      'Detailed information about this landmark will be added soon.';

  @override
  String get taxiTitle => 'Taxi Tracker';

  @override
  String taxiTariffInfo(String open, String km, String min) {
    return 'Istanbul tariff: Opening ₺$open  · per km ₺$km  · per min ₺$min';
  }

  @override
  String get taxiStart => 'Start Trip';

  @override
  String get taxiStop => 'Stop Trip';

  @override
  String get taxiResume => 'Resume';

  @override
  String get taxiNew => 'New Trip';

  @override
  String get taxiDesc =>
      'GPS-based distance tracking with estimated fare calculated using the current Istanbul tariff.';

  @override
  String get taxiPrompt => 'Start your taxi trip';

  @override
  String get taxiTracking => 'Tracking active';

  @override
  String get taxiPaused => 'Tracking paused';

  @override
  String get taxiDistance => 'Distance';

  @override
  String get taxiDuration => 'Duration';

  @override
  String get taxiStart2 => 'Started';

  @override
  String get taxiAvgSpeed => 'Avg. Speed';

  @override
  String get taxiFareLabel => 'Estimated Fare';

  @override
  String get taxiFareNote => 'Calculated using Istanbul tariff';

  @override
  String get taxiDeviationTitle => 'Route Alert';

  @override
  String get taxiDeviationBody =>
      'The taxi has moved further than expected from your starting point. Consider confirming the route with the driver.';

  @override
  String get taxiPermissionDenied =>
      'Location permission denied. Please enable it in settings.';

  @override
  String get emergencyTitle => 'Emergency';

  @override
  String get emergencySubtitle =>
      'Press SOS — your GPS coordinates will be shared instantly.';

  @override
  String get emergencyPolice => 'Police';

  @override
  String get emergencyAmbulance => 'Ambulance';

  @override
  String get emergencyTourism => 'Tourism';

  @override
  String get emergencyFireDept => 'Fire Dept.';

  @override
  String get emergencyGendarmerie => 'Gendarmerie';

  @override
  String get emergencyCoastGuard => 'Coast Guard';

  @override
  String get emergencyTourismLine => 'Tourism Helpline';

  @override
  String get emergencyNumbers => 'Emergency Numbers';

  @override
  String get emergencyLastSent => 'Last location shared';

  @override
  String get emergencyShareTitle => 'How to share your location?';

  @override
  String get emergencyShareSms => 'Send via SMS';

  @override
  String get emergencyShareApp => 'Share (WhatsApp, etc.)';

  @override
  String get emergencyShareMaps => 'Open in Google Maps';

  @override
  String emergencyShareText(String coords, String lat, String lng) {
    return 'EMERGENCY!\nLocation: $coords\nMap: https://maps.google.com/?q=$lat,$lng';
  }

  @override
  String emergencySmsText(String coords, String lat, String lng) {
    return 'EMERGENCY: My location: $coords — Google Maps: https://maps.google.com/?q=$lat,$lng';
  }

  @override
  String get emergencyGpsError =>
      'Could not get location. Check your GPS signal.';

  @override
  String get emergencyPermissionDenied =>
      'Location permission denied. Please enable it in settings.';

  @override
  String emergencyTimeLabel(String time) {
    return 'At $time';
  }

  @override
  String get understood => 'Got it';

  @override
  String get minuteShort => 'min';

  @override
  String get kmShort => 'km';

  @override
  String get kmPerHour => 'km/h';
}
