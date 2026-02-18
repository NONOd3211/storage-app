import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/item.dart';
import '../view_models/item_view_model.dart';
import '../view_models/location_view_model.dart';

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
  final _notesController = TextEditingController();

  ItemCategory _category = ItemCategory.other;
  String _storageLocation = '';
  bool _useProductionDate = true;
  DateTime _productionDate = DateTime.now();
  int _expirationDays = 30;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));

  bool get isEditing => widget.editingItem != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationViewModel>().loadLocations();
      if (widget.editingItem != null) {
        _loadEditingItem(widget.editingItem!);
      }
    });
  }

  void _loadEditingItem(Item item) {
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _category = item.category;
    _storageLocation = item.storageLocation;
    _notesController.text = item.notes ?? '';

    if (item.productionDate != null && item.expirationDays != null) {
      _useProductionDate = true;
      _productionDate = item.productionDate!;
      _expirationDays = item.expirationDays!;
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
    final days = calculatedDays;
    if (days == null) return Colors.green;
    if (days < 0) return Colors.red;
    // 使用设置中的阈值
    final urgentDays = settingsService.urgentDays;
    final warningDays = settingsService.warningDays;
    if (days < urgentDays) return Colors.orange;
    if (days < warningDays) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑物品' : '添加物品'),
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
                    const Text(
                      '基本信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '物品名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入物品名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '份数',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入份数';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity < 1) {
                          return '请输入有效的份数';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ItemCategory>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: '分类',
                        border: OutlineInputBorder(),
                      ),
                      items: ItemCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label),
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
                          value: _storageLocation.isEmpty
                              ? null
                              : _storageLocation,
                          decoration: const InputDecoration(
                            labelText: '存放位置',
                            border: OutlineInputBorder(),
                          ),
                          items: locationVM.locations.map((loc) {
                            return DropdownMenuItem(
                              value: loc.name,
                              child: Text(loc.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _storageLocation = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请选择存放位置';
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
                    const Text(
                      '保质期信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('使用生产日期+保质期天数'),
                      value: _useProductionDate,
                      onChanged: (value) {
                        setState(() {
                          _useProductionDate = value;
                        });
                      },
                    ),
                    if (_useProductionDate) ...[
                      ListTile(
                        title: const Text('生产日期'),
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
                            const Text('保质期天数: '),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: _expirationDays.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '天数',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            const Text(' 天'),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListTile(
                        title: const Text('到期日期'),
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
                    const Text(
                      '备注',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '添加备注（可选）',
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
                color: daysColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('到期日期'),
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
                            const Text('剩余天数'),
                            Text(
                              calculatedDays! < 0
                                  ? '${-calculatedDays!} 天（已过期）'
                                  : '$calculatedDays 天',
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
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? '保存修改' : '添加物品'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;

    final item = Item(
      id: widget.editingItem?.id ?? const Uuid().v4(),
      name: _nameController.text,
      category: _category,
      storageLocation: _storageLocation,
      quantity: quantity,
      productionDate: _useProductionDate ? _productionDate : null,
      expirationDays: _useProductionDate ? _expirationDays : null,
      expirationDate: _useProductionDate ? null : _expirationDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.editingItem?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final viewModel = context.read<ItemViewModel>();

    if (isEditing) {
      viewModel.updateItem(item);
    } else {
      viewModel.addItem(item);
    }

    Navigator.pop(context);
  }
}