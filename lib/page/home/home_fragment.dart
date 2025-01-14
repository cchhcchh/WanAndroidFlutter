import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:wanandroidflutter/application.dart';
import 'package:wanandroidflutter/constant/Constants.dart';
import 'package:wanandroidflutter/data/article.dart';
import 'package:wanandroidflutter/data/banner.dart';
import 'package:wanandroidflutter/generated/l10n.dart';
import 'package:wanandroidflutter/http/api.dart';
import 'package:wanandroidflutter/http/http_request.dart';
import 'package:wanandroidflutter/page/drawer/draw_page.dart';
import 'package:wanandroidflutter/page/home/search_fragment.dart';
import 'package:wanandroidflutter/page/webview_page.dart';
import 'package:wanandroidflutter/theme/theme_model.dart';
import 'package:wanandroidflutter/utils/collect_event.dart';
import 'package:wanandroidflutter/utils/common.dart';
import 'package:wanandroidflutter/utils/login_event.dart';
import 'package:wanandroidflutter/utils/loginout_event.dart';
import 'package:wanandroidflutter/widget/animate_provider.dart';
import 'package:wanandroidflutter/widget/article_item.dart';
import 'package:wanandroidflutter/widget/custom_refresh.dart';
import 'package:wanandroidflutter/widget/page_widget.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

