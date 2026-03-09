import '../models/item.dart';
import '../models/storage_location.dart';
import 'app_localizations.dart';

extension ItemCategoryL10n on ItemCategory {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ItemCategory.food:
        return l10n.categoryFood;
      case ItemCategory.medicine:
        return l10n.categoryMedicine;
      case ItemCategory.cosmetics:
        return l10n.categoryCosmetics;
      case ItemCategory.daily:
        return l10n.categoryDaily;
      case ItemCategory.other:
        return l10n.categoryOther;
    }
  }
}

extension ExpirationStatusL10n on ExpirationStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExpirationStatus.fresh:
        return l10n.statusFresh;
      case ExpirationStatus.warning:
        return l10n.statusWarning;
      case ExpirationStatus.urgent:
        return l10n.statusUrgent;
      case ExpirationStatus.expired:
        return l10n.statusExpired;
    }
  }
}

extension StorageLocationL10n on StorageLocation {
  String localizedName(AppLocalizations l10n) {
    switch (id) {
      case StorageLocation.uncategorizedId:
        return l10n.locationUncategorized;
      case 'preset_1':
        return l10n.locationFridge;
      case 'preset_2':
        return l10n.locationCabinet;
      case 'preset_5':
        return l10n.locationShelf;
      default:
        return name;
    }
  }
}

extension ItemL10n on Item {
  String localizedStorageLocationName(AppLocalizations l10n) {
    return StorageLocation(
      id: storageLocationId,
      name: storageLocation,
    ).localizedName(l10n);
  }
}
