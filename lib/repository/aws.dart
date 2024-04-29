import 'package:dio/dio.dart';

final awsHttpClient = Dio(BaseOptions(
  baseUrl: 'http://cloudprod-elb-1744064738.us-east-1.elb.amazonaws.com/',
  contentType: 'application/json',
));