/// 首页
class _HomeFragmentState extends State<HomeFragment>
    with AutomaticKeepAliveClientMixin {
  List<Article> articleList = List();
  int currentPage = 0;
  SwiperController _swiperController = SwiperController();
  List<BannerData> bannerList = List();
  ScrollController _scrollController;
  PageStateController _pageStateController;
  bool isShowSearchFab = true;
  bool isShowAppbar = false;
  var appTheme;

  void loadArticleList() async {
    if (currentPage == 0) {
      HttpRequest.getInstance().get(Api.ARTICLE_TOP, successCallBack: (data) {
        _easyRefreshKey.currentState.callRefreshFinish();
        _easyRefreshKey.currentState.callLoadMoreFinish();
        articleList.clear();
        if (data != null) {
          _pageStateController.changeState(PageState.LoadSuccess);
          List responseJson = json.decode(data);
          articleList
              .addAll(responseJson.map((m) => Article.fromJson(m)).toList());
          loadArticleData();
          if (articleList.length == 0) {
            _pageStateController.changeState(PageState.NoData);
          }
        } else {
          _pageStateController.changeState(PageState.LoadFail);
        }
      }, errorCallBack: (code, msg) {});
    } else {
      loadArticleData();
    }
  }

  loadArticleData() async {
    HttpRequest.getInstance().get("${Api.HOME_ARTICLE_LIST}$currentPage/json",
        successCallBack: (data) {
      if (data != null) {
        Map<String, dynamic> dataJson = json.decode(data);
        List responseJson = json.decode(json.encode(dataJson["datas"]));
        print(responseJson.runtimeType);
        setState(() {
          articleList.addAll(
              responseJson.map((m) => new Article.fromJson(m)).toList());
        });
        if (articleList.length == 0) {
          _pageStateController.changeState(PageState.NoData);
        }
      } else {
        _pageStateController.changeState(PageState.LoadFail);
      }
    }, errorCallBack: (code, msg) {});
  }

  loadBanner() async {
    HttpRequest.getInstance().get(Api.BANNER_URL, successCallBack: (data) {
      List responseJson = json.decode(data);
      setState(() {
        bannerList.clear();
        bannerList.addAll(
            responseJson.map((m) => new BannerData.fromJson(m)).toList());
      });
    }, errorCallBack: (code, msg) {});
  }

  @override
  void initState() {
    super.initState();
    loadBanner();
    _pageStateController = PageStateController();
    _swiperController.autoplay = true;
    _scrollController = ScrollController();
    loadArticleList();
    Application.eventBus.on<LoginEvent>().listen((event) {
      _onRefresh(true);
    });
    Application.eventBus.on<LoginOutEvent>().listen((event) {
      _onRefresh(true);
    });
    Application.eventBus.on<LoginEvent>().listen((event) {
      _onRefresh(true);
    });
    Application.eventBus.on<CollectEvent>().listen((event) {
      _onRefresh(true);
    });
    initAnimator();
  }

  @override
  void dispose() {
    _swiperController.stopAutoplay();
    _swiperController.dispose();
    super.dispose();
  }

  void initAnimator() {
    _scrollController.addListener(() {
      if (_scrollController.offset < 200) {
        setState(() {
          isShowSearchFab = true;
          isShowAppbar = false;
        });
      } else if (_scrollController.offset >= 200) {
        setState(() {
          isShowSearchFab = false;
          Future.delayed(Duration(milliseconds: 100), () {
            isShowAppbar = true;
          });
        });
      }
    });
  }

  void _onRefresh(bool up) {
    if (up) {
      loadBanner();
      currentPage = 0;
      loadArticleList();
    } else {
      currentPage++;
      loadArticleList();
    }
  }

  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    appTheme = Provider.of<ThemeModel>(context);
    super.build(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: isShowSearchFab
            ? null
            : AppBar(
                leading: EmptyAnimatedSwitcher(
                    display: isShowAppbar,
                    child: IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () =>
                            _scaffoldKey.currentState.openDrawer())),
                title: EmptyAnimatedSwitcher(
                    display: isShowAppbar, child: Text(S.of(context).tab_home)),
                centerTitle: true,
                backgroundColor: appTheme.themeColor,
                actions: <Widget>[
                  EmptyAnimatedSwitcher(
                      display: isShowAppbar,
                      child: IconButton(
                        padding: EdgeInsets.only(right: 10),
                        icon: Icon(Icons.search),
                        onPressed: () {
                          CommonUtils.push(context, SearchFragment());
                        },
                      ))
                ],
              ),
        body: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: PageWidget(
              controller: _pageStateController,
              reload: () {
                loadArticleList();
              },
              child: CustomRefresh(
                  easyRefreshKey: _easyRefreshKey,
                  onRefresh: () {
                    _onRefresh(true);
                  },
                  loadMore: () {
                    _onRefresh(false);
                  },
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: articleList.length + 1,
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Container(
                                height: 200,
                                child: bannerList.length != 0
                                    ? Swiper(
                                        autoplayDelay: 5000,
                                        controller: _swiperController,
                                        itemHeight: 200,
                                        pagination: pagination(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return new Image.network(
                                            bannerList[index].imagePath,
                                            fit: BoxFit.fill,
                                          );
                                        },
                                        itemCount: bannerList.length,
                                        onTap: (index) {
                                          var item = bannerList[index];
                                          CommonUtils.push(
                                              context,
                                              WebViewPage(
                                                url: item.url,
                                                title: item.title,
                                                id: item.id,
                                                isCollect: false,
                                              ));
                                        },
                                      )
                                    : SizedBox(
                                        width: 0,
                                        height: 0,
                                      ),
                              )
                            : ArticleWidget(articleList[index - 1]);
                      })),
            )),
        floatingActionButton: ScaleAnimatedSwitcher(
            child: isShowSearchFab
                ? FloatingActionButton(
                    heroTag: 'homeFab',
                    key: ValueKey(Icons.search),
                    backgroundColor: appTheme.themeColor.withAlpha(180),
                    child: Icon(Icons.search),
                    onPressed: () {
                      CommonUtils.push(context, SearchFragment());
                    })
                : FloatingActionButton(
                    heroTag: 'homeEmpty',
                    key: ValueKey(Icons.vertical_align_top),
                    backgroundColor: appTheme.themeColor.withAlpha(180),
                    child: Icon(Icons.vertical_align_top),
                    onPressed: () {
                      _scrollController.animateTo(0,
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.linear);
                    })),
        drawer: Drawer(
          child: DrawerPage(),
        ));
  }

  SwiperPagination pagination() => SwiperPagination(
      margin: EdgeInsets.all(0.0),
      builder: SwiperCustomPagination(
          builder: (BuildContext context, SwiperPluginConfig config) {
        return Container(
          color: Color(0x599E9E9E),
          height: 40,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            children: <Widget>[
              Text(
                "${bannerList[config.activeIndex].title}",
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
              Expanded(
                flex: 1,
                child: new Align(
                  alignment: Alignment.centerRight,
                  child: new DotSwiperPaginationBuilder(
                          color: Colors.black12,
                          activeColor: appTheme.themeColor,
                          size: 6.0,
                          activeSize: 6.0)
                      .build(context, config),
                ),
              )
            ],
          ),
        );
      }));

  /// with AutomaticKeepAliveClientMixin 切换Tabhou保留Tab状态，避免instance方法重复调用
  @override
  bool get wantKeepAlive => true;
}
