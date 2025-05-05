import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../../app/app_sp.dart';
import '../../app/app_sp_key.dart';
import '../../app/app_utils.dart';
import '../../constants/app_api.dart';
import '../../constants/app_constants.dart';
import '../../models/resource/resource_model.dart';
import '../../models/resource/resource_picker_model.dart';
import '../../models/response/response_result.dart';
import '../../models/user/user.dart';

class ResourceRequest {
  final Dio dio = Dio();

  Future<List<ResourceModel>> getFilesFromDirectoryResource() async {
    FormData formData = getNameDirFormData();

    try {
      final response = await dio.post(
        '${Api.hostApi}${Api.getFilesFromDirectoryResource}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);
      List<dynamic> list = responseData['file_list'];

      List<ResourceModel> listFiles =
          list.map((e) => ResourceModel.fromJson(e)).toList();
      return listFiles.where((resource) {
        return !RegExp(r'\.part\d+$').hasMatch(resource.path ?? '');
      }).toList();
    } catch (_) {}

    return [];
  }

  Future<ResponseResult<ResourceModel?>> uploadFile(
      ResourcePickerModel fileModel, Function(double) onProgress) async {
    if (fileModel.file == null) {
      return ResponseResult.error(
          'File không hợp lệ, vui lòng chọn kiểm tra lại');
    }

    dynamic error;
    String? msg;

    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      File file = File(fileModel.file!.path);
      String fileName = basename(fileModel.fileNameReplace ?? file.path);
      String? mimeType = lookupMimeType(file.path);
      int fileLength = await file.length();
      int maxLengthUpload = 200 * 1024 * 1024;
      if (mimeType == null) {
        return ResponseResult.error(
            'File không hợp lệ, vui lòng chọn kiểm tra lại');
      }

      List<String> mimeTypeParts = mimeType.split('/');
      fileModel.cancelToken = CancelToken();
      Map<String, dynamic>? finalResponse;

      if (fileLength > maxLengthUpload) {
        const int chunkSize = 100 * 1024 * 1024;
        int totalSent = 0;
        int totalChunks = (fileLength / chunkSize).ceil();

        for (int i = 0; i < totalChunks; i++) {
          if (fileModel.cancelToken == null) break;

          int start = i * chunkSize;
          int end = (start + chunkSize) > fileLength
              ? fileLength
              : (start + chunkSize);
          int totalSize = 0;

          FormData formData = FormData.fromMap({
            'name_dir': currentUser.customerToken,
            'fileupload': MultipartFile.fromStream(
              () => file.openRead(start, end),
              end - start,
              filename: fileName,
              contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
            ),
            'filename': fileName,
            'chunk_index': i + 1,
            'total_chunks': totalChunks,
            'customer_id': currentUser.customerId,
          });

          Response response = await dio.post(
            '${Api.hostApi}${Api.uploadLargeFileToDirectoryResource}',
            data: formData,
            cancelToken: fileModel.cancelToken,
            onSendProgress: (int sent, int total) {
              totalSize = total;
              double progress = ((totalSent + sent) / fileLength);
              onProgress(progress);
            },
          );

          totalSent += totalSize;
          Map<String, dynamic> responseData = jsonDecode(response.data);

          if (!(responseData['status'] == true ||
              responseData['status'] == AppConstants.statusSuccess)) {
            msg = responseData['msg'];
            break;
          }

          if (responseData.containsKey('path_file')) {
            finalResponse = responseData;
          }
        }

        if (finalResponse != null) {
          final dynamic fileJson = finalResponse['path_file'];
          ResourceModel resource = ResourceModel.fromJson(fileJson);

          return ResponseResult.success(resource);
        }
      } else {
        FormData formData = FormData.fromMap({
          'name_dir': currentUser.customerToken,
          'fileupload': await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
          ),
          'customer_id': currentUser.customerId,
        });

        Response response = await dio.post(
          '${Api.hostApi}${Api.uploadFileToDirectoryResource}',
          data: formData,
          cancelToken: fileModel.cancelToken,
          onSendProgress: (int sent, int total) {
            double progress = sent / total;
            onProgress(progress);
          },
        );

        final responseData = jsonDecode(response.data);
        if (responseData['status'] == true ||
            responseData['status'] == AppConstants.statusSuccess) {
          final dynamic fileJson = responseData['path_file'];
          ResourceModel resource = ResourceModel.fromJson(fileJson);

          return ResponseResult.success(resource);
        }

        msg = responseData['msg'];
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.cancel) {
        return ResponseResult.success(null);
      }
      error = e;
    } catch (e) {
      error = e;
    }

    if (msg != null) {
      return ResultError(msg);
    } else {
      return getErrorFromException(error: error);
    }
  }

  Future<bool> createDirectory() async {
    FormData formData = getNameDirFormData();

    try {
      final response = await dio.post(
        '${Api.hostApi}${Api.createDirectoryResource}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] || responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<bool> checkDirectoryExist() async {
    FormData formData = getNameDirFormData();

    try {
      final response = await dio.post(
        '${Api.hostApi}${Api.checkDirectoryResourceExist}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return responseData['status'] == 1;
    } catch (_) {}

    return false;
  }

  Future<ResponseResult<bool>> cancelUploadResource(String fileName) async {
    dynamic error;

    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final formData = FormData.fromMap({
        'name_dir': currentUser.customerToken,
        'filename': fileName,
      });

      final response = await dio.post(
        '${Api.hostApi}${Api.cancelUploadResource}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return ResponseResult.success(responseData['status'] == 1);
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<ResponseResult<bool>> deleteFileFromDirectoryResource(
      String fileName) async {
    dynamic error;

    try {
      final User currentUser =
          User.fromJson(jsonDecode(AppSP.get(AppSPKey.userInfo)));
      final formData = FormData.fromMap({
        'name_dir': currentUser.customerToken,
        'name_file': fileName,
      });

      final response = await dio.post(
        '${Api.hostApi}${Api.deleteFileFromDirectoryResource}',
        data: formData,
      );

      final responseData = jsonDecode(response.data);

      return ResponseResult.success(responseData['status']);
    } catch (e) {
      error = e;
    }

    return getErrorFromException(error: error);
  }

  Future<int> getSizeOfDirectoryResource() async {
    FormData formData = getNameDirFormData();

    try {
      final response = await dio.post(
        '${Api.hostApi}${Api.getSizeDirectoryResource}',
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );

      final responseData = jsonDecode(response.data);

      String total = responseData['totalsize'] ?? '0';

      return int.parse(total);
    } catch (_) {}

    return 0;
  }

  Future<int> getSizeOfFileResource(String url) async {
    try {
      int fileSize = 0;
      final response = await Dio().head(url);
      if (response.headers.map.containsKey('content-length')) {
        final fi = response.headers.value('content-length') ?? '0';
        fileSize = int.parse(fi);
      }

      return fileSize;
    } catch (_) {}

    return 0;
  }

  FormData getNameDirFormData() {
    String userInfo = AppSP.get(AppSPKey.userInfo);
    final userJson = jsonDecode(userInfo);
    User currentUser = User.fromJson(userJson);

    return FormData.fromMap({
      'name_dir': currentUser.customerToken,
    });
  }
}
