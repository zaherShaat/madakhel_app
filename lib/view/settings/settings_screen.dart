import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/model/auth_user.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/bottom_nav_bar.dart';
import 'package:madakhel_app/view_model/auth_view_model.dart';
import 'package:madakhel_app/view_model/theme_view_model.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _activeTabIndex = 0; // Settings tab is active

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final authUser = context.watch<AuthUser?>();
    final userName = authUser?.displayName ?? authUser?.email ?? 'اسم المستخدم';
    final userEmail = authUser?.email ?? 'البريد الإلكتروني غير متوفر';
    final userInitials = userName.isNotEmpty
        ? userName
              .trim()
              .split(' ')
              .map((part) => part.characters.first)
              .take(2)
              .join()
        : 'U';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'الإعدادات'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(context.scaleW(16)),
                children: [
                  // Profile section
                  Container(
                    padding: EdgeInsets.symmetric(vertical: context.scaleH(12)),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: scheme.outline.withAlpha(40),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: context.scaleW(44),
                          height: context.scaleW(44),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              userInitials,
                              style: TextStyle(
                                fontSize: context.scaleSp(14),
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.scaleW(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: context.scaleSp(14),
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: context.scaleSp(12),
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.scaleH(16)),
                  // Account section
                  _SectionTitle('الحساب', context),
                  _SettingRow('تعديل الملف الشخصي', context),
                  SizedBox(height: context.scaleH(16)),
                  // Data section
                  _SectionTitle('إدارة البيانات', context),
                  _SettingRow(
                    'إدارة فئات المعاملات',
                    context,
                    onTap: () => context.push('/categories'),
                  ),
                  _SettingRow('تصدير إلى CSV', context),
                  _SettingRow('النسخ الاحتياطي', context, isComingSoon: true),
                  SizedBox(height: context.scaleH(16)),
                  // Appearance section
                  _SectionTitle('المظهر', context),
                  SizedBox(height: context.scaleH(8)),
                  Consumer<ThemeViewModel>(
                    builder: (context, themeViewModel, child) => Wrap(
                      alignment: WrapAlignment.center,
                      spacing: context.scaleW(6),
                      children: AppThemeMode.values.asMap().entries.map((e) {
                        return InkWell(
                          onTap: () async {
                            themeViewModel.setThemeMode(
                              AppThemeMode.values[e.key],
                            );
                          },
                          child: Chip(
                            // isActive: themeViewModel.themeMode.index == e.key,
                            label: Text(e.value.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: context.scaleH(24)),
                  // Logout button
                  Consumer<AuthViewModel>(
                    builder: (context, authProvider, child) => ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AppConfirmActionDialog(
                            title: "أنت على وشك تسجيل الخروج",
                            message: "هل تريد فعلاً تسجيل الخروج",
                            confirmLabel: "تأكيد",
                            cancelLabel: "إلغاء",
                            onConfirm: () async {
                              await authProvider.signOut();
                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                              if (!context.mounted) return;
                              context.go('/start');
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCEBEB),
                        minimumSize: Size(double.infinity, context.scaleH(44)),
                      ),
                      child: Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: const Color(0xFFA32D2D),
                          fontSize: context.scaleSp(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomNavBar(
              activeIndex: _activeTabIndex,
              onTap: (index) {
                setState(() => _activeTabIndex = index);
                if (index == 1) {
                  context.go('/transactions');
                } else if (index == 2) {
                  context.go('/home');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _SectionTitle(String title, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(8)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: context.scaleSp(11),
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.04,
        ),
      ),
    );
  }

  Widget _SettingRow(
    String label,
    BuildContext context, {
    VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.scaleH(12)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: scheme.outline.withAlpha(40), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.scaleSp(13),
                color: scheme.onSurface,
              ),
            ),
            if (isComingSoon)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaleW(8),
                  vertical: context.scaleH(2),
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'قريباً',
                  style: TextStyle(
                    fontSize: context.scaleSp(10),
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: context.scaleSp(12),
                color: scheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
