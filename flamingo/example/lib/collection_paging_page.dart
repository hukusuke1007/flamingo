import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CollectionPagingPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<CollectionPagingPage> {
  final ScrollController scrollController = ScrollController();
  final RefreshController refreshController = RefreshController();

  CollectionPaging<User> collectionPaging;

  List<User> items = [];

  @override
  void initState() {
    super.initState();

    /// Using Collection
    collectionPaging = CollectionPaging<User>(
      query: User().collectionRef.orderBy('updatedAt', descending: true),
      limit: 100,
      decode: (snap) => User(snapshot: snap),
    );

    /// Using CollectionGroup
//    collectionPaging = CollectionPaging<User>(
//      query: firestoreInstance
//          .collectionGroup('user')
//          .orderBy('createdAt', descending: true),
//      limit: 20,
//      decode: (snap) =>
//          User(snapshot: snap,
//    );
    initLoad();
  }

  void initLoad() async {
    final _items = await collectionPaging.load();
    setState(() {
      items = _items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Collection Paging Sample'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 24, right: 24),
                child: Text('count: ${items.length}'),
              )
            ],
          ),
          body: SmartRefresher(
            controller: refreshController,
            enablePullDown: true,
            enablePullUp: true,
            header: CustomHeader(
              builder: (context, mode) {
                if (mode == RefreshStatus.idle) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(
                  height: 55,
                  child: Center(child: CupertinoActivityIndicator()),
                );
              },
            ),
            footer: CustomFooter(
              builder: (context, mode) {
                if (mode == LoadStatus.idle) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(
                  height: 55,
                  child: Center(child: CupertinoActivityIndicator()),
                );
              },
            ),
            onRefresh: () async {
              final _items = await collectionPaging.load();
              setState(() {
                items = _items;
              });
              refreshController.refreshCompleted();
            },
            onLoading: () async {
              final _items = await collectionPaging.loadMore();
              setState(() {
                items.addAll(_items);
              });
              refreshController.loadComplete();
            },
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                final data = items[index];
                return ListTile(
                  title: Text(
                    data.id,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    '${index + 1} ${data.name} ${data.createdAt.toDate()}',
                    maxLines: 1,
                  ),
                );
              },
              itemCount: items.length,
            ),
          )),
    );
  }
}
