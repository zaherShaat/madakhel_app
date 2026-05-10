/// Generic async state wrapper
sealed class AppState<T> {
  const AppState();
}

class IdleState<T> extends AppState<T> {
  const IdleState();
}

class LoadingState<T> extends AppState<T> {
  const LoadingState();
}

class SuccessState<T> extends AppState<T> {
  const SuccessState(this.data);
  final T data;
}

class ErrorState<T> extends AppState<T> {
  const ErrorState(this.message);
  final String message;
}