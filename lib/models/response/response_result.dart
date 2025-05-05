import 'package:dio/dio.dart';

abstract class ResponseResult<T> {
  const ResponseResult();

  factory ResponseResult.success(T value) = ResultSuccess<T>;

  factory ResponseResult.error(String message) = ResultError;
}

class ResultSuccess<T> extends ResponseResult<T> {
  final T value;

  ResultSuccess(this.value);
}

class ResultError extends ResponseResult<Never> {
  final String message;

  ResultError(this.message);
}

ResponseResult<T> getErrorFromException<T>({dynamic error}) {
  if (error == null) {
    return ResponseResult.error(
      'Thao tác không thành công, vui lòng thử lại sau',
    );
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ResponseResult.error(
          'Kết nối có vấn đề, vui lòng kiểm tra lại kết nối của bạn',
        );
      case DioExceptionType.badResponse:
        return ResponseResult.error(
          'Đã có lỗi xảy ra từ máy chủ, vui lòng thử lại sau',
        );
      default:
        break;
    }
  }
  return ResponseResult.error(
    'Có lỗi không xác định xảy ra, vui lòng thử lại sau',
  );
}