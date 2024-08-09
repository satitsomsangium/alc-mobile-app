import 'dart:convert';

import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/model/check_price_model.dart';
import 'package:alc_mobile_app/model/makro_product_detail_model.dart';
import 'package:alc_mobile_app/model/product_data_model.dart';
import 'package:alc_mobile_app/service/app_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as get_x;

class ApiController extends get_x.GetxController {
  static ApiController get to => get_x.Get.find();

  static ApiController init({String? tag, bool permanent = false}) =>
      get_x.Get.put(ApiController(), tag: tag, permanent: permanent);
  
  static String baseUrl = 'https://search.maknet.siammakro.cloud/search/api/v1/indexes/products/search';

  static Future<dynamic> _post(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? headers,
  }) async {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.headers = headers;

    try {
      Response response = await dio.post(path, data: jsonEncode(data));
      dynamic responseData = response.data;
      return responseData['hits'];
    } on DioException catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static get_x.Rx<CheckPriceResponse> productWithImage = CheckPriceResponse(art: '', dscr: '', price: '', image: []).obs;

  static Future<void> checkPriceWithImages(String article) async {
    Product? firebaseProduct = await FirebaseController.getProduct(article);
    if (firebaseProduct != null) {
      if (AppService.isShowProductImage.value) {
        Map<String, dynamic> payload = {
          "q": firebaseProduct.art,
          "size": 20,
          "filters": {
            "isMakroPro": false,
            "isInStore": true,
            "storeCodes": [
              "30"
            ],
            "isSalesCustomer": false,
            "allowAlcohol": true
          },
          "sortBy": "RELEVANCE",
          "autocorrect": true,
          "page": 1,
          "autocategorise": true,
          "source": "app"
        };
        var response = await _post(
          '', 
          payload,
          headers: {}
        );
        
        List<dynamic> hits = response;
        List<MakroProductDetail> products = hits.map((hit) {
        Map<String, dynamic> document = hit['document'];
          return MakroProductDetail.fromJson(document);
        }).toList();
        for (var product in products) {
          if (firebaseProduct.art == product.makroId 
          || firebaseProduct.dscr == product.title) {
            productWithImage.value = CheckPriceResponse(
              art: firebaseProduct.art.toString(), 
              dscr: firebaseProduct.dscr, 
              price: firebaseProduct.price, 
              image: product.images
            );
          }
        }
      } else {
        productWithImage.value = CheckPriceResponse(
          art: firebaseProduct.art.toString(), 
          dscr: firebaseProduct.dscr, 
          price: firebaseProduct.price,  
          image: []
        );
      }
    } else {
      productWithImage.value = CheckPriceResponse(
        art: '', 
        dscr: '', 
        price: '', 
        image: []
      );
    }
  }

  static List<MakroProductDetail> parseCheckPriceResponse(String responseBody) {
    final parsed = json.decode(responseBody);
    final hits = parsed['hits'] as List<dynamic>;
    return hits.map((hit) => MakroProductDetail.fromJson(hit)).toList();
  }
}

class ApiError implements Exception {
  final DioExceptionType type;
  final String error;

  ApiError({required this.type, required this.error});

  String get code {
    try {
      return json.decode(error)["code"];
    } catch (e) {
      return "";
    }
  }

  String get message => (error.toString());

  @override
  String toString() {
    return 'ApiError(type: $type, error: $error)';
  }
}