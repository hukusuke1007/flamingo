import 'package:flutter/material.dart';
import 'package:flamingo/flamingo.dart';
import 'flamingo_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final firestore = Firestore.instance;
  final root = firestore.collection('version').document('1');
  Flamingo.configure(firestore: firestore, storage: FirebaseStorage.instance, root: root);
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
        body: SingleChildScrollView(
          child: _body(),
        ),
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
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('All',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.all();
                  },
                  child: Text('Start', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
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
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Document Raw',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveRaw();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.amberAccent,
                  onPressed: () async {
                    await test.updateRaw();
                  },
                  child: Text('update', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.deleteRaw();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
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
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Batch Raw',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.batchSaveRaw();
                  },
                  child: Text('Save Raw', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.batchUpdateDeleteRaw();
                  },
                  child: Text('Delete Raw', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Batch Collection',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.batchCollectionCRUD();
                  },
                  child: Text('CRUD', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
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
            Padding(
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
            Padding(
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
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('StorageAndDoc',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveStorageAndDoc();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black12,
                  onPressed: () async {
                    await test.deleteStorageAndDoc();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveAndDeleteStorageDocWithDocumentAccessor();
                  },
                  child: Text('Save empty list.', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
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
            Padding(
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
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('MapSave',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveMap();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('ListSave',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.saveList();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('CheckModalSample',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.checkModelSample();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('ListenerSample',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.listenerSample();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Model',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.model();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Increment',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.incrementTest1();
                  },
                  child: Text('Save 1', style: TextStyle(color: Colors.white),),
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.deepPurple,
                  onPressed: () async {
                    await test.incrementTest2();
                  },
                  child: Text('Save 2', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('ValueZeroTest',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.valueZeroTest();
                  },
                  child: Text('Save 1', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Extend document',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.extendCRUD();
                  },
                  child: Text('CRUD', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Test reference path',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.testReferencePath();
                  },
                  child: Text('CRUD', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Test error check',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.all(4),
                  color: Colors.lightBlue,
                  onPressed: () async {
                    await test.testErrorCheck();
                  },
                  child: Text('Execute', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
