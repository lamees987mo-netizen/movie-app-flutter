// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق الأفلام';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSearch => 'البحث';

  @override
  String get navWatchlist => 'قائمة المشاهدة';

  @override
  String get navAccount => 'حسابي';

  @override
  String get moviesTrending => 'الأكثر رواجًا';

  @override
  String get moviesTopRated => 'الأعلى تقييمًا';

  @override
  String get moviesUpcoming => 'قريبًا';

  @override
  String get moviesNowPlaying => 'يُعرض الآن';

  @override
  String get moviesSeeAll => 'عرض الكل';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonErrorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get commonErrorNetwork =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get commonErrorServer => 'الخادم يواجه مشكلة. حاول لاحقًا.';

  @override
  String get commonNotFound => 'لم نعثر على ما تبحث عنه.';

  @override
  String get commonCacheError => 'تعذّرت قراءة البيانات المحفوظة على الجهاز.';

  @override
  String get commonOfflineBanner => 'أنت غير متصل. يتم عرض المحتوى المحفوظ.';

  @override
  String get commonEmpty => 'لا يوجد شيء هنا بعد.';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonShowMore => 'عرض المزيد';

  @override
  String get commonShowLess => 'عرض أقل';

  @override
  String get detailsOverview => 'القصة';

  @override
  String get detailsCast => 'طاقم التمثيل';

  @override
  String get detailsPlayTrailer => 'تشغيل الإعلان';

  @override
  String detailsRuntimeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes دقيقة',
      few: '$minutes دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get detailsReleaseDate => 'تاريخ الإصدار';

  @override
  String get detailsNoOverview => 'لا يوجد وصف متاح.';

  @override
  String get detailsAddToWatchlist => 'أضف إلى قائمة المشاهدة';

  @override
  String get detailsRemoveFromWatchlist => 'إزالة من قائمة المشاهدة';

  @override
  String get detailsSimilar => 'أفلام مشابهة';

  @override
  String get personBiography => 'السيرة الذاتية';

  @override
  String get personNoBiography => 'لا توجد سيرة ذاتية متاحة.';

  @override
  String get personKnownFor => 'أبرز الأعمال';

  @override
  String personBorn(String date) {
    return 'تاريخ الميلاد: $date';
  }

  @override
  String get personPlaceOfBirth => 'مكان الميلاد';

  @override
  String get searchHint => 'ابحث عن فيلم';

  @override
  String get searchEmptyQuery => 'اكتب اسم فيلم لبدء البحث.';

  @override
  String searchNoResults(String query) {
    return 'لا توجد أفلام تطابق \"$query\".';
  }

  @override
  String get watchlistEmptyTitle => 'قائمة المشاهدة فارغة';

  @override
  String get watchlistEmptySubtitle =>
      'الأفلام التي تحفظها ستظهر هنا، حتى بدون إنترنت.';

  @override
  String get watchlistClearAll => 'مسح الكل';

  @override
  String get watchlistClearConfirmTitle => 'مسح قائمة المشاهدة؟';

  @override
  String get watchlistClearConfirmBody =>
      'سيؤدي هذا إلى إزالة جميع الأفلام من قائمة المشاهدة.';

  @override
  String get watchlistCancel => 'إلغاء';

  @override
  String get watchlistConfirm => 'مسح';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get accountSignIn => 'تسجيل الدخول';

  @override
  String get accountSignOut => 'تسجيل الخروج';

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String get accountDeleteConfirmTitle => 'حذف حسابك؟';

  @override
  String get accountDeleteConfirmBody =>
      'سيؤدي هذا إلى حذف حسابك وقائمة المشاهدة المحفوظة فيه نهائيًا، ولا يمكن التراجع عن ذلك.';

  @override
  String get accountDeleteConfirm => 'حذف';

  @override
  String get accountDeleted => 'تم حذف حسابك.';

  @override
  String get accountPageTitle => 'الملف الشخصي';

  @override
  String get accountGuestName => 'زائر';

  @override
  String get accountSectionAccount => 'الحساب';

  @override
  String get accountManageProfile => 'إدارة الملف الشخصي';

  @override
  String get accountSecurity => 'الأمان والخصوصية';

  @override
  String get accountMyWatchlist => 'قائمة المشاهدة';

  @override
  String get accountProfileName => 'الاسم';

  @override
  String get accountProfileNameRequired => 'اكتب اسمك';

  @override
  String get accountProfileSave => 'حفظ';

  @override
  String get accountProfileSaved => 'تم حفظ اسمك.';

  @override
  String get accountSignInMethod => 'طريقة تسجيل الدخول';

  @override
  String get accountSignInMethodGoogle => 'Google';

  @override
  String get accountSignInMethodEmail => 'البريد الإلكتروني وكلمة المرور';

  @override
  String get accountSectionSignIn => 'تسجيل الدخول';

  @override
  String get accountChangePassword => 'تغيير كلمة المرور';

  @override
  String get accountChangePasswordHint =>
      'سنرسل لك رابطًا بالبريد الإلكتروني لاختيار كلمة مرور جديدة.';

  @override
  String accountPasswordResetSent(String email) {
    return 'أرسلنا رابطًا إلى $email لتغيير كلمة المرور.';
  }

  @override
  String get accountGooglePasswordNote =>
      'أنت تسجّل الدخول بحساب Google، لذلك تُدار كلمة المرور من حسابك على Google.';

  @override
  String get accountSectionDanger => 'منطقة الخطر';

  @override
  String get accountDeleteHint =>
      'احذف حسابك وقائمة المشاهدة المتزامنة معه نهائيًا.';

  @override
  String get settingsSectionPreferences => 'التفضيلات';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsSectionSupport => 'الدعم';

  @override
  String get settingsHelpCenter => 'مركز المساعدة';

  @override
  String get settingsTerms => 'الشروط والسياسات';

  @override
  String get settingsAbout => 'من نحن';

  @override
  String get settingsLinkError => 'تعذّر فتح الرابط.';

  @override
  String get settingsTermsIntro =>
      'تطبيق الأفلام مشروع مجاني ضمن معرض أعمال. توضح هذه الصفحة ما يحفظه التطبيق وأين.';

  @override
  String get settingsTermsDeviceTitle => 'على جهازك';

  @override
  String get settingsTermsDeviceBody =>
      'تُحفظ قائمة المشاهدة والمظهر واللغة على هذا الهاتف، لذلك تعمل بدون إنترنت.';

  @override
  String get settingsTermsAccountTitle => 'إذا سجّلت الدخول';

  @override
  String get settingsTermsAccountBody =>
      'يُحفظ بريدك الإلكتروني واسمك وقائمة المشاهدة في Firebase (من Google)، لتظهر قائمتك على أجهزتك الأخرى. وعند حذف حسابك تُحذف كلها.';

  @override
  String get settingsTermsAnalyticsTitle => 'الإحصاءات وتقارير الأعطال';

  @override
  String get settingsTermsAnalyticsBody =>
      'يرسل التطبيق أحداث استخدام مجهولة الهوية وتقارير الأعطال إلى Firebase للمساعدة في إصلاح المشكلات، ولا تتضمن بريدك أو اسمك.';

  @override
  String get settingsTermsTmdbTitle => 'بيانات الأفلام';

  @override
  String get settingsTermsTmdbBody =>
      'الأفلام والملصقات والإعلانات مصدرها قاعدة بيانات الأفلام TMDB ويوتيوب. التطبيق لا يستضيف الأفلام الكاملة ولا يعرضها.';

  @override
  String settingsAboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsAboutDescription =>
      'تصفّح الأفلام الرائجة، وابحث، وشاهد الإعلانات، واحتفظ بقائمة مشاهدة، بالعربية والإنجليزية.';

  @override
  String get settingsAboutSourceCode => 'الكود المصدري على GitHub';

  @override
  String get settingsAboutLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authName => 'الاسم (اختياري)';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authSwitchToSignUp => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get authSwitchToSignIn => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String authResetEmailSent(String email) {
    return 'إذا كان هناك حساب مرتبط بـ $email، فقد أرسلنا إليه رابطًا لإعادة تعيين كلمة المرور.';
  }

  @override
  String get authOr => 'أو';

  @override
  String get authContinueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get authEmailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get authEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get authPasswordRequired => 'أدخل كلمة المرور';

  @override
  String authPasswordTooShort(int min) {
    return 'استخدم $min أحرف على الأقل';
  }

  @override
  String get authErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorEmailInUse =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. جرّب تسجيل الدخول.';

  @override
  String get authErrorWeakPassword => 'كلمة المرور ضعيفة جدًا. اختر كلمة أطول.';

  @override
  String get authErrorInvalidEmail => 'عنوان البريد الإلكتروني غير صالح.';

  @override
  String get authErrorUserDisabled => 'تم إيقاف هذا الحساب.';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة جدًا. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get authErrorRequiresRecentLogin =>
      'لحماية حسابك، سجّل الخروج ثم سجّل الدخول مرة أخرى، وبعدها احذف حسابك.';

  @override
  String get authErrorCancelled => 'تم إلغاء تسجيل الدخول.';

  @override
  String get authErrorUnavailable => 'تسجيل الدخول غير متاح حاليًا.';

  @override
  String get tmdbAttribution =>
      'يستخدم هذا المنتج واجهة TMDB البرمجية لكنه غير معتمد أو موثّق من TMDB.';

  @override
  String get trailerTitle => 'الإعلان';

  @override
  String get trailerOpenInYoutube => 'فتح في يوتيوب';

  @override
  String get trailerError => 'لا يمكن تشغيل هذا الإعلان داخل التطبيق.';
}
