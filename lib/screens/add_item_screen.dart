import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
import '../models/item.dart';
import '../models/expiration_status_ui.dart';
import '../services/settings_service.dart';
import '../view_models/item_view_model.dart';
import '../view_models/location_view_model.dart';
import '../widgets/limited_text_context_menu.dart';

class AddItemScreen extends StatefulWidget {
  final Item? editingItem;

  const AddItemScreen({super.key, this.editingItem});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _expirationDaysController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  ItemCategory _category = ItemCategory.other;
  String _storageLocationId = '';
  bool _useProductionDate = true;
  DateTime _productionDate = DateTime.now();
  int _expirationDays = 30;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  bool get isEditing => widget.editingItem != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationVM = context.read<LocationViewModel>();
      await locationVM.loadLocations();
      if (widget.editingItem != null) {
        _loadEditingItem(widget.editingItem!, locationVM);
      }
    });
  }

  void _loadEditingItem(Item item, LocationViewModel locationVM) {
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _category = item.category;
    _storageLocationId = item.storageLocationId;
    if (_storageLocationId.isEmpty) {
      final matched = locationVM.locations
          .where((location) => location.name == item.storageLocation)
          .firstOrNull;
      _storageLocationId = matched?.id ?? '';
    }
    _notesController.text = item.notes ?? '';

    if (item.productionDate != null && item.expirationDays != null) {
      _useProductionDate = true;
      _productionDate = item.productionDate!;
      _expirationDays = item.expirationDays!;
      _expirationDaysController.text = _expirationDays.toString();
    } else if (item.expirationDate != null) {
      _useProductionDate = false;
      _expirationDate = item.expirationDate!;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expirationDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get calculatedExpirationDate {
    if (_useProductionDate) {
      return _productionDate.add(Duration(days: _expirationDays));
    } else {
      return _expirationDate;
    }
  }

  int? get calculatedDays {
    final expDate = calculatedExpirationDate;
    if (expDate == null) return null;
    return expDate.difference(DateTime.now()).inDays;
  }

  Color get daysColor {
    final settingsService = context.read<SettingsService>();
    final status = ExpirationStatusFromDays.fromDays(
      calculatedDays,
      warningDays: settingsService.warningDays,
      urgentDays: settingsService.urgentDays,
    );
    return status.color;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editItemTitle : l10n.addItemTitle),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.basicInfo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      contextMenuBuilder: buildLimitedTextContextMenu,
                      decoration: InputDecoration(
                        labelText: l10n.itemNameLabel,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.itemNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      contextMenuBuilder: buildLimitedTextContextMenu,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.quantityLabel,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.quantityRequired;
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity < 1) {
                          return l10n.quantityInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ItemCategory>(
                      key: ValueKey(_category),
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: OutlineInputBorder(),
                      ),
                      items: ItemCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.localizedLabel(l10n)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<LocationViewModel>(
                      builder: (context, locationVM, _) {
                        return DropdownButtonFormField<String>(
                          key: ValueKey(_storageLocationId),
                          initialValue: _storageLocationId.isEmpty
                              ? null
                              : _storageLocationId,
                          decoration: InputDecoration(
                            labelText: l10n.storageLocationLabel,
                            border: OutlineInputBorder(),
                          ),
                          items: locationVM.locations.map((loc) {
                            return DropdownMenuItem(
                              value: loc.id,
                              child: Text(loc.localizedName(l10n)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _storageLocationId = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.selectStorageLocationRequired;
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 保质期信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.expirationInfo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l10n.useProductionDateAndShelfLife),
                      value: _useProductionDate,
                      onChanged: (value) {
                        setState(() {
                          _useProductionDate = value;
                        });
                      },
                    ),
                    if (_useProductionDate) ...[
                      ListTile(
                        title: Text(l10n.productionDate),
                        subtitle: Text(
                          '${_productionDate.year}-${_productionDate.month.toString().padLeft(2, '0')}-${_productionDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _productionDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _productionDate = date;
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(l10n.shelfLifeDays),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _expirationDaysController,
                                contextMenuBuilder: buildLimitedTextContextMenu,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: l10n.dayLabel,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final days = int.tryParse(value);
                                  if (days != null && days > 0) {
                                    setState(() {
                                      _expirationDays = days;
                                    });
                                  }
                                },
                              ),
                            ),
                            Text(' ${l10n.daysSuffix}'),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListTile(
                        title: Text(l10n.dueDate),
                        subtitle: Text(
                          '${_expirationDate.year}-${_expirationDate.month.toString().padLeft(2, '0')}-${_expirationDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _expirationDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _expirationDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 备注
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.remarks,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      contextMenuBuilder: buildLimitedTextContextMenu,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.optionalRemarkHint,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 计算结果
            if (calculatedExpirationDate != null)
              Card(
                color: daysColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.expirationDateLabel),
                          Text(
                            '${calculatedExpirationDate!.year}-${calculatedExpirationDate!.month.toString().padLeft(2, '0')}-${calculatedExpirationDate!.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: daysColor,
                            ),
                          ),
                        ],
                      ),
                      if (calculatedDays != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.remainingDaysLabel),
                            Text(
                              calculatedDays! < 0
                                  ? l10n.expiredDaysCompact(-calculatedDays!)
                                  : l10n.remainingDays(calculatedDays!),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: daysColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // 保存按钮
            ElevatedButton(
              onPressed: _isSaving ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? l10n.saveChanges : l10n.addItemTitle),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final locationVM = context.read<LocationViewModel>();
    final location = locationVM.locations
        .where((item) => item.id == _storageLocationId)
        .firstOrNull;
    if (location == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidStorageLocation)));
      return;
    }

    final item = Item(
      id: widget.editingItem?.id ?? const Uuid().v4(),
      name: _nameController.text,
      category: _category,
      storageLocationId: location.id,
      storageLocation: location.name,
      quantity: quantity,
      productionDate: _useProductionDate ? _productionDate : null,
      expirationDays: _useProductionDate ? _expirationDays : null,
      expirationDate: _useProductionDate ? null : _expirationDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.editingItem?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);

    try {
      final viewModel = context.read<ItemViewModel>();

      if (isEditing) {
        await viewModel.updateItem(item);
      } else {
        await viewModel.addItem(item);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saveFailedRetry)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
