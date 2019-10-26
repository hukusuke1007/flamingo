import 'package:flutter/material.dart';
import 'package:flamingo/flamingo.dart';
import 'flamingo_test.dart';

void main() {
  Flamingo.configure(rootName: 'version', version: 1);
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
          title: const Text('Flamingo sample app'),
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
              padding: const EdgeInsets.all(4),
              child: Text('Document',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.save();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.amberAccent,
                  onPressed: () async {
                    await test.update();
                  },
                  child: Text('update', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.delete();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Text('Batch',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.batchSave();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.batchUpdateDelete();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Text('Get',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await test.getAndUpdate();
                  },
                  child: Text('GetAndUpdate', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.green,
                  onPressed: () async {
                    await test.getCollection();
                  },
                  child: Text('Collection', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Text('SubCollection',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.green,
                  onPressed: () async {
                    await test.subCollection();
                  },
                  child: Text('SubCollection', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Text('Storage',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveStorage();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.deleteStorage();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Text('DistributedCounter',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.distributedCounter();
                  },
                  child: Text('CreateIncrementGet', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              child: Text('Transaction',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.transactionSave();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.amber,
                  onPressed: () async {
                    await test.transactionUpdate();
                  },
                  child: Text('Update', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
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
