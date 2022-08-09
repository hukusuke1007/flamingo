import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class CollectionPagingListenerPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<CollectionPagingListenerPage> {
  final ScrollController scrollController = ScrollController();
  final RefreshController refreshController = RefreshController();

  late CollectionPagingListener<User> collectionPagingListener;

  List<User> items = [];

  @override
  void dispose() async {
    super.dispose();
    await collectionPagingListener.dispose();
  }

  @override
  void initState() {
    super.initState();

    collectionPagingListener = CollectionPagingListener<User>(
      query: User().collectionRef.orderBy('updatedAt', descending: true),
      initialLimit: 20,
      pagingLimit: 20,
      decode: (snap) => User(snapshot: snap),
    )
      ..fetch()
      ..data.listen((event) {
        setState(() {
          items = event;
        });
      });

    collectionPagingListener.docChanges.listen((event) {
      for (var item in event) {
        final change = item.docChange;
        print(
            'id: ${item.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Collection Paging Listener Sample'),
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
          onRefresh: () {
            refreshController.refreshCompleted();
          },
          onLoading: () {
            collectionPagingListener.loadMore();
            refreshController.loadComplete();
          },
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              final data = items[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        final documentAccessor = DocumentAccessor();
                        await documentAccessor.delete(data);
                      },
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    data.id,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    '${index + 1} ${data.name} ${data.updatedAt?.toDate()}',
                    maxLines: 1,
                  ),
                  onTap: () async {
                    data.name = Helper.randomString();
                    final documentAccessor = DocumentAccessor();
                    await documentAccessor.update(data);
                  },
                ),
              );
            },
            itemCount: items.length,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final item = User()..name = Helper.randomString(length: 5);
            final documentAccessor = DocumentAccessor();
            await documentAccessor.save(item);
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
