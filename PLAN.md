# خطة تنفيذ تطبيق الأفلام (Movie App) — نسخة 2

## 1. الهدف
مشروع تاني في الـ CV جنب Beauty، يوضّح المهارات اللي إعلانات Flutter في مصر بتطلبها ومش موجودة في Beauty:
**Bloc/Cubit · REST API (Dio) · Clean Architecture · Hive · go_router · Unit + Widget Tests · CI على GitHub Actions**

## 2. البيئة (اتأكدنا منها على جهازك)
Flutter 3.44.5 · Dart 3.12.2. مش هنستخدم freezed، لأن نسخته الجديدة محتاجة Dart أحدث، وهنستخدم بداله `sealed classes` و `equatable`. وأي package هيتضاف بأمر `flutter pub add`.

## 3. المميزات
| الشاشة | المحتوى |
|---|---|
| الرئيسية | Trending و Top Rated و Upcoming، مع Skeleton loading و Pull-to-refresh |
| See All | Grid فيه pagination لأي قسم (مش pagination في الأقسام الثلاثة) |
| تفاصيل الفيلم | Hero animation للبوستر، والقصة والتقييم والممثلين، وزرار التريلر يفتح YouTube، كل ده من request واحد |
| البحث | **Bloc** بـ debounce ويلغي الطلبات القديمة، مع حالات التحميل والنتايج الفاضية والأخطاء |
| Watchlist | Hive، وبتشتغل من غير نت |
| Offline | أول صفحة من كل قسم بتتحفظ، وتظهر مع شريط "أنت أوفلاين" |
| الإعدادات | Dark/Light mode وعربي/إنجليزي بـ Cubit بسيط |

## 4. الهيكل
Clean Architecture **عملية مش مبالغ فيها**:
- 3 طبقات: data و domain و presentation.
- الـ Cubit بيكلّم الـ Repository مباشرة، و use cases بس للحاجات اللي ليها منطق، زي ToggleWatchlist و GetMovieDetails.
- الإعدادات Cubit بسيط من غير طبقات.
- الأخطاء: `sealed Failure` (NetworkFailure و ServerFailure و NotFound و CacheFailure) و `Result<T>`.
- TMDB: الـ **Read Access Token** بيتبعت في Header، والمفتاح متخزن في `env.json` اللي مش هيترفع على GitHub.

## 5. المراحل
| # | المرحلة | مين | شرط إنها خلصت |
|---|---|---|---|
| 0 | تجيبي الـ Token من TMDB، ونتأكد إن الـ API والصور بيفتحوا من النت عندك | **انتي** | request تجريبي بيرجع بيانات |
| 1 | الأساس: كل الـ packages والـ core والـ router بكل الصفحات (فاضية) والـ DI والـ l10n | خبير واحد | analyze بـ 0 مشاكل، و build apk بينجح، والتطبيق بيفتح ويجيب بيانات حقيقية |
| 2a | **النموذج المرجعي:** Trending والتفاصيل كاملين بالـ tests | خبير واحد | الـ tests بتعدّي، وبتشتغل على الـ Emulator |
| 2b | البحث ‖ الـ Watchlist والإعدادات ‖ باقي أقسام الرئيسية و See All | 3 خبراء بالتوازي، كل واحد في نسخة لوحده (worktree) | كل خبير بيلمس الملفات بتاعته بس |
| 3 | الدمج: أدمج نسخة نسخة، وأجرّب على الـ Emulator، وأضيف الـ Offline cache | أنا | كل السيناريوهات شغالة، وفيها وضع الطيارة |
| 4 | Widget tests و integration test واحد، ومراجعة مستقلة | خبيرين | التغطية ≥ 70% |
| 5 | التسليم: CI و README و Release APK | خبير وأنا | الـ CI أخضر، والـ README بيشتغل من clone جديد |

**قواعد عشان الخبراء ميبوّظوش شغل بعض:** بعد المرحلة 1 بيتقفل التعديل على pubspec و main و router و DI والـ ARB. أي خبير محتاج حاجة فيهم بيطلبها مني. وأنا بنفسي بعيد تشغيل كل الـ tests والفحوصات، ومش بعتمد على تقرير الخبير.

## 6. نقط توقف ليكي + تمارين تعمليها بنفسك
| بعد | هشرحلك | تمرينك |
|---|---|---|
| المرحلة 1 | الطلب بيمشي إزاي: main ← DI ← Dio ← Repository | تضيفي interceptor يغيّر لغة الـ API حسب لغة التطبيق |
| المرحلة 2a ⭐ | طبقات Clean Architecture ودورة حياة الـ Cubit | تضيفي قسم **Now Playing** بنفسك |
| المرحلة 3 | go_router و Hive | زرار "مسح الـ Watchlist" مع رسالة تأكيد |
| المرحلة 4 | bloc_test و mocktail | تكتبي tests للـ Cubit بتاع Now Playing |
| قبل الرفع | — | **Mock interview:** تشرحيلي المشروع في 5 دقايق |

## 7. Git و GitHub
- commits صغيرة بأسماء واضحة (feat و fix و test)، مش commit ضخم لكل مرحلة.
- **مفيش رفع على GitHub غير بموافقتك.**

## 8. الـ README
- GIF في أول الصفحة، وscreenshots للوضع الفاتح والغامق وللعربي والإنجليزي.
- Badge للـ CI ولينك تحميل APK.
- رسمة للـ architecture وقسم "ليه اخترت كذا".
- طريقة التشغيل، وذكر TMDB زي ما شروط استخدامهم بتطلب.

## 9. المدة
حوالي يومين شغل للخبراء. ومع شرحي ليكي والتمارين: **أسبوع لأسبوع ونص.**
