import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:wanandroidflutter/data/article.dart';
import 'package:wanandroidflutter/http/http_request.dart';
import 'package:wanandroidflutter/http/api.dart';
import 'package:wanandroidflutter/widget/custom_refresh.dart';
import 'package:wanandroidflutter/widget/page_widget.dart';
import 'package:wanandroidflutter/widget/project_item.dart';

class ProjectListFragment extends StatefulWidget {
  int _Id;

  ProjectListFragment(this._Id);

  @override
  State<StatefulWidget> createState() {
    return ProjectListFragmentState(_Id);
  }
}

class ProjectListFragmentState extends State<ProjectListFragment>
    with AutomaticKeepAliveClientMixin {
  int _Id;
  int currentPage = 1;
  List<Article> projectArticleList = List();

  ProjectListFragmentState(this._Id);

  ScrollController _scrollController;
  PageStateController _pageStateController;

  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();

  @override
  void initState() {
    super.initState();
    _pageStateController = PageStateController();
    _scrollController = ScrollController();
    loadprojectArticleList();
  }

  void loadprojectArticleList() async {
    HttpRequest.getInstance()
        .get("${Api.PROJECT_LIST}$currentPage/json?cid=$_Id",
            successCallBack: (data) {
      if (currentPage == 1) {
        projectArticleList.clear();
      }
      _easyRefreshKey.currentState.callRefreshFinish();
      _easyRefreshKey.currentState.callLoadMoreFinish();
      if (data != null) {
        _pageStateController.changeState(PageState.LoadSuccess);
        Map<String, dynamic> dataJson = json.decode(data);
        List responseJson = json.decode(json.encode(dataJson["datas"]));
        print(responseJson);
        setState(() {
          projectArticleList
              .addAll(responseJson.map((m) => Article.fromJson(m)).toList());
        });
      }
    }, errorCallBack: (code, msg) {});
  }

  void _onRefresh(bool up) {
    if (up) {
      currentPage = 1;
      loadprojectArticleList();
    } else {
      currentPage++;
      loadprojectArticleList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageWidget(
        controller: _pageStateController,
        reload: () {
          loadprojectArticleList();
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
                itemCount: projectArticleList.length,
                itemBuilder: (context, index) {
                  return ProjectArticleWidget(projectArticleList[index]);
                })),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red.withAlpha(180),
          child: Icon(Icons.arrow_upward),
          onPressed: () {
            _scrollController.animateTo(0,
                duration: Duration(milliseconds: 1000), curve: Curves.linear);
          }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
