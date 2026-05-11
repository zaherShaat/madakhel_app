# madakhel_app

A new Flutter project.

Migration notes:
- The project was migrated to the v3 DB model defined in `app_context.md`.
- After pulling these changes, regenerate generated sources with:
	- `flutter pub get`
	- `flutter pub run build_runner build --delete-conflicting-outputs`
- If you don't have Flutter in PATH on CI or locally, run the above from a machine with Flutter installed.
