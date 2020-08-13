import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/News.dart';
import 'package:haber/models/NewsDetails.dart';
import 'package:haber/providers/comment_provider.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CareouselSlider extends StatefulWidget {
  CareouselSlider({Key key}) : super(key: key);

  @override
  _CareouselSliderState createState() => _CareouselSliderState();
}

class _CareouselSliderState extends State<CareouselSlider> {
  List<String> news_sites = List<String>();

  Future<void> refreshNews() {
    news_sites = Provider.of<NewsProvider>(context, listen: false)
        .getSelectedNewsSites();
    return Provider.of<NewsProvider>(context, listen: false).fetchSliderNews(
      news_sites,
      false,
    );
  }

  @override
  void didChangeDependencies() {
    if (Provider.of<NewsProvider>(context, listen: false)
        .requiredToFetchAgain) {
      Future.microtask(() {
        news_sites = Provider.of<NewsProvider>(context, listen: false)
            .getSelectedNewsSites();
        Provider.of<NewsProvider>(context, listen: false)
            .setrequiredToFetchAgain = false;
        Provider.of<NewsProvider>(context, listen: false)
            .fetchSliderNews(news_sites, false);
      });
    }

    super.didChangeDependencies();
  }

  Future<void> loadMoreNews() {
    news_sites = Provider.of<NewsProvider>(context, listen: false)
        .getSelectedNewsSites();

    return Provider.of<NewsProvider>(context, listen: false).fetchSliderNews(
      news_sites,
      true,
    );
  }

  @override
  void initState() {
    Future.microtask(() => {
          news_sites = Provider.of<NewsProvider>(context, listen: false)
              .getSelectedNewsSites(),
          Provider.of<NewsProvider>(context, listen: false).fetchSliderNews(
            news_sites,
            false,
          ),
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading =
        Provider.of<NewsProvider>(context, listen: true).loadingSliderNews;
    if (isLoading == true) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        enabled: true,
        child: CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            autoPlay: false,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
          ),
          items: <Widget>[
            for (int i = 0; i < 3; i++)
              Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          "assets/images/shimmer.jpg",
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              "abc",
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
          ],
        ),
      );
    } else {
      int length =
          (Provider.of<NewsProvider>(context, listen: true).getSliderNews() !=
                  null)
              ? Provider.of<NewsProvider>(context, listen: true)
                  .getSliderNews()
                  .length
              : 0;
      if (length == 0) {
        return Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  "Seçtiğiniz sitelerde Son Dakika haberi bulunamadı.",
                  style: AppTheme.title,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Haber kaynaklarını değiştirmeyi deneyin.",
                  style: AppTheme.subtitle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else {
        List<News> listNews =
            Provider.of<NewsProvider>(context, listen: true).getSliderNews();
        return CarouselSlider(
            options: CarouselOptions(
              onPageChanged: (index, reason) {
                int newsLength =
                    Provider.of<NewsProvider>(context, listen: false)
                        .getSliderNews()
                        .length;
                if (index + 1 == newsLength) {
                  Provider.of<NewsProvider>(context, listen: false)
                      .fetchSliderNews(
                    news_sites,
                    true,
                  );
                }
              },
              enableInfiniteScroll: false,
              autoPlay: false,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: listNews
                .map((item) => InkWell(
                      onTap: () async {
                        var index = listNews.indexOf(item);
                        Navigator.pushNamed(
                          context,
                          "/detail",
                          arguments: NewsDetails(
                              index, true, Constants.newsTypeSlider),
                        );
                      },
                      child: Container(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                                    tag: "type_1" +
                                        item.image +
                                        "_id" +
                                        listNews.indexOf(item).toString(),
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.0,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      imageUrl: item.image,
                                      fit: BoxFit.cover,
                                      width: 1000,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromARGB(200, 0, 0, 0),
                                            Color.fromARGB(0, 0, 0, 0)
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Text(
                                        item.title,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ))
                .toList());
      }
    }
  }
}
