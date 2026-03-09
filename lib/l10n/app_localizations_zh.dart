// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '收纳';

  @override
  String get tabItems => '物品';

  @override
  String get tabLocations => '位置';

  @override
  String get tabStatistics => '统计';

  @override
  String selectionCount(Object count) {
    return '已选择 $count 项';
  }

  @override
  String get actionSelectAll => '全选';

  @override
  String get actionTransfer => '转移';

  @override
  String get actionDelete => '删除';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionAdd => '添加';

  @override
  String get searchItemsHint => '搜索物品';

  @override
  String get categoryAll => '全部';

  @override
  String get emptyNoItems => '暂无物品';

  @override
  String get emptyTapAddItem => '点击右上角添加物品';

  @override
  String get emptyNoItemsInLocation => '该位置暂无物品';

  @override
  String get emptyNoLocations => '暂无位置';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionExpirationReminder => '保质期提醒';

  @override
  String get sectionAbout => '关于';

  @override
  String get theme => '皮肤';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get selectTheme => '选择皮肤';

  @override
  String get themeUpdated => '皮肤已更新';

  @override
  String get language => '语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageUpdated => '语言已更新';

  @override
  String get notificationEnabled => '启用通知';

  @override
  String get statusEnabled => '已开启';

  @override
  String get statusDisabled => '已关闭';

  @override
  String get reminderSettings => '提醒项设置';

  @override
  String get configureReminderSwitches => '配置四类提醒开关';

  @override
  String get enableNotificationsFirst => '请先开启通知';

  @override
  String get warningReminder => '即将过期提醒';

  @override
  String get urgentReminder => '紧急提醒';

  @override
  String get oneDayReminder => '到期前 1 天提醒';

  @override
  String get dueDayReminder => '到期当天提醒';

  @override
  String get warningReminderSubtitle => '按“即将过期天数”触发';

  @override
  String get urgentReminderSubtitle => '按“紧急天数”触发';

  @override
  String get daysSuffix => '天';

  @override
  String get thresholdNote => '注：保质期小于紧急天数显示为红色，小于即将过期天数显示为橙色';

  @override
  String get versionLoading => '版本获取中...';

  @override
  String versionPrefix(Object version) {
    return '版本 $version';
  }

  @override
  String get aboutDescriptionLine1 => '一款简洁的物品收纳管理应用';

  @override
  String get aboutDescriptionLine2 => '帮助您管理物品位置和保质期';

  @override
  String get featureTitle => '功能介绍';

  @override
  String get featureItem1 => '• 物品管理（添加、编辑、删除）';

  @override
  String get featureItem2 => '• 位置管理（预设+自定义位置）';

  @override
  String get featureItem3 => '• 保质期追踪（智能状态提醒）';

  @override
  String get featureItem4 => '• 分类筛选';

  @override
  String get featureItem5 => '• 数据统计';

  @override
  String get authorLabel => '作者：Ice Wraith';

  @override
  String get locationUncategorized => '未分类';

  @override
  String get locationFridge => '冰箱';

  @override
  String get locationCabinet => '橱柜';

  @override
  String get locationShelf => '架子';

  @override
  String get locationManagementTitle => '位置管理';

  @override
  String get presetLocation => '预设位置';

  @override
  String get addLocationTitle => '添加位置';

  @override
  String get locationNameLabel => '位置名称';

  @override
  String get deleteLocationTitle => '删除位置';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteItem(Object itemName) {
    return '确定要删除\"$itemName\"吗？';
  }

  @override
  String confirmDeleteItemWithIrreversible(Object itemName) {
    return '确定要删除 $itemName 吗？此操作无法撤销。';
  }

  @override
  String confirmDeleteLocation(Object locationName) {
    return '确定要删除位置\"$locationName\"吗？';
  }

  @override
  String locationHasItems(Object locationName, Object count) {
    return '位置\"$locationName\"下有 $count 个物品。';
  }

  @override
  String get deleteLocationAlsoDeleteItems => '删除该位置将同时删除以下所有物品：';

  @override
  String andMoreItems(Object count) {
    return '...等共 $count 个物品';
  }

  @override
  String deletedLocation(Object locationName) {
    return '已删除位置\"$locationName\"';
  }

  @override
  String deletedLocationAndItems(Object locationName, Object count) {
    return '已删除位置\"$locationName\"及 $count 个物品';
  }

  @override
  String get batchDeleteTitle => '批量删除';

  @override
  String batchDeleteConfirm(Object count) {
    return '确定要删除已选择的 $count 个物品吗？';
  }

  @override
  String batchDeleted(Object count) {
    return '已删除 $count 个物品';
  }

  @override
  String deletedItem(Object itemName) {
    return '$itemName 已删除';
  }

  @override
  String get batchTransferTitle => '批量转移物品';

  @override
  String selectedItemsCount(Object count) {
    return '已选择 $count 个物品';
  }

  @override
  String get targetLocation => '目标位置';

  @override
  String get confirmTransfer => '确认转移';

  @override
  String get noTransferTargetLocation => '没有可转移的目标位置';

  @override
  String transferredItemsToLocation(Object count, Object locationName) {
    return '已转移 $count 个物品到 $locationName';
  }

  @override
  String get itemDetailTitle => '物品详情';

  @override
  String get expirationStatus => '保质期状态';

  @override
  String get itemInfo => '物品信息';

  @override
  String get nameLabel => '名称';

  @override
  String get categoryLabel => '分类';

  @override
  String get storageLocationLabel => '存放位置';

  @override
  String get quantityLabel => '份数';

  @override
  String get expirationDateLabel => '到期日期';

  @override
  String get productionDateLabel => '生产日期';

  @override
  String get shelfLifeLabel => '保质期';

  @override
  String get remainingDaysLabel => '剩余天数';

  @override
  String get remarksLabel => '备注';

  @override
  String get addItemTitle => '添加物品';

  @override
  String get editItemTitle => '编辑物品';

  @override
  String get basicInfo => '基本信息';

  @override
  String get itemNameLabel => '物品名称';

  @override
  String get itemNameRequired => '请输入物品名称';

  @override
  String get quantityRequired => '请输入份数';

  @override
  String get quantityInvalid => '请输入有效的份数';

  @override
  String get selectStorageLocationRequired => '请选择存放位置';

  @override
  String get invalidStorageLocation => '请选择有效的存放位置';

  @override
  String get expirationInfo => '保质期信息';

  @override
  String get useProductionDateAndShelfLife => '使用生产日期+保质期天数';

  @override
  String get productionDate => '生产日期';

  @override
  String get shelfLifeDays => '保质期天数:';

  @override
  String get dayLabel => '天数';

  @override
  String get dueDate => '到期日期';

  @override
  String get remarks => '备注';

  @override
  String get optionalRemarkHint => '添加备注（可选）';

  @override
  String get saveChanges => '保存修改';

  @override
  String get saveFailedRetry => '保存失败，请重试';

  @override
  String get statisticsTitle => '统计';

  @override
  String get categoryStatistics => '分类统计';

  @override
  String get locationStatistics => '位置统计';

  @override
  String get itemOverview => '物品概览';

  @override
  String get totalLabel => '总计';

  @override
  String get freshLabel => '新鲜';

  @override
  String get warningLabel => '即将过期';

  @override
  String get urgentLabel => '紧急';

  @override
  String get expiredLabel => '已过期';

  @override
  String get noItemData => '暂无物品数据';

  @override
  String get noLocationData => '暂无位置数据';

  @override
  String get statusFresh => '新鲜';

  @override
  String get statusWarning => '注意';

  @override
  String get statusUrgent => '紧迫';

  @override
  String get statusExpired => '已过期';

  @override
  String get categoryFood => '食品';

  @override
  String get categoryMedicine => '药品';

  @override
  String get categoryCosmetics => '化妆品';

  @override
  String get categoryDaily => '日用品';

  @override
  String get categoryOther => '其他';

  @override
  String remainingDays(Object days) {
    return '剩余 $days 天';
  }

  @override
  String expiredDays(Object days) {
    return '已过期 $days 天';
  }

  @override
  String get dueToday => '今天到期';

  @override
  String expiredDaysCompact(Object days) {
    return '$days 天（已过期）';
  }

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get warningDialogTitle => '即将过期提醒 (天)';

  @override
  String get urgentDialogTitle => '紧急提醒 (天)';

  @override
  String warningValidation(Object urgentDays) {
    return '即将过期天数必须大于紧急天数（$urgentDays）';
  }

  @override
  String urgentValidation(Object warningDays) {
    return '紧急天数必须小于即将过期天数（$warningDays）';
  }

  @override
  String get notificationChannelName => '保质期提醒';

  @override
  String get notificationChannelDescription => '物品保质期提醒通知';

  @override
  String get notificationWarningTitle => '即将过期提醒';

  @override
  String get notificationUrgentTitle => '紧急提醒';

  @override
  String get notificationDueTitle => '到期提醒';

  @override
  String notificationWarningBody(Object itemName, Object days) {
    return '$itemName 还有$days天就要过期了，请尽快使用！';
  }

  @override
  String notificationUrgentBody(Object itemName, Object days) {
    return '$itemName 还有$days天就要过期了，请尽快使用！';
  }

  @override
  String notificationOneDayBody(Object itemName) {
    return '$itemName 还有1天就要过期了！';
  }

  @override
  String notificationDueBody(Object itemName) {
    return '$itemName 今天到期，请及时处理！';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw(): super('zh_TW');

  @override
  String get appTitle => '收納';

  @override
  String get tabItems => '物品';

  @override
  String get tabLocations => '位置';

  @override
  String get tabStatistics => '統計';

  @override
  String selectionCount(Object count) {
    return '已選擇 $count 項';
  }

  @override
  String get actionSelectAll => '全選';

  @override
  String get actionTransfer => '轉移';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionEdit => '編輯';

  @override
  String get actionAdd => '新增';

  @override
  String get searchItemsHint => '搜尋物品';

  @override
  String get categoryAll => '全部';

  @override
  String get emptyNoItems => '暫無物品';

  @override
  String get emptyTapAddItem => '點擊右上角新增物品';

  @override
  String get emptyNoItemsInLocation => '該位置暫無物品';

  @override
  String get emptyNoLocations => '暫無位置';

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionAppearance => '外觀';

  @override
  String get sectionExpirationReminder => '保質期提醒';

  @override
  String get sectionAbout => '關於';

  @override
  String get theme => '主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get selectTheme => '選擇主題';

  @override
  String get themeUpdated => '主題已更新';

  @override
  String get language => '語言';

  @override
  String get languageFollowSystem => '跟隨系統';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get languageUpdated => '語言已更新';

  @override
  String get notificationEnabled => '啟用通知';

  @override
  String get statusEnabled => '已開啟';

  @override
  String get statusDisabled => '已關閉';

  @override
  String get reminderSettings => '提醒項設定';

  @override
  String get configureReminderSwitches => '設定四類提醒開關';

  @override
  String get enableNotificationsFirst => '請先開啟通知';

  @override
  String get warningReminder => '即將過期提醒';

  @override
  String get urgentReminder => '緊急提醒';

  @override
  String get oneDayReminder => '到期前 1 天提醒';

  @override
  String get dueDayReminder => '到期當天提醒';

  @override
  String get warningReminderSubtitle => '按「即將過期天數」觸發';

  @override
  String get urgentReminderSubtitle => '按「緊急天數」觸發';

  @override
  String get daysSuffix => '天';

  @override
  String get thresholdNote => '註：保質期小於緊急天數顯示為紅色，小於即將過期天數顯示為橙色';

  @override
  String get versionLoading => '版本讀取中...';

  @override
  String versionPrefix(Object version) {
    return '版本 $version';
  }

  @override
  String get aboutDescriptionLine1 => '一款簡潔的物品收納管理應用';

  @override
  String get aboutDescriptionLine2 => '幫助您管理物品位置和保質期';

  @override
  String get featureTitle => '功能介紹';

  @override
  String get featureItem1 => '• 物品管理（新增、編輯、刪除）';

  @override
  String get featureItem2 => '• 位置管理（預設+自訂位置）';

  @override
  String get featureItem3 => '• 保質期追蹤（智慧狀態提醒）';

  @override
  String get featureItem4 => '• 分類篩選';

  @override
  String get featureItem5 => '• 數據統計';

  @override
  String get authorLabel => '作者：Ice Wraith';

  @override
  String get locationUncategorized => '未分類';

  @override
  String get locationFridge => '冰箱';

  @override
  String get locationCabinet => '櫥櫃';

  @override
  String get locationShelf => '架子';

  @override
  String get locationManagementTitle => '位置管理';

  @override
  String get presetLocation => '預設位置';

  @override
  String get addLocationTitle => '新增位置';

  @override
  String get locationNameLabel => '位置名稱';

  @override
  String get deleteLocationTitle => '刪除位置';

  @override
  String get confirmDelete => '確認刪除';

  @override
  String confirmDeleteItem(Object itemName) {
    return '確定要刪除\"$itemName\"嗎？';
  }

  @override
  String confirmDeleteItemWithIrreversible(Object itemName) {
    return '確定要刪除 $itemName 嗎？此操作無法撤銷。';
  }

  @override
  String confirmDeleteLocation(Object locationName) {
    return '確定要刪除位置\"$locationName\"嗎？';
  }

  @override
  String locationHasItems(Object locationName, Object count) {
    return '位置\"$locationName\"下有 $count 個物品。';
  }

  @override
  String get deleteLocationAlsoDeleteItems => '刪除此位置將同時刪除以下所有物品：';

  @override
  String andMoreItems(Object count) {
    return '...等共 $count 個物品';
  }

  @override
  String deletedLocation(Object locationName) {
    return '已刪除位置\"$locationName\"';
  }

  @override
  String deletedLocationAndItems(Object locationName, Object count) {
    return '已刪除位置\"$locationName\"及 $count 個物品';
  }

  @override
  String get batchDeleteTitle => '批量刪除';

  @override
  String batchDeleteConfirm(Object count) {
    return '確定要刪除已選擇的 $count 個物品嗎？';
  }

  @override
  String batchDeleted(Object count) {
    return '已刪除 $count 個物品';
  }

  @override
  String deletedItem(Object itemName) {
    return '$itemName 已刪除';
  }

  @override
  String get batchTransferTitle => '批量轉移物品';

  @override
  String selectedItemsCount(Object count) {
    return '已選擇 $count 個物品';
  }

  @override
  String get targetLocation => '目標位置';

  @override
  String get confirmTransfer => '確認轉移';

  @override
  String get noTransferTargetLocation => '沒有可轉移的目標位置';

  @override
  String transferredItemsToLocation(Object count, Object locationName) {
    return '已轉移 $count 個物品到 $locationName';
  }

  @override
  String get itemDetailTitle => '物品詳情';

  @override
  String get expirationStatus => '保質期狀態';

  @override
  String get itemInfo => '物品資訊';

  @override
  String get nameLabel => '名稱';

  @override
  String get categoryLabel => '分類';

  @override
  String get storageLocationLabel => '存放位置';

  @override
  String get quantityLabel => '份數';

  @override
  String get expirationDateLabel => '到期日期';

  @override
  String get productionDateLabel => '生產日期';

  @override
  String get shelfLifeLabel => '保質期';

  @override
  String get remainingDaysLabel => '剩餘天數';

  @override
  String get remarksLabel => '備註';

  @override
  String get addItemTitle => '新增物品';

  @override
  String get editItemTitle => '編輯物品';

  @override
  String get basicInfo => '基本資訊';

  @override
  String get itemNameLabel => '物品名稱';

  @override
  String get itemNameRequired => '請輸入物品名稱';

  @override
  String get quantityRequired => '請輸入份數';

  @override
  String get quantityInvalid => '請輸入有效的份數';

  @override
  String get selectStorageLocationRequired => '請選擇存放位置';

  @override
  String get invalidStorageLocation => '請選擇有效的存放位置';

  @override
  String get expirationInfo => '保質期資訊';

  @override
  String get useProductionDateAndShelfLife => '使用生產日期+保質期天數';

  @override
  String get productionDate => '生產日期';

  @override
  String get shelfLifeDays => '保質期天數:';

  @override
  String get dayLabel => '天數';

  @override
  String get dueDate => '到期日期';

  @override
  String get remarks => '備註';

  @override
  String get optionalRemarkHint => '新增備註（可選）';

  @override
  String get saveChanges => '保存修改';

  @override
  String get saveFailedRetry => '保存失敗，請重試';

  @override
  String get statisticsTitle => '統計';

  @override
  String get categoryStatistics => '分類統計';

  @override
  String get locationStatistics => '位置統計';

  @override
  String get itemOverview => '物品概覽';

  @override
  String get totalLabel => '總計';

  @override
  String get freshLabel => '新鮮';

  @override
  String get warningLabel => '即將過期';

  @override
  String get urgentLabel => '緊急';

  @override
  String get expiredLabel => '已過期';

  @override
  String get noItemData => '暫無物品數據';

  @override
  String get noLocationData => '暫無位置數據';

  @override
  String get statusFresh => '新鮮';

  @override
  String get statusWarning => '注意';

  @override
  String get statusUrgent => '緊迫';

  @override
  String get statusExpired => '已過期';

  @override
  String get categoryFood => '食品';

  @override
  String get categoryMedicine => '藥品';

  @override
  String get categoryCosmetics => '化妝品';

  @override
  String get categoryDaily => '日用品';

  @override
  String get categoryOther => '其他';

  @override
  String remainingDays(Object days) {
    return '剩餘 $days 天';
  }

  @override
  String expiredDays(Object days) {
    return '已過期 $days 天';
  }

  @override
  String get dueToday => '今天到期';

  @override
  String expiredDaysCompact(Object days) {
    return '$days 天（已過期）';
  }

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get warningDialogTitle => '即將過期提醒 (天)';

  @override
  String get urgentDialogTitle => '緊急提醒 (天)';

  @override
  String warningValidation(Object urgentDays) {
    return '即將過期天數必須大於緊急天數（$urgentDays）';
  }

  @override
  String urgentValidation(Object warningDays) {
    return '緊急天數必須小於即將過期天數（$warningDays）';
  }

  @override
  String get notificationChannelName => '保質期提醒';

  @override
  String get notificationChannelDescription => '物品保質期提醒通知';

  @override
  String get notificationWarningTitle => '即將過期提醒';

  @override
  String get notificationUrgentTitle => '緊急提醒';

  @override
  String get notificationDueTitle => '到期提醒';

  @override
  String notificationWarningBody(Object itemName, Object days) {
    return '$itemName 還有$days天就要過期了，請儘快使用！';
  }

  @override
  String notificationUrgentBody(Object itemName, Object days) {
    return '$itemName 還有$days天就要過期了，請儘快使用！';
  }

  @override
  String notificationOneDayBody(Object itemName) {
    return '$itemName 還有1天就要過期了！';
  }

  @override
  String notificationDueBody(Object itemName) {
    return '$itemName 今天到期，請及時處理！';
  }
}
