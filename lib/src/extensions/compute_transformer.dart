import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ComputeTransformer extends DefaultTransformer {
  ComputeTransformer()
      : super(jsonDecodeCallback: (value) {
          return compute(jsonDecode, value);
        });
}
