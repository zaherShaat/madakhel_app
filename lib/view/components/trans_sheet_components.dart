import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';
import 'package:madakhel_app/view/transactions/add_category_screen.dart';
import 'package:madakhel_app/view_model/category_view_model.dart';
import 'package:provider/provider.dart';

class CategoryField extends StatefulWidget {
  final TransactionCategory? selected;
  final int? initialCategoryId;
  final bool enabled;
  final ValueChanged<TransactionCategory?> onChanged;
  final bool isEdit;

  const CategoryField({
    super.key,
    required this.selected,
    required this.initialCategoryId,
    required this.enabled,
    required this.onChanged,
    this.isEdit = false,
  });

  @override
  State<CategoryField> createState() => _CategoryFieldState();
}

class _CategoryFieldState extends State<CategoryField> {
  TransactionCategory? value;

  // late Future<List<TransactionCategory>> _categoriesFuture;

  // @override
  // void initState() {
  //   super.initState();
  //   _categoriesFuture = _loadCategories();
  // }

  // Future<List<TransactionCategory>> _loadCategories() {
  //   return context.read<CategoryViewModel>().getCategories();
  // }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categories = context.watch<CategoryViewModel>().categories;
    return Builder(
      builder: (context) {
        final TransactionCategory? gottenCat = categories.firstWhereOrNull(
          (cat) => cat.id == widget.initialCategoryId,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نوع المعاملة',
                  style: TextStyle(
                    fontSize: context.scaleSp(12),
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!widget.isEdit)
                  SizedBox(
                    width: context.scaleW(28),
                    height: context.scaleH(28),
                    child: CircleIconButton(
                      onTap: () async {
                        final category =
                            await showModalBottomSheet<TransactionCategory>(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(context.scaleW(16)),
                                ),
                              ),
                              builder: (_) => const AddCategoryScreen(),
                            );
                        if (!context.mounted || category == null) return;
                        setState(() {
                          value = category;
                        });
                        widget.onChanged(category);
                      },
                      icon: Icons.add,
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.scaleH(8)),
            DropdownSearch<TransactionCategory>(
              enabled: widget.enabled,
              items: (filter, loadProps) => categories,
              selectedItem: value,
              itemAsString: (category) => category.name,
              compareFn: (a, b) => a.id == b.id,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                fit: FlexFit.loose,
                constraints: BoxConstraints(maxHeight: context.scaleH(320)),
                searchFieldProps: const TextFieldProps(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ابحث عن نوع المعاملة',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                emptyBuilder: (context, searchEntry) => Padding(
                  padding: EdgeInsets.all(context.scaleW(16)),
                  child: const Text('لا توجد نتائج مطابقة'),
                ),
                // dropdown_search 7.0.0 order: (context, item, isDisabled, isSelected)
                itemBuilder: (context, category, isDisabled, isSelected) {
                  return ListTile(
                    title: Text(category.name),
                    selected: isSelected,
                    selectedTileColor: scheme.primary.withAlpha(20),
                    enabled: !isDisabled,
                  );
                },
              ),
              onSaved: widget.onChanged,
              autoValidateMode: AutovalidateMode.always,
              onSelected: widget.onChanged,
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: !widget.isEdit
                      ? "إختر نوع المعاملة"
                      : gottenCat!.name,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
////////////////

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const AmountField({super.key, required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المبلغ',
          style: TextStyle(
            fontSize: context.scaleSp(12),
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '0.00'),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

////////
class DateField extends StatelessWidget {
  final DateTime selectedDate;
  final bool enabled;
  final ValueChanged<DateTime> onChanged;

  const DateField({
    super.key,
    required this.selectedDate,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: TextStyle(
            fontSize: context.scaleSp(12),
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        InkWell(
          onTap: !enabled
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onChanged(picked);
                },
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: context.scaleW(18),
                  color: scheme.onSurfaceVariant,
                ),
                Text(label),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

////////
class NoteField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const NoteField({super.key, required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات (اختياري)',
          style: TextStyle(
            fontSize: context.scaleSp(12),
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'أضف ملاحظة...'),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

///////////
class MessageBox extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;

  const MessageBox({
    super.key,
    required this.message,
    required this.color,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaleW(12)),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(context.scaleW(8)),
        border: Border.all(color: color.withAlpha(100), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: context.scaleW(20)),
          SizedBox(width: context.scaleW(8)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: context.scaleSp(12), color: color),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: color, size: context.scaleW(16)),
          ),
        ],
      ),
    );
  }
}
