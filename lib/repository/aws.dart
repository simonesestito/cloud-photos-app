import 'package:dio/dio.dart';

final awsHttpClient = Dio(BaseOptions(
  baseUrl: 'http://54.196.227.223',
  contentType: 'application/json',
));
