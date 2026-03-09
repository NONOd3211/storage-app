// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Storage';

  @override
  String get tabItems => 'Items';

  @override
  String get tabLocations => 'Locations';

  @override
  String get tabStatistics => 'Stats';

  @override
  String selectionCount(Object count) {
    return 'Selected $count';
  }

  @override
  String get actionSelectAll => 'Select all';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get searchItemsHint => 'Search items';

  @override
  String get categoryAll => 'All';

  @override
  String get emptyNoItems => 'No items';

  @override
  String get emptyTapAddItem => 'Tap + to add items';

  @override
  String get emptyNoItemsInLocation => 'No items in this location';

  @override
  String get emptyNoLocations => 'No locations';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionExpirationReminder => 'Expiration Alerts';

  @override
  String get sectionAbout => 'About';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get themeUpdated => 'Theme updated';

  @override
  String get language => 'Language';

  @override
  String get languageFollowSystem => 'Follow system';

  @override
  String get languageSimplifiedChinese => 'Simplified Chinese';

  @override
  String get languageTraditionalChinese => 'Traditional Chinese';

  @override
  String get languageEnglish => 'English';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get notificationEnabled => 'Enable notifications';

  @override
  String get statusEnabled => 'Enabled';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get reminderSettings => 'Reminder settings';

  @override
  String get configureReminderSwitches => 'Configure four reminder switches';

  @override
  String get enableNotificationsFirst => 'Enable notifications first';

  @override
  String get warningReminder => 'Warning reminder';

  @override
  String get urgentReminder => 'Urgent reminder';

  @override
  String get oneDayReminder => '1-day before due reminder';

  @override
  String get dueDayReminder => 'Due day reminder';

  @override
  String get warningReminderSubtitle => 'Triggered by warning threshold';

  @override
  String get urgentReminderSubtitle => 'Triggered by urgent threshold';

  @override
  String get daysSuffix => 'days';

  @override
  String get thresholdNote => 'Note: red when remaining days are below urgent threshold; orange when below warning threshold.';

  @override
  String get versionLoading => 'Loading version...';

  @override
  String versionPrefix(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutDescriptionLine1 => 'A clean app to manage item storage';

  @override
  String get aboutDescriptionLine2 => 'Helps you track locations and expiration';

  @override
  String get featureTitle => 'Features';

  @override
  String get featureItem1 => '• Item management (add, edit, delete)';

  @override
  String get featureItem2 => '• Location management (preset + custom)';

  @override
  String get featureItem3 => '• Expiration tracking (smart status alerts)';

  @override
  String get featureItem4 => '• Category filtering';

  @override
  String get featureItem5 => '• Statistics';

  @override
  String get authorLabel => 'Author: Ice Wraith';

  @override
  String get locationUncategorized => 'Uncategorized';

  @override
  String get locationFridge => 'Fridge';

  @override
  String get locationCabinet => 'Cabinet';

  @override
  String get locationShelf => 'Shelf';

  @override
  String get locationManagementTitle => 'Location Management';

  @override
  String get presetLocation => 'Preset location';

  @override
  String get addLocationTitle => 'Add location';

  @override
  String get locationNameLabel => 'Location name';

  @override
  String get deleteLocationTitle => 'Delete location';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String confirmDeleteItem(Object itemName) {
    return 'Delete \"$itemName\"?';
  }

  @override
  String confirmDeleteItemWithIrreversible(Object itemName) {
    return 'Delete $itemName? This action cannot be undone.';
  }

  @override
  String confirmDeleteLocation(Object locationName) {
    return 'Delete location \"$locationName\"?';
  }

  @override
  String locationHasItems(Object locationName, Object count) {
    return 'Location \"$locationName\" has $count items.';
  }

  @override
  String get deleteLocationAlsoDeleteItems => 'Deleting this location will also delete all items below:';

  @override
  String andMoreItems(Object count) {
    return '...and $count items in total';
  }

  @override
  String deletedLocation(Object locationName) {
    return 'Location \"$locationName\" deleted';
  }

  @override
  String deletedLocationAndItems(Object locationName, Object count) {
    return 'Deleted location \"$locationName\" and $count items';
  }

  @override
  String get batchDeleteTitle => 'Batch delete';

  @override
  String batchDeleteConfirm(Object count) {
    return 'Delete $count selected items?';
  }

  @override
  String batchDeleted(Object count) {
    return 'Deleted $count items';
  }

  @override
  String deletedItem(Object itemName) {
    return '$itemName deleted';
  }

  @override
  String get batchTransferTitle => 'Batch transfer';

  @override
  String selectedItemsCount(Object count) {
    return 'Selected $count items';
  }

  @override
  String get targetLocation => 'Target location';

  @override
  String get confirmTransfer => 'Confirm transfer';

  @override
  String get noTransferTargetLocation => 'No available target location';

  @override
  String transferredItemsToLocation(Object count, Object locationName) {
    return 'Transferred $count items to $locationName';
  }

  @override
  String get itemDetailTitle => 'Item Details';

  @override
  String get expirationStatus => 'Expiration status';

  @override
  String get itemInfo => 'Item info';

  @override
  String get nameLabel => 'Name';

  @override
  String get categoryLabel => 'Category';

  @override
  String get storageLocationLabel => 'Storage location';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get expirationDateLabel => 'Expiration date';

  @override
  String get productionDateLabel => 'Production date';

  @override
  String get shelfLifeLabel => 'Shelf life';

  @override
  String get remainingDaysLabel => 'Remaining days';

  @override
  String get remarksLabel => 'Notes';

  @override
  String get addItemTitle => 'Add item';

  @override
  String get editItemTitle => 'Edit item';

  @override
  String get basicInfo => 'Basic info';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get itemNameRequired => 'Please enter item name';

  @override
  String get quantityRequired => 'Please enter quantity';

  @override
  String get quantityInvalid => 'Please enter a valid quantity';

  @override
  String get selectStorageLocationRequired => 'Please select a storage location';

  @override
  String get invalidStorageLocation => 'Please select a valid storage location';

  @override
  String get expirationInfo => 'Expiration info';

  @override
  String get useProductionDateAndShelfLife => 'Use production date + shelf-life days';

  @override
  String get productionDate => 'Production date';

  @override
  String get shelfLifeDays => 'Shelf-life days:';

  @override
  String get dayLabel => 'Days';

  @override
  String get dueDate => 'Due date';

  @override
  String get remarks => 'Notes';

  @override
  String get optionalRemarkHint => 'Add notes (optional)';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveFailedRetry => 'Save failed, please retry';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get categoryStatistics => 'Category statistics';

  @override
  String get locationStatistics => 'Location statistics';

  @override
  String get itemOverview => 'Item overview';

  @override
  String get totalLabel => 'Total';

  @override
  String get freshLabel => 'Fresh';

  @override
  String get warningLabel => 'Warning';

  @override
  String get urgentLabel => 'Urgent';

  @override
  String get expiredLabel => 'Expired';

  @override
  String get noItemData => 'No item data';

  @override
  String get noLocationData => 'No location data';

  @override
  String get statusFresh => 'Fresh';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusUrgent => 'Urgent';

  @override
  String get statusExpired => 'Expired';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryMedicine => 'Medicine';

  @override
  String get categoryCosmetics => 'Cosmetics';

  @override
  String get categoryDaily => 'Daily supplies';

  @override
  String get categoryOther => 'Other';

  @override
  String remainingDays(Object days) {
    return '$days days left';
  }

  @override
  String expiredDays(Object days) {
    return 'Expired for $days days';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String expiredDaysCompact(Object days) {
    return '$days days (expired)';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get warningDialogTitle => 'Warning reminder (days)';

  @override
  String get urgentDialogTitle => 'Urgent reminder (days)';

  @override
  String warningValidation(Object urgentDays) {
    return 'Warning days must be greater than urgent days ($urgentDays).';
  }

  @override
  String urgentValidation(Object warningDays) {
    return 'Urgent days must be less than warning days ($warningDays).';
  }

  @override
  String get notificationChannelName => 'Expiration reminders';

  @override
  String get notificationChannelDescription => 'Notifications for item expiration reminders';

  @override
  String get notificationWarningTitle => 'Expiring soon';

  @override
  String get notificationUrgentTitle => 'Urgent';

  @override
  String get notificationDueTitle => 'Due reminder';

  @override
  String notificationWarningBody(Object itemName, Object days) {
    return '$itemName will expire in $days days. Please use it soon!';
  }

  @override
  String notificationUrgentBody(Object itemName, Object days) {
    return '$itemName will expire in $days days. Please handle it soon!';
  }

  @override
  String notificationOneDayBody(Object itemName) {
    return '$itemName will expire in 1 day!';
  }

  @override
  String notificationDueBody(Object itemName) {
    return '$itemName is due today. Please handle it in time!';
  }
}
