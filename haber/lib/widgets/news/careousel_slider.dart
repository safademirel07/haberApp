import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:provider/provider.dart';

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
      Future.microtask(() => {
            news_sites = Provider.of<NewsProvider>(context, listen: false)
                .getSelectedNewsSites(),
            Provider.of<NewsProvider>(context, listen: false)
                .setrequiredToFetchAgain = false,
            Provider.of<NewsProvider>(context, listen: false)
                .fetchSliderNews(news_sites, false)
          });
    }

    print("changed ");
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
    int length = (Provider.of<NewsProvider>(context).getSliderNews() != null)
        ? Provider.of<NewsProvider>(context).getSliderNews().length
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
    } else
      return CarouselSlider(
          options: CarouselOptions(
            onPageChanged: (index, reason) =>
                print("index ne " + index.toString()),
            enableInfiniteScroll: false,
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
          ),
          items: Provider.of<NewsProvider>(context)
              .getSliderNews()
              .map((item) => Container(
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Stack(
                            children: <Widget>[
                              Image.network(item.image,
                                  fit: BoxFit.cover, width: 1000.0),
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
                  ))
              .toList());
  }
}
