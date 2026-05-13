import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/context_ext.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  String _selectedDirection = 'in'; // 'in' for income, 'out' for expense

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping inside sheet
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.scaleW(16)),
                    topRight: Radius.circular(context.scaleW(16)),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(10),
                        ),
                        child: Container(
                          width: context.scaleW(36),
                          height: context.scaleH(4),
                          decoration: BoxDecoration(
                            color: scheme.outline.withAlpha(100),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(16),
                          vertical: context.scaleH(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'فئة جديدة',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: context.scaleH(16)),
                            // Name field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الاسم',
                                  style: TextStyle(
                                    fontSize: context.scaleSp(11),
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.scaleH(4)),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'مثال: مشتريات',
                                    filled: true,
                                    fillColor: scheme.surfaceContainerHighest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        context.scaleW(8),
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.outline.withAlpha(40),
                                        width: 0.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        context.scaleW(8),
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.outline.withAlpha(40),
                                        width: 0.5,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: context.scaleW(12),
                                      vertical: context.scaleH(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.scaleH(12)),
                            // Direction chips
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الاتجاه',
                                  style: TextStyle(
                                    fontSize: context.scaleSp(11),
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.scaleH(6)),
                                Row(
                                  children: [
                                    FilterChip(
                                      selected: _selectedDirection == 'in',
                                      onSelected: (_) => setState(
                                        () => _selectedDirection = 'in',
                                      ),
                                      label: Text(
                                        '+ دخل',
                                        style: TextStyle(
                                          fontSize: context.scaleSp(12),
                                        ),
                                      ),
                                      backgroundColor:
                                          scheme.surfaceContainerHighest,
                                      selectedColor: scheme.onSurface,
                                      labelStyle: TextStyle(
                                        color: _selectedDirection == 'in'
                                            ? scheme.surface
                                            : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(width: context.scaleW(6)),
                                    FilterChip(
                                      selected: _selectedDirection == 'out',
                                      onSelected: (_) => setState(
                                        () => _selectedDirection = 'out',
                                      ),
                                      label: Text(
                                        '− مصروف',
                                        style: TextStyle(
                                          fontSize: context.scaleSp(12),
                                        ),
                                      ),
                                      backgroundColor:
                                          scheme.surfaceContainerHighest,
                                      selectedColor: scheme.onSurface,
                                      labelStyle: TextStyle(
                                        color: _selectedDirection == 'out'
                                            ? scheme.surface
                                            : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: context.scaleH(12)),
                            // Warning box
                            Container(
                              padding: EdgeInsets.all(context.scaleW(12)),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                border: Border.all(
                                  color: scheme.outline.withAlpha(40),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  context.scaleW(8),
                                ),
                              ),
                              child: Text(
                                '⚠️ لا يمكن تغيير الاتجاه بعد الحفظ لأن الحركات المالية تعتمد عليه.',
                                style: TextStyle(
                                  fontSize: context.scaleSp(11),
                                  color: scheme.onSurfaceVariant,
                                  height: 1.6,
                                ),
                              ),
                            ),
                            SizedBox(height: context.scaleH(16)),
                            // Buttons
                            ElevatedButton(
                              onPressed: () => context.pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme.onSurface,
                                minimumSize: Size(
                                  double.infinity,
                                  context.scaleH(44),
                                ),
                              ),
                              child: Text(
                                'حفظ الفئة',
                                style: TextStyle(
                                  color: scheme.surface,
                                  fontSize: context.scaleSp(13),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: context.scaleH(8)),
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                  double.infinity,
                                  context.scaleH(44),
                                ),
                                side: BorderSide(
                                  color: scheme.outline.withAlpha(60),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: context.scaleSp(13),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: context.scaleH(16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
