import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'TourSup'**
  String get appTitle;

  /// No description provided for @navScan.
  ///
  /// In tr, this message translates to:
  /// **'Tara'**
  String get navScan;

  /// No description provided for @navTaxi.
  ///
  /// In tr, this message translates to:
  /// **'Taksi'**
  String get navTaxi;

  /// No description provided for @navEmergency.
  ///
  /// In tr, this message translates to:
  /// **'Acil'**
  String get navEmergency;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @scanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Rehberlik'**
  String get scanTitle;

  /// No description provided for @scanButton.
  ///
  /// In tr, this message translates to:
  /// **'Yapıyı Tanı'**
  String get scanButton;

  /// No description provided for @scanInitializing.
  ///
  /// In tr, this message translates to:
  /// **'Kamera başlatılıyor...'**
  String get scanInitializing;

  /// No description provided for @scanNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Yapı tanınamadı. Kamerayı yapıya daha iyi odaklayın.'**
  String get scanNotFound;

  /// No description provided for @scanConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Güven skoru: %{score}'**
  String scanConfidence(String score);

  /// No description provided for @landmarkAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get landmarkAbout;

  /// No description provided for @landmarkLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get landmarkLocation;

  /// No description provided for @landmarkSeeDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detayları Gör'**
  String get landmarkSeeDetails;

  /// No description provided for @landmarkUnknownDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu yapı hakkında detaylı bilgi yakında eklenecektir.'**
  String get landmarkUnknownDesc;

  /// No description provided for @taxiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Taksi Takip'**
  String get taxiTitle;

  /// No description provided for @taxiTariffInfo.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul tarifesi: Açılış ₺{open}  · km başı ₺{km}  · dk başı ₺{min}'**
  String taxiTariffInfo(String open, String km, String min);

  /// No description provided for @taxiStart.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğu Başlat'**
  String get taxiStart;

  /// No description provided for @taxiStop.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğu Durdur'**
  String get taxiStop;

  /// No description provided for @taxiResume.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get taxiResume;

  /// No description provided for @taxiNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Yolculuk'**
  String get taxiNew;

  /// No description provided for @taxiDesc.
  ///
  /// In tr, this message translates to:
  /// **'GPS ile mesafe takibi yapılır ve güncel İstanbul tarifesine göre tahmini ücret hesaplanır.'**
  String get taxiDesc;

  /// No description provided for @taxiPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Taksi yolculuğunuzu başlatın'**
  String get taxiPrompt;

  /// No description provided for @taxiTracking.
  ///
  /// In tr, this message translates to:
  /// **'Takip aktif'**
  String get taxiTracking;

  /// No description provided for @taxiPaused.
  ///
  /// In tr, this message translates to:
  /// **'Takip duraklatıldı'**
  String get taxiPaused;

  /// No description provided for @taxiDistance.
  ///
  /// In tr, this message translates to:
  /// **'Mesafe'**
  String get taxiDistance;

  /// No description provided for @taxiDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get taxiDuration;

  /// No description provided for @taxiStart2.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get taxiStart2;

  /// No description provided for @taxiAvgSpeed.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Hız'**
  String get taxiAvgSpeed;

  /// No description provided for @taxiFareLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini Ücret'**
  String get taxiFareLabel;

  /// No description provided for @taxiFareNote.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul tarifesine göre hesaplanmıştır'**
  String get taxiFareNote;

  /// No description provided for @taxiDeviationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güzergah Uyarısı'**
  String get taxiDeviationTitle;

  /// No description provided for @taxiDeviationBody.
  ///
  /// In tr, this message translates to:
  /// **'Taksi başlangıç noktanızdan beklenenden fazla uzaklaştı. Güzergahı şoföre teyit ettirmeniz önerilir.'**
  String get taxiDeviationBody;

  /// No description provided for @taxiPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi. Lütfen ayarlardan izin verin.'**
  String get taxiPermissionDenied;

  /// No description provided for @emergencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil Durum'**
  String get emergencyTitle;

  /// No description provided for @emergencySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'SOS butonuna basın — GPS koordinatlarınız anında paylaşılır.'**
  String get emergencySubtitle;

  /// No description provided for @emergencyPolice.
  ///
  /// In tr, this message translates to:
  /// **'Polis'**
  String get emergencyPolice;

  /// No description provided for @emergencyAmbulance.
  ///
  /// In tr, this message translates to:
  /// **'Ambulans'**
  String get emergencyAmbulance;

  /// No description provided for @emergencyTourism.
  ///
  /// In tr, this message translates to:
  /// **'Turizm'**
  String get emergencyTourism;

  /// No description provided for @emergencyFireDept.
  ///
  /// In tr, this message translates to:
  /// **'İtfaiye'**
  String get emergencyFireDept;

  /// No description provided for @emergencyGendarmerie.
  ///
  /// In tr, this message translates to:
  /// **'Jandarma'**
  String get emergencyGendarmerie;

  /// No description provided for @emergencyCoastGuard.
  ///
  /// In tr, this message translates to:
  /// **'Sahil Güvenlik'**
  String get emergencyCoastGuard;

  /// No description provided for @emergencyTourismLine.
  ///
  /// In tr, this message translates to:
  /// **'ALO Turizm Danışma'**
  String get emergencyTourismLine;

  /// No description provided for @emergencyNumbers.
  ///
  /// In tr, this message translates to:
  /// **'Acil Numaralar'**
  String get emergencyNumbers;

  /// No description provided for @emergencyLastSent.
  ///
  /// In tr, this message translates to:
  /// **'Son konum paylaşımı'**
  String get emergencyLastSent;

  /// No description provided for @emergencyShareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum nasıl paylaşılsın?'**
  String get emergencyShareTitle;

  /// No description provided for @emergencyShareSms.
  ///
  /// In tr, this message translates to:
  /// **'SMS ile Gönder'**
  String get emergencyShareSms;

  /// No description provided for @emergencyShareApp.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş (WhatsApp, vb.)'**
  String get emergencyShareApp;

  /// No description provided for @emergencyShareMaps.
  ///
  /// In tr, this message translates to:
  /// **'Google Maps\'te Aç'**
  String get emergencyShareMaps;

  /// No description provided for @emergencyShareText.
  ///
  /// In tr, this message translates to:
  /// **'ACİL YARDIM GEREKİYOR!\nKonum: {coords}\nHarita: https://maps.google.com/?q={lat},{lng}'**
  String emergencyShareText(String coords, String lat, String lng);

  /// No description provided for @emergencySmsText.
  ///
  /// In tr, this message translates to:
  /// **'ACİL YARDIM: Konumum: {coords} — Google Maps: https://maps.google.com/?q={lat},{lng}'**
  String emergencySmsText(String coords, String lat, String lng);

  /// No description provided for @emergencyGpsError.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı. GPS sinyalinizi kontrol edin.'**
  String get emergencyGpsError;

  /// No description provided for @emergencyPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi. Lütfen ayarlardan izin verin.'**
  String get emergencyPermissionDenied;

  /// No description provided for @emergencyTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Saat {time}'**
  String emergencyTimeLabel(String time);

  /// No description provided for @understood.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get understood;

  /// No description provided for @minuteShort.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minuteShort;

  /// No description provided for @kmShort.
  ///
  /// In tr, this message translates to:
  /// **'km'**
  String get kmShort;

  /// No description provided for @kmPerHour.
  ///
  /// In tr, this message translates to:
  /// **'km/s'**
  String get kmPerHour;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
