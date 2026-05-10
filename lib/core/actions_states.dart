/// For actions that don't return data (create, update, delete)
sealed class ActionState {
  const ActionState();
}

class ActionIdle extends ActionState {
  const ActionIdle();
}

class ActionLoading extends ActionState {
  const ActionLoading();
}

class ActionSuccess extends ActionState {
  const ActionSuccess({this.message});
  final String? message;
}

class ActionError extends ActionState {
  const ActionError(this.message);
  final String message;
}