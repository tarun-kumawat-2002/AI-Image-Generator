import 'package:ai_image/Utils/size_config.dart';
import 'package:ai_image/provider/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:widget_zoom/widget_zoom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, model, child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color(0xff171911),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.01,),

                  //Heading
                  Text('Generate Images 🚀', style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      fontSize: fontSize * 0.063
                  ),),
                  SizedBox(height: screenHeight * 0.01,),

                  //Images List
                  Expanded(
                    child: model.imageUrlList.isEmpty ?
                    SizedBox(
                      width: screenWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/ai.png', width: screenWidth * 0.35,),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Visibility(
                              visible: model.isSearching,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/run.gif',
                                    width: screenWidth * 0.28,
                                  ),

                                  Text('Generating image, please wait...', style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'poppins',
                                    fontSize: fontSize * 0.042,
                                  ),),
                                  SizedBox(height: screenHeight * 0.02,),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ) :
                    SingleChildScrollView(
                      controller: model.scrollController,
                      child: Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              right: screenWidth * 0.05,
                              top: screenHeight * 0.02,
                            ),
                            shrinkWrap: true,
                            itemCount: model.imageUrlList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                  color: const Color(0xff333428),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(model.imageUrlList[index]['prompt'], style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'poppins',
                                        fontSize: fontSize * 0.042
                                    ),),

                                    SizedBox(height: screenHeight * 0.025),

                                    GestureDetector(
                                      onLongPressStart: (details) async {
                                        final offset = details.globalPosition;
                                        showMenu(
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                            offset.dx,
                                            offset.dy,
                                            MediaQuery.of(context).size.width - offset.dx,
                                            MediaQuery.of(context).size.height - offset.dy,
                                          ),
                                          items: [
                                            PopupMenuItem(
                                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                              height: screenHeight * 0.01,
                                              onTap: () async {
                                                model.saveNetworkImage(model.imageUrlList[index]['url']);
                                              },
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.download, size: screenWidth * 0.047),
                                                  SizedBox(width: screenWidth * 0.01,),
                                                  Text('Download', style: TextStyle(
                                                    fontFamily: 'poppins',
                                                    fontSize: fontSize * 0.04,
                                                  ),),
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                        child: WidgetZoom(
                                          heroAnimationTag: 'tag$index',
                                          zoomWidget: CachedNetworkImage(
                                            imageUrl: model.imageUrlList[index]['url'],

                                            //Placeholder
                                            placeholder: (context, url) {
                                              return SizedBox(
                                                width: screenWidth,
                                                height: screenHeight * 0.3,
                                                child: Shimmer.fromColors(
                                                  baseColor: const Color(0xff171911),
                                                  highlightColor: const Color(0xff333428),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                                      color: const Color(0xff171911),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },

                                            //Error widget
                                            errorWidget: (context, url, error) {
                                              return Container(
                                                width: screenWidth * 0.8,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenHeight * 0.1,
                                                  horizontal: screenWidth * 0.02,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                                  color: const Color(0xff171911),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/image_error.png',
                                                      width: screenWidth * 0.12,
                                                      color: Colors.white.withOpacity(0.9),
                                                    ),

                                                    SizedBox(height: screenHeight * 0.008),

                                                    Text('Unable to load image, please try again.', style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'poppins',
                                                        fontSize: fontSize * 0.04
                                                    ),),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          //Searching Gif
                          Visibility(
                            visible: model.isSearching,
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/run.gif',
                                  width: screenWidth * 0.28,
                                ),

                                Text('Generating image, please wait...', style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'poppins',
                                  fontSize: fontSize * 0.042,
                                ),),
                                SizedBox(height: screenHeight * 0.02,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //Search Box
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: TextField(
                      controller: model.searchController,
                      onChanged: (value) {
                        if(model.searchController.text.length <= 1){
                          if(model.searchController.text == ' '){
                            model.clearSearchController();
                          }
                        }
                      },
                      maxLength: 1800,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: fontSize * 0.043,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());

                        if(model.isSearching){
                          showToast('Please wait for the previous result before searching again.');
                        } else if(model.searchController.text.isEmpty){
                          showToast('Please enter your prompt...');
                        } else{
                          model.callGenerateImageApi(context);
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Enter your prompt...',
                        hintStyle: TextStyle(
                          fontSize: fontSize * 0.043,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                            )
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.02,
                          horizontal: screenWidth * 0.04,
                        ),
                        suffixIconColor: Colors.white,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());

                            if(model.isSearching){
                              showToast('Please wait for the previous result before searching again.');
                            } else if(model.searchController.text.isEmpty){
                              showToast('Please enter your prompt...');
                            } else{
                              model.callGenerateImageApi(context);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01,),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
