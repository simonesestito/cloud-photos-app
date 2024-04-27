import 'package:dio/dio.dart';

final awsHttpClient = Dio(BaseOptions(
  baseUrl: 'http://54.221.3.189',
  contentType: 'application/json',
));
