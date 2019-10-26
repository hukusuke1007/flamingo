import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flamingo/flamingo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo_test.dart';

void main() {
  Flamingo.configure(Firestore.instance.collection('version').document("1"));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final test = FlamingoTest();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Container(
      color: Colors.white,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('Document',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.save();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.amberAccent,
                  onPressed: () async {
                    final id = 'GqnTA8p6lo2ZrjqygnoS';
                    await test.update(id);
                  },
                  child: Text('update', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.black12,
                  onPressed: () async {
                    final id = 'GqnTA8p6lo2ZrjqygnoS';
                    await test.delete(id);
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('Batch',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.batchSave();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
//                RaisedButton(
//                  padding: EdgeInsets.all(4.0),
//                  color: Colors.amberAccent,
//                  onPressed: () async {
//                    final id = 'Q3sR1fi5XjEO2SseHesV';
//                    await test.update(id);
//                  },
//                  child: Text('update', style: TextStyle(color: Colors.white),),
//                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.batchDelete();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('Get',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.get();
                  },
                  child: Text('Get', style: TextStyle(color: Colors.white),),
                ),
//                RaisedButton(
//                  padding: EdgeInsets.all(4.0),
//                  color: Colors.amberAccent,
//                  onPressed: () async {
//                    final id = 'Q3sR1fi5XjEO2SseHesV';
//                    await test.update(id);
//                  },
//                  child: Text('update', style: TextStyle(color: Colors.white),),
//                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await test.getAndUpdate();
                  },
                  child: Text('GetAndUpdate', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.green,
                  onPressed: () async {
                    await test.getCollection();
                  },
                  child: Text('Collection', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('SubCollection',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.green,
                  onPressed: () async {
                    await test.saveCollection();
                  },
                  child: Text('SaveSubCollection', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.cyan,
                  onPressed: () async {
                    await test.getSubCollection();
                  },
                  child: Text('GetSubCollection', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('Storage',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveStorage();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.deleteStorage();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('DistributedCounter',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.distributedCreate();
                  },
                  child: Text('Create', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.distributedIncrement();
                  },
                  child: Text('Increment', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.brown,
                  onPressed: () async {
                    await test.distributedGet();
                  },
                  child: Text('Get', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: Text('Transaction',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.transactionSave();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.amber,
                  onPressed: () async {
                    await test.transactionUpdate();
                  },
                  child: Text('Update', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: EdgeInsets.all(4.0),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.transactionDelete();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
