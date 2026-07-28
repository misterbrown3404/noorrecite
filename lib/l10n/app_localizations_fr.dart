// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'Assalamu Alaikum,';

  @override
  String get nextPrayer => 'PROCHAINE PRIÈRE';

  @override
  String get unableToLoadPrayerTimes =>
      'Impossible de charger les horaires de prière';

  @override
  String get retry => 'Réessayer';

  @override
  String get continueListening => 'CONTINUER L\'ÉCOUTE';

  @override
  String get dailyAyah => 'VERSET DU JOUR';

  @override
  String get popularReciters => 'Récitateurs populaires';

  @override
  String get viewAll => 'TOUT VOIR';

  @override
  String get quranTitle => 'Coran';

  @override
  String get allSurahs => 'Toutes les sourates';

  @override
  String get juz => 'Jouz';

  @override
  String get makkah => 'Mecquoise';

  @override
  String get madinah => 'Médinoise';

  @override
  String get bookmarksFilter => 'Favoris';

  @override
  String get searchHint => 'Rechercher une sourate, un jouz ou un mot-clé...';

  @override
  String get lastRead => 'DERNIÈRE LECTURE';

  @override
  String ayahLabel(int n) {
    return 'Verset $n';
  }

  @override
  String percentCompleted(String pct) {
    return '$pct% terminé';
  }

  @override
  String pagesRange(int start, int end) {
    return 'Pages $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'PAGES $start–$end';
  }

  @override
  String get nowPlaying => 'En cours de lecture';

  @override
  String get removeDownload => 'Supprimer le téléchargement';

  @override
  String deleteOfflineCopy(String surahName) {
    return 'Supprimer la copie hors ligne de $surahName ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get queue => 'FILE D\'ATTENTE';

  @override
  String get noSurahsInQueue => 'Aucune sourate dans la file d\'attente';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'Sourate $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'Téléchargements';

  @override
  String get manageOfflineLibrary =>
      'Gérez votre bibliothèque coranique hors ligne';

  @override
  String get offlineMode => 'MODE HORS LIGNE';

  @override
  String get storageUsage => 'UTILISATION DU STOCKAGE';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sourates',
      one: 'sourate',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'TOUT EFFACER';

  @override
  String get downloadedByReciter => 'TÉLÉCHARGÉ PAR RÉCITATEUR';

  @override
  String get clearAllDownloads => 'Effacer tous les téléchargements';

  @override
  String get clearAllDownloadsConfirm =>
      'Cela supprime toutes les sourates téléchargées de cet appareil. Cette action est irréversible.';

  @override
  String get clearAllButton => 'Tout effacer';

  @override
  String get noDownloadsYet => 'Aucun téléchargement pour l\'instant';

  @override
  String get noDownloadsSubtitle =>
      'Appuyez sur l\'icône de téléchargement dans le lecteur pour sauvegarder une sourate pour l\'écoute hors ligne.';

  @override
  String get bookmarksTitle => 'Signets';

  @override
  String get myBookmarks => 'Mes signets';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets sauvegardés',
      one: '$count verset sauvegardé',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'Dernière lecture';

  @override
  String get noSurahOpenedYet => 'Aucune sourate ouverte';

  @override
  String get openSurahFromQuranTab =>
      'Ouvrez une sourate depuis l\'onglet Coran';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'Verset $ayah • Pages $start–$end';
  }

  @override
  String get continueReading => 'Continuer la lecture';

  @override
  String get noBookmarksYet => 'Aucun signet pour l\'instant';

  @override
  String get noBookmarksSubtitle =>
      'Commencez à sauvegarder vos versets préférés pour construire votre trésor spirituel personnel.';

  @override
  String get exploreQuran => 'Explorer le Coran';

  @override
  String get recitersTitle => 'Récitateurs';

  @override
  String get featuredReciters => 'Récitateurs en vedette';

  @override
  String get searchRecitersHint => 'Rechercher par nom ou style...';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get appearance => 'APPARENCE';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'NOTIFICATIONS';

  @override
  String get prayerTimesReminders => 'Horaires de prière et rappels';

  @override
  String get prayerTimesSubtitle =>
      'Recevoir des notifications pour les heures de prière';

  @override
  String get dailyReflectionReminder => 'Rappel de réflexion quotidienne';

  @override
  String get dailyReflectionSubtitle =>
      'Un rappel doux pour votre verset quotidien';

  @override
  String get offline => 'HORS LIGNE';

  @override
  String get offlineModeTitle => 'Mode hors ligne';

  @override
  String get offlineModeSubtitle => 'Lire uniquement les sourates téléchargées';

  @override
  String get dataPrivacy => 'DONNÉES ET CONFIDENTIALITÉ';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get clearAllDataSubtitle => 'Réinitialiser l\'application';

  @override
  String get about => 'À PROPOS';

  @override
  String get supportApp => 'Soutenir cette application';

  @override
  String get supportAppSubtitle =>
      'Sadaqa gratuite — faites un don si vous en bénéficiez';

  @override
  String get version => 'Version';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get systemDefault => 'Paramètre système';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get chooseTheme => 'Choisir le thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get clearAllDataTitle => 'Effacer toutes les données';

  @override
  String get clearAllDataConfirm =>
      'Cela supprimera tous les signets, téléchargements, statistiques et paramètres. Cette action est irréversible.';

  @override
  String get clearAllDataButton => 'Tout effacer';

  @override
  String get done => 'Terminé';

  @override
  String get allDataCleared =>
      'Toutes les données effacées. Redémarrez l\'application.';

  @override
  String get dailyReflectionLabel => 'RÉFLEXION QUOTIDIENNE';

  @override
  String get listen => 'Écouter';

  @override
  String get save => 'Sauvegarder';

  @override
  String get share => 'Partager';

  @override
  String get previousReflections => 'Réflexions précédentes';

  @override
  String get viewAllButton => 'Tout voir';

  @override
  String get addReflection => 'Ajouter une réflexion';

  @override
  String get myReflection => 'MA RÉFLEXION';

  @override
  String get reflectionHint =>
      'Comment ce verset résonne-t-il avec votre journée ?';

  @override
  String get clear => 'Effacer';

  @override
  String get saveNote => 'Sauvegarder la note';

  @override
  String get saved => 'Sauvegardé';

  @override
  String get reflectionCleared => 'Votre réflexion a été effacée.';

  @override
  String get reflectionSaved => 'Votre réflexion a été sauvegardée.';

  @override
  String get selectAyah => 'SÉLECTIONNER UN VERSET';

  @override
  String get selectAyahDefault => 'Sélectionner un verset';

  @override
  String get yourReflection => 'VOTRE RÉFLEXION';

  @override
  String get saveReflection => 'Sauvegarder la réflexion';

  @override
  String get selectAyahSheet => 'Sélectionner un verset';

  @override
  String get empty => 'Vide';

  @override
  String get pleaseWriteReflection =>
      'Veuillez d\'abord écrire votre réflexion.';

  @override
  String get reflectionHasSaved => 'Votre réflexion a été sauvegardée.';

  @override
  String get allReflections => 'TOUTES LES RÉFLEXIONS';

  @override
  String get yourReflections => 'Vos réflexions';

  @override
  String get noMoreReflections => 'Aucune réflexion pour l\'instant';

  @override
  String get noMoreReflectionsSubtitle =>
      'Appuyez sur \"Ajouter une réflexion\" pour sauvegarder vos pensées sur n\'importe quel verset.';

  @override
  String get addFirstReflection => 'Ajoutez votre première réflexion';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingGetStarted => 'COMMENCER';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingSlide1Title => 'Découvrez la récitation du Coran';

  @override
  String get onboardingSlide1Body =>
      'Vivez la parole divine à travers les plus belles voix du monde dans un sanctuaire conçu pour votre âme.';

  @override
  String get onboardingSlide2Title => 'Écoutez partout';

  @override
  String get onboardingSlide2Body =>
      'Téléchargez vos récitations préférées et écoutez-les hors ligne, même dans les sanctuaires les plus reculés.';

  @override
  String get onboardingSlide3Title => 'Apprenez et réfléchissez';

  @override
  String get onboardingSlide3Body =>
      'Plongez plus profondément dans la sagesse divine avec le Tafsir mot à mot et des signets organisés pour votre voyage spirituel.';
}
