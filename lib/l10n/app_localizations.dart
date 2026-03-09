import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get appTitle;

  /// No description provided for @tabItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get tabItems;

  /// No description provided for @tabLocations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get tabLocations;

  /// No description provided for @tabStatistics.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStatistics;

  /// No description provided for @selectionCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count}'**
  String selectionCount(Object count);

  /// No description provided for @actionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get actionSelectAll;

  /// No description provided for @actionTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get actionTransfer;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @searchItemsHint.
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get searchItemsHint;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @emptyNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get emptyNoItems;

  /// No description provided for @emptyTapAddItem.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add items'**
  String get emptyTapAddItem;

  /// No description provided for @emptyNoItemsInLocation.
  ///
  /// In en, this message translates to:
  /// **'No items in this location'**
  String get emptyNoItemsInLocation;

  /// No description provided for @emptyNoLocations.
  ///
  /// In en, this message translates to:
  /// **'No locations'**
  String get emptyNoLocations;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionExpirationReminder.
  ///
  /// In en, this message translates to:
  /// **'Expiration Alerts'**
  String get sectionExpirationReminder;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get selectTheme;

  /// No description provided for @themeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Theme updated'**
  String get themeUpdated;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageFollowSystem;

  /// No description provided for @languageSimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageSimplifiedChinese;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageTraditionalChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @notificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationEnabled;

  /// No description provided for @statusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get statusEnabled;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statusDisabled;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder settings'**
  String get reminderSettings;

  /// No description provided for @configureReminderSwitches.
  ///
  /// In en, this message translates to:
  /// **'Configure four reminder switches'**
  String get configureReminderSwitches;

  /// No description provided for @enableNotificationsFirst.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications first'**
  String get enableNotificationsFirst;

  /// No description provided for @warningReminder.
  ///
  /// In en, this message translates to:
  /// **'Warning reminder'**
  String get warningReminder;

  /// No description provided for @urgentReminder.
  ///
  /// In en, this message translates to:
  /// **'Urgent reminder'**
  String get urgentReminder;

  /// No description provided for @oneDayReminder.
  ///
  /// In en, this message translates to:
  /// **'1-day before due reminder'**
  String get oneDayReminder;

  /// No description provided for @dueDayReminder.
  ///
  /// In en, this message translates to:
  /// **'Due day reminder'**
  String get dueDayReminder;

  /// No description provided for @warningReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Triggered by warning threshold'**
  String get warningReminderSubtitle;

  /// No description provided for @urgentReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Triggered by urgent threshold'**
  String get urgentReminderSubtitle;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysSuffix;

  /// No description provided for @thresholdNote.
  ///
  /// In en, this message translates to:
  /// **'Note: red when remaining days are below urgent threshold; orange when below warning threshold.'**
  String get thresholdNote;

  /// No description provided for @versionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading version...'**
  String get versionLoading;

  /// No description provided for @versionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionPrefix(Object version);

  /// No description provided for @aboutDescriptionLine1.
  ///
  /// In en, this message translates to:
  /// **'A clean app to manage item storage'**
  String get aboutDescriptionLine1;

  /// No description provided for @aboutDescriptionLine2.
  ///
  /// In en, this message translates to:
  /// **'Helps you track locations and expiration'**
  String get aboutDescriptionLine2;

  /// No description provided for @featureTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featureTitle;

  /// No description provided for @featureItem1.
  ///
  /// In en, this message translates to:
  /// **'• Item management (add, edit, delete)'**
  String get featureItem1;

  /// No description provided for @featureItem2.
  ///
  /// In en, this message translates to:
  /// **'• Location management (preset + custom)'**
  String get featureItem2;

  /// No description provided for @featureItem3.
  ///
  /// In en, this message translates to:
  /// **'• Expiration tracking (smart status alerts)'**
  String get featureItem3;

  /// No description provided for @featureItem4.
  ///
  /// In en, this message translates to:
  /// **'• Category filtering'**
  String get featureItem4;

  /// No description provided for @featureItem5.
  ///
  /// In en, this message translates to:
  /// **'• Statistics'**
  String get featureItem5;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author: Ice Wraith'**
  String get authorLabel;

  /// No description provided for @locationUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get locationUncategorized;

  /// No description provided for @locationFridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get locationFridge;

  /// No description provided for @locationCabinet.
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get locationCabinet;

  /// No description provided for @locationShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get locationShelf;

  /// No description provided for @locationManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Management'**
  String get locationManagementTitle;

  /// No description provided for @presetLocation.
  ///
  /// In en, this message translates to:
  /// **'Preset location'**
  String get presetLocation;

  /// No description provided for @addLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addLocationTitle;

  /// No description provided for @locationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Location name'**
  String get locationNameLabel;

  /// No description provided for @deleteLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete location'**
  String get deleteLocationTitle;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{itemName}\"?'**
  String confirmDeleteItem(Object itemName);

  /// No description provided for @confirmDeleteItemWithIrreversible.
  ///
  /// In en, this message translates to:
  /// **'Delete {itemName}? This action cannot be undone.'**
  String confirmDeleteItemWithIrreversible(Object itemName);

  /// No description provided for @confirmDeleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Delete location \"{locationName}\"?'**
  String confirmDeleteLocation(Object locationName);

  /// No description provided for @locationHasItems.
  ///
  /// In en, this message translates to:
  /// **'Location \"{locationName}\" has {count} items.'**
  String locationHasItems(Object locationName, Object count);

  /// No description provided for @deleteLocationAlsoDeleteItems.
  ///
  /// In en, this message translates to:
  /// **'Deleting this location will also delete all items below:'**
  String get deleteLocationAlsoDeleteItems;

  /// No description provided for @andMoreItems.
  ///
  /// In en, this message translates to:
  /// **'...and {count} items in total'**
  String andMoreItems(Object count);

  /// No description provided for @deletedLocation.
  ///
  /// In en, this message translates to:
  /// **'Location \"{locationName}\" deleted'**
  String deletedLocation(Object locationName);

  /// No description provided for @deletedLocationAndItems.
  ///
  /// In en, this message translates to:
  /// **'Deleted location \"{locationName}\" and {count} items'**
  String deletedLocationAndItems(Object locationName, Object count);

  /// No description provided for @batchDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch delete'**
  String get batchDeleteTitle;

  /// No description provided for @batchDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected items?'**
  String batchDeleteConfirm(Object count);

  /// No description provided for @batchDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} items'**
  String batchDeleted(Object count);

  /// No description provided for @deletedItem.
  ///
  /// In en, this message translates to:
  /// **'{itemName} deleted'**
  String deletedItem(Object itemName);

  /// No description provided for @batchTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch transfer'**
  String get batchTransferTitle;

  /// No description provided for @selectedItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} items'**
  String selectedItemsCount(Object count);

  /// No description provided for @targetLocation.
  ///
  /// In en, this message translates to:
  /// **'Target location'**
  String get targetLocation;

  /// No description provided for @confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm transfer'**
  String get confirmTransfer;

  /// No description provided for @noTransferTargetLocation.
  ///
  /// In en, this message translates to:
  /// **'No available target location'**
  String get noTransferTargetLocation;

  /// No description provided for @transferredItemsToLocation.
  ///
  /// In en, this message translates to:
  /// **'Transferred {count} items to {locationName}'**
  String transferredItemsToLocation(Object count, Object locationName);

  /// No description provided for @itemDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetailTitle;

  /// No description provided for @expirationStatus.
  ///
  /// In en, this message translates to:
  /// **'Expiration status'**
  String get expirationStatus;

  /// No description provided for @itemInfo.
  ///
  /// In en, this message translates to:
  /// **'Item info'**
  String get itemInfo;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @storageLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get storageLocationLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @expirationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDateLabel;

  /// No description provided for @productionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Production date'**
  String get productionDateLabel;

  /// No description provided for @shelfLifeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shelf life'**
  String get shelfLifeLabel;

  /// No description provided for @remainingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining days'**
  String get remainingDaysLabel;

  /// No description provided for @remarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get remarksLabel;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemTitle;

  /// No description provided for @editItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItemTitle;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get basicInfo;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemNameLabel;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter item name'**
  String get itemNameRequired;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get quantityRequired;

  /// No description provided for @quantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get quantityInvalid;

  /// No description provided for @selectStorageLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a storage location'**
  String get selectStorageLocationRequired;

  /// No description provided for @invalidStorageLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid storage location'**
  String get invalidStorageLocation;

  /// No description provided for @expirationInfo.
  ///
  /// In en, this message translates to:
  /// **'Expiration info'**
  String get expirationInfo;

  /// No description provided for @useProductionDateAndShelfLife.
  ///
  /// In en, this message translates to:
  /// **'Use production date + shelf-life days'**
  String get useProductionDateAndShelfLife;

  /// No description provided for @productionDate.
  ///
  /// In en, this message translates to:
  /// **'Production date'**
  String get productionDate;

  /// No description provided for @shelfLifeDays.
  ///
  /// In en, this message translates to:
  /// **'Shelf-life days:'**
  String get shelfLifeDays;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dayLabel;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get remarks;

  /// No description provided for @optionalRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes (optional)'**
  String get optionalRemarkHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Save failed, please retry'**
  String get saveFailedRetry;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @categoryStatistics.
  ///
  /// In en, this message translates to:
  /// **'Category statistics'**
  String get categoryStatistics;

  /// No description provided for @locationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Location statistics'**
  String get locationStatistics;

  /// No description provided for @itemOverview.
  ///
  /// In en, this message translates to:
  /// **'Item overview'**
  String get itemOverview;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @freshLabel.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get freshLabel;

  /// No description provided for @warningLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningLabel;

  /// No description provided for @urgentLabel.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentLabel;

  /// No description provided for @expiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredLabel;

  /// No description provided for @noItemData.
  ///
  /// In en, this message translates to:
  /// **'No item data'**
  String get noItemData;

  /// No description provided for @noLocationData.
  ///
  /// In en, this message translates to:
  /// **'No location data'**
  String get noLocationData;

  /// No description provided for @statusFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get statusFresh;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// No description provided for @statusUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get statusUrgent;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get categoryMedicine;

  /// No description provided for @categoryCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get categoryCosmetics;

  /// No description provided for @categoryDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily supplies'**
  String get categoryDaily;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @remainingDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String remainingDays(Object days);

  /// No description provided for @expiredDays.
  ///
  /// In en, this message translates to:
  /// **'Expired for {days} days'**
  String expiredDays(Object days);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @expiredDaysCompact.
  ///
  /// In en, this message translates to:
  /// **'{days} days (expired)'**
  String expiredDaysCompact(Object days);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @warningDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning reminder (days)'**
  String get warningDialogTitle;

  /// No description provided for @urgentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent reminder (days)'**
  String get urgentDialogTitle;

  /// No description provided for @warningValidation.
  ///
  /// In en, this message translates to:
  /// **'Warning days must be greater than urgent days ({urgentDays}).'**
  String warningValidation(Object urgentDays);

  /// No description provided for @urgentValidation.
  ///
  /// In en, this message translates to:
  /// **'Urgent days must be less than warning days ({warningDays}).'**
  String urgentValidation(Object warningDays);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Expiration reminders'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications for item expiration reminders'**
  String get notificationChannelDescription;

  /// No description provided for @notificationWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get notificationWarningTitle;

  /// No description provided for @notificationUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get notificationUrgentTitle;

  /// No description provided for @notificationDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Due reminder'**
  String get notificationDueTitle;

  /// No description provided for @notificationWarningBody.
  ///
  /// In en, this message translates to:
  /// **'{itemName} will expire in {days} days. Please use it soon!'**
  String notificationWarningBody(Object itemName, Object days);

  /// No description provided for @notificationUrgentBody.
  ///
  /// In en, this message translates to:
  /// **'{itemName} will expire in {days} days. Please handle it soon!'**
  String notificationUrgentBody(Object itemName, Object days);

  /// No description provided for @notificationOneDayBody.
  ///
  /// In en, this message translates to:
  /// **'{itemName} will expire in 1 day!'**
  String notificationOneDayBody(Object itemName);

  /// No description provided for @notificationDueBody.
  ///
  /// In en, this message translates to:
  /// **'{itemName} is due today. Please handle it in time!'**
  String notificationDueBody(Object itemName);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.countryCode) {
    case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
