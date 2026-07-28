// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'Ассаляму алейкум,';

  @override
  String get nextPrayer => 'СЛЕДУЮЩИЙ НАМАЗ';

  @override
  String get unableToLoadPrayerTimes => 'Не удалось загрузить время намаза';

  @override
  String get retry => 'Повторить';

  @override
  String get continueListening => 'ПРОДОЛЖИТЬ СЛУШАТЬ';

  @override
  String get dailyAyah => 'АЯТ ДНЯ';

  @override
  String get popularReciters => 'Популярные чтецы';

  @override
  String get viewAll => 'СМОТРЕТЬ ВСЕ';

  @override
  String get quranTitle => 'Коран';

  @override
  String get allSurahs => 'Все суры';

  @override
  String get juz => 'Джуз';

  @override
  String get makkah => 'Мекканские';

  @override
  String get madinah => 'Мединские';

  @override
  String get bookmarksFilter => 'Закладки';

  @override
  String get searchHint => 'Поиск суры, джуза или ключевого слова...';

  @override
  String get lastRead => 'ПОСЛЕДНЕЕ ЧТЕНИЕ';

  @override
  String ayahLabel(int n) {
    return 'Аят $n';
  }

  @override
  String percentCompleted(String pct) {
    return '$pct% завершено';
  }

  @override
  String pagesRange(int start, int end) {
    return 'Страницы $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'СТРАНИЦЫ $start–$end';
  }

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String get removeDownload => 'Удалить загрузку';

  @override
  String deleteOfflineCopy(String surahName) {
    return 'Удалить офлайн-копию $surahName?';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get queue => 'ОЧЕРЕДЬ';

  @override
  String get noSurahsInQueue => 'В очереди нет сур';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'Сура $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'Загрузки';

  @override
  String get manageOfflineLibrary =>
      'Управляйте своей офлайн-библиотекой Корана';

  @override
  String get offlineMode => 'ОФЛАЙН-РЕЖИМ';

  @override
  String get storageUsage => 'ИСПОЛЬЗОВАНИЕ ПАМЯТИ';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'сур',
      few: 'суры',
      one: 'сура',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'ОЧИСТИТЬ ВСЕ';

  @override
  String get downloadedByReciter => 'ЗАГРУЖЕНО ПО ЧТЕЦУ';

  @override
  String get clearAllDownloads => 'Очистить все загрузки';

  @override
  String get clearAllDownloadsConfirm =>
      'Это удалит все загруженные суры с устройства. Действие нельзя отменить.';

  @override
  String get clearAllButton => 'Очистить все';

  @override
  String get noDownloadsYet => 'Загрузок пока нет';

  @override
  String get noDownloadsSubtitle =>
      'Нажмите значок загрузки в плеере, чтобы сохранить суру для офлайн-прослушивания.';

  @override
  String get bookmarksTitle => 'Закладки';

  @override
  String get myBookmarks => 'Мои закладки';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сохранённых аятов',
      few: '$count сохранённых аята',
      one: '$count сохранённый аят',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'Последнее чтение';

  @override
  String get noSurahOpenedYet => 'Ни одна сура ещё не открыта';

  @override
  String get openSurahFromQuranTab => 'Откройте суру на вкладке Коран';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'Аят $ayah • Страницы $start–$end';
  }

  @override
  String get continueReading => 'Продолжить чтение';

  @override
  String get noBookmarksYet => 'Закладок пока нет';

  @override
  String get noBookmarksSubtitle =>
      'Начните сохранять любимые аяты, чтобы создать личную духовную сокровищницу.';

  @override
  String get exploreQuran => 'Изучить Коран';

  @override
  String get recitersTitle => 'Чтецы';

  @override
  String get featuredReciters => 'Избранные чтецы';

  @override
  String get searchRecitersHint => 'Поиск по имени или стилю...';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get appearance => 'ВНЕШНИЙ ВИД';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get notifications => 'УВЕДОМЛЕНИЯ';

  @override
  String get prayerTimesReminders => 'Время намаза и напоминания';

  @override
  String get prayerTimesSubtitle => 'Получать уведомления о времени намаза';

  @override
  String get dailyReflectionReminder => 'Напоминание о ежедневном размышлении';

  @override
  String get dailyReflectionSubtitle =>
      'Мягкое напоминание о вашем ежедневном аяте';

  @override
  String get offline => 'ОФЛАЙН';

  @override
  String get offlineModeTitle => 'Офлайн-режим';

  @override
  String get offlineModeSubtitle => 'Воспроизводить только загруженные суры';

  @override
  String get dataPrivacy => 'ДАННЫЕ И КОНФИДЕНЦИАЛЬНОСТЬ';

  @override
  String get clearAllData => 'Очистить все данные';

  @override
  String get clearAllDataSubtitle =>
      'Сбросить приложение до начального состояния';

  @override
  String get about => 'О ПРИЛОЖЕНИИ';

  @override
  String get supportApp => 'Поддержать это приложение';

  @override
  String get supportAppSubtitle =>
      'Бесплатная садака — пожертвуйте, если приложение полезно';

  @override
  String get version => 'Версия';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get systemDefault => 'Системная тема';

  @override
  String get chooseLanguage => 'Выбрать язык';

  @override
  String get chooseTheme => 'Выбрать тему';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get clearAllDataTitle => 'Очистить все данные';

  @override
  String get clearAllDataConfirm =>
      'Это удалит все закладки, загрузки, статистику и настройки. Действие нельзя отменить.';

  @override
  String get clearAllDataButton => 'Очистить всё';

  @override
  String get done => 'Готово';

  @override
  String get allDataCleared => 'Все данные очищены. Перезапустите приложение.';

  @override
  String get dailyReflectionLabel => 'ЕЖЕДНЕВНОЕ РАЗМЫШЛЕНИЕ';

  @override
  String get listen => 'Слушать';

  @override
  String get save => 'Сохранить';

  @override
  String get share => 'Поделиться';

  @override
  String get previousReflections => 'Предыдущие размышления';

  @override
  String get viewAllButton => 'Смотреть все';

  @override
  String get addReflection => 'Добавить размышление';

  @override
  String get myReflection => 'МОЁ РАЗМЫШЛЕНИЕ';

  @override
  String get reflectionHint => 'Как этот аят перекликается с вашим днём?';

  @override
  String get clear => 'Очистить';

  @override
  String get saveNote => 'Сохранить заметку';

  @override
  String get saved => 'Сохранено';

  @override
  String get reflectionCleared => 'Ваше размышление очищено.';

  @override
  String get reflectionSaved => 'Ваше размышление сохранено.';

  @override
  String get selectAyah => 'ВЫБРАТЬ АЯТ';

  @override
  String get selectAyahDefault => 'Выбрать аят';

  @override
  String get yourReflection => 'ВАШЕ РАЗМЫШЛЕНИЕ';

  @override
  String get saveReflection => 'Сохранить размышление';

  @override
  String get selectAyahSheet => 'Выбрать аят';

  @override
  String get empty => 'Пусто';

  @override
  String get pleaseWriteReflection =>
      'Пожалуйста, сначала напишите своё размышление.';

  @override
  String get reflectionHasSaved => 'Ваше размышление сохранено.';

  @override
  String get allReflections => 'ВСЕ РАЗМЫШЛЕНИЯ';

  @override
  String get yourReflections => 'Ваши размышления';

  @override
  String get noMoreReflections => 'Размышлений пока нет';

  @override
  String get noMoreReflectionsSubtitle =>
      'Нажмите «Добавить размышление», чтобы сохранить свои мысли о любом аяте.';

  @override
  String get addFirstReflection => 'Добавьте первое размышление';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingGetStarted => 'НАЧАТЬ';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingSlide1Title => 'Откройте для себя чтение Корана';

  @override
  String get onboardingSlide1Body =>
      'Прочувствуйте божественное слово через самые прекрасные голоса мира в пространстве, созданном для вашей души.';

  @override
  String get onboardingSlide2Title => 'Слушайте где угодно';

  @override
  String get onboardingSlide2Body =>
      'Загружайте любимые чтения и слушайте их офлайн, даже в самых отдалённых местах.';

  @override
  String get onboardingSlide3Title => 'Учитесь и размышляйте';

  @override
  String get onboardingSlide3Body =>
      'Погрузитесь глубже в божественную мудрость с пословным тафсиром и организованными закладками для вашего духовного пути.';
}
