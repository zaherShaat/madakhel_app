import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/model/auth_user.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/components/app_primary_button.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/bottom_nav_bar.dart';
import 'package:madakhel_app/view_model/auth_view_model.dart';
import 'package:madakhel_app/view_model/backup_view_model.dart';
import 'package:madakhel_app/view_model/theme_view_model.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _activeTabIndex = 0; // Settings tab is active
  // State moved to BackupViewModel

  Future<void> _backupNow() async {
    final vm = context.read<BackupViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await vm.backup();
      messenger.showSnackBar(
        const SnackBar(content: Text('اكتمل النسخ الاحتياطي بنجاح.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _restoreBackup() async {
    final backupVm = context.read<BackupViewModel>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    BackupSnapshot snapshot;

    try {
      snapshot = await backupVm.downloadBackupSnapshot();
    } catch (e) {
      debugPrint('Restore backup download error: $e');
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }

    if (!mounted) return;
    final approvedReplacement = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppConfirmActionDialog(
        title: 'Restore backup',
        message:
            'Backup downloaded: ${snapshot.incomeSources.length} sources, ${snapshot.categories.length} categories, ${snapshot.transactions.length} transactions. Replace current local data with this backup?',
        confirmLabel: 'Replace',
        cancelLabel: 'Cancel',
        isDanger: true,
        onConfirm: () async {
          Navigator.pop(dialogContext, true);
        },
      ),
    );

    if (approvedReplacement != true) return;
    try {
      await backupVm.replaceWithSnapshot(snapshot);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Backup restored successfully.')),
      );
    } catch (e) {
      debugPrint('Restore backup error: $e');
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

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
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.scaleW(18)),
                      child: Row(
                        children: [
                          Container(
                            width: context.scaleW(56),
                            height: context.scaleW(56),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                userInitials,
                                style: TextStyle(
                                  fontSize: context.scaleSp(18),
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.scaleW(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: context.scaleSp(16),
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: context.scaleH(6)),
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
                  ),
                  SizedBox(height: context.scaleH(20)),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.scaleW(18)),
                          child: _SectionTitle('الحساب', context),
                        ),
                        const Divider(height: 0),
                        _SettingRow('تعديل الملف الشخصي', context),
                      ],
                    ),
                  ),
                  SizedBox(height: context.scaleH(20)),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.scaleW(18)),
                          child: _SectionTitle('إدارة البيانات', context),
                        ),
                        const Divider(height: 0),
                        _SettingRow(
                          'إدارة فئات المعاملات',
                          context,
                          onTap: () => context.push('/categories'),
                        ),
                        Consumer<BackupViewModel>(
                          builder: (context, vm, child) => Column(
                            children: [
                              _SettingRow(
                                vm.isBackingUp
                                    ? 'جارٍ إجراء النسخ الاحتياطي...'
                                    : 'النسخ الاحتياطي',
                                context,
                                onTap: vm.isBackingUp ? null : _backupNow,
                              ),
                              _SettingRow(
                                vm.isRestoring
                                    ? 'جارٍ استعادة النسخة الاحتياطية...'
                                    : 'استعادة النسخة الاحتياطية',
                                context,
                                onTap: vm.isRestoring ? null : _restoreBackup,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.scaleH(20)),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.scaleW(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle('المظهر', context),
                          SizedBox(height: context.scaleH(8)),
                          Consumer<ThemeViewModel>(
                            builder: (context, themeViewModel, child) => Wrap(
                              alignment: WrapAlignment.center,
                              spacing: context.scaleW(8),
                              runSpacing: context.scaleH(8),
                              children: AppThemeMode.values.asMap().entries.map(
                                (e) {
                                  final isSelected =
                                      themeViewModel.mode.index == e.key;
                                  return ChoiceChip(
                                    selected: isSelected,
                                    label: Text(
                                      e.value.name == "system"
                                          ? "إعدادات النظام"
                                          : e.value.name == "light"
                                          ? "فاتح"
                                          : "داكن",
                                    ),
                                    selectedColor: scheme.primary,
                                    backgroundColor:
                                        scheme.surfaceContainerHighest,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? scheme.onPrimary
                                          : scheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    onSelected: (_) {
                                      themeViewModel.setThemeMode(
                                        AppThemeMode.values[e.key],
                                      );
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(24)),
                  Consumer<AuthViewModel>(
                    builder: (context, authProvider, child) => AppPrimaryButton(
                      label: 'تسجيل الخروج',
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AppConfirmActionDialog(
                            title: "أنت على وشك تسجيل الخروج",
                            message: "هل تريد فعلاً تسجيل الخروج؟",
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.scaleH(12)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: scheme.outline.withAlpha(40), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: context.scaleW(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.scaleSp(13),
                color: scheme.onSurface,
              ),
            ),
            Spacer(),
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
            SizedBox(width: context.scaleW(8)),
          ],
        ),
      ),
    );
  }
}
