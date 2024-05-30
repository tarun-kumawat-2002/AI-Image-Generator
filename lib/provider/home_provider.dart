import 'dart:convert';

import 'package:ai_image/Utils/keys.dart';
import 'package:ai_image/Utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lottie/lottie.dart';

class HomeProvider extends ChangeNotifier{
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  bool _isSearching = false;

  List<Map<String, dynamic>> imageUrlList = [];


  bool get isSearching => _isSearching;

  set isSearching(bool value){
    if(value != _isSearching){
      _isSearching = value;
      notifyListeners();
    }
  }

  addImage(String prompt, String url){
    imageUrlList.add({
      'prompt': prompt,
      'url': url,
    });
    notifyListeners();
  }

  clearSearchController(){
    searchController.clear();
    notifyListeners();
  }

  void saveNetworkImage(String url) async {
    showToast('Downloading image...');
    var response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 100,
      name: "ai_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    if(result['isSuccess']){
      showToast('Image downloaded successfully.');
    }else{
      showToast('Image download failed...');
    }
  }

  callGenerateImageApi(BuildContext context) async {
    try{
      String searchText = searchController.text.trim();
      clearSearchController();
      isSearching = true;

      if(imageUrlList.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 100), (){
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.fastOutSlowIn,
          );
        });
      }

      Map<String, dynamic> data = {
        "prompt": searchText,
        "aspect_ratio": "1:1",
      };

      var response = await Dio().postUri(
        Uri.parse('https://api.limewire.com/api/image/generation'),
        data: jsonEncode(data),
        options: Options(
          headers: {
            'Authorization': 'Bearer $limeWireKey',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Api-Version': 'v1',
          },
          responseType: ResponseType.json,
        )
      );

      if(response.statusCode == 200){
        Map<String, dynamic> res = response.data;
        isSearching = false;

        if(res['status'] == 'COMPLETED') {
          addImage(
            searchText,
            res['data'][0]['asset_url'],
          );
          Future.delayed(const Duration(milliseconds: 200), () {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            );
          });
        }else{
          //Inappropriate keywords
          if (context.mounted) showInappropriateDialog(context);
        }
      }else{
        isSearching = false;
        if (context.mounted) showErrorDialog(context);
      }

    } catch(ex){
      isSearching = false;
      if (context.mounted) showErrorDialog(context);
    }
  }


  void showInappropriateDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xff333428),
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: screenWidth * 0.88,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/warning.json',
                  repeat: false,
                  width: screenWidth * 0.43,
                ),
                Text('Oops!', style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: fontSize * 0.08,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),),
                SizedBox(height: screenHeight * 0.01,),

                Text('It looks like your prompt contains some inappropriate words. Please provide a different prompt.', style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: fontSize * 0.041,
                  color: Colors.white,
                ),),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.03,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.14,
                      vertical: screenHeight * 0.011,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      color: const Color(0xffF8C346),
                    ),
                    child: Text('Ok', style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.045,
                    ),),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xff333428),
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: screenWidth * 0.88,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/error.json',
                  repeat: false,
                  width: screenWidth * 0.52,
                ),
                Text('Oops!', style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: fontSize * 0.08,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),),
                SizedBox(height: screenHeight * 0.01,),

                Text('Something went wrong, please try again.', style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: fontSize * 0.042,
                  color: Colors.white,
                ),),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.03,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.14,
                      vertical: screenHeight * 0.011,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      color: const Color(0xffBD0A0A),
                    ),
                    child: Text('Ok', style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.045,
                      // fontWeight: FontWeight.w500,
                    ),),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

}