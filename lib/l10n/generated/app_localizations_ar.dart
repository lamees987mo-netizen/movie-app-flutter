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
  String get navSettings => 'الإعدادات';

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
  String get detailsOverview => 'القصة';

  @override
  String get detailsCast => 'طاقم التمثيل';

  @override
  String get detailsPlayTrailer => 'تشغيل الإعلان';

  @override
  String detailsRuntimeMinutes(int minutes) {
    return '$minutes دقيقة';
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
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'حسب النظام';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get tmdbAttribution =>
      'يستخدم هذا المنتج واجهة TMDB البرمجية لكنه غير معتمد أو موثّق من TMDB.';
}
