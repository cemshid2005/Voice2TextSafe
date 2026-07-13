import 'dart:io';

/// Thrown for any user-facing error. [message] is already localized
/// (Azerbaijani) and safe to show directly in the UI.
class AppException implements Exception {
  AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Converts raw exceptions / HTTP status codes into [AppException]s with
/// short, user-friendly Azerbaijani messages. Never includes request/response
/// bodies (which could contain audio text or key fragments) in the message.
class ErrorMapper {
  ErrorMapper._();

  static AppException map(Object error) {
    if (error is AppException) return error;

    if (error is SocketException) {
      return AppException(
        'İnternet bağlantısı tapılmadı. Şəbəkəni yoxlayıb yenidən cəhd edin.',
      );
    }
    if (error is HttpException) {
      return AppException('Şəbəkə xətası baş verdi. Yenidən cəhd edin.');
    }
    if (error is FormatException) {
      return AppException('API-dən gələn cavab oxuna bilmədi.');
    }
    if (error.toString().contains('TimeoutException')) {
      return AppException(
        'Sorğu vaxtı bitdi. Audio fayl çox böyük ola bilər, yenidən cəhd edin.',
      );
    }

    return AppException('Naməlum xəta baş verdi. Yenidən cəhd edin.');
  }

  static AppException fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
        return AppException(
          'API Key yanlışdır və ya səlahiyyəti yoxdur. Ayarlardan API Key-i yoxlayın.',
        );
      case 404:
        return AppException(
          'Seçilmiş model tapılmadı. Ayarlardan başqa provayder seçməyi yoxlayın.',
        );
      case 413:
        return AppException('Audio fayl ölçüsü çox böyükdür.');
      case 429:
        return AppException('Sorğu limiti aşıldı. Bir az sonra yenidən cəhd edin.');
      case 500:
      case 502:
      case 503:
        return AppException(
          'AI provayderin serverində problem yarandı. Bir az sonra yenidən cəhd edin.',
        );
      default:
        return AppException('Sorğu uğursuz oldu (kod $statusCode).');
    }
  }
}
