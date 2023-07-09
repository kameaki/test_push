import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChannels.lifecycle.setMessageHandler(_change);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

  Future<String?> _change(String? msg) async {
    if (msg == AppLifecycleState.resumed.toString()) {
      print("##########");
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  static const MethodChannel _channel = MethodChannel('test');

  static Future<dynamic> get _list async {
    final Map params = <String, dynamic>{
      'name': 'my name is hoge',
      'age': 25,
    };
    final List<dynamic> list = await _channel.invokeMethod('startPush', params);
    return list;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _list.then((value) => print(value));
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callMe':
        debugPrint('call callMe : arguments = ${call.arguments}');
        return Future.value('called from platform!');
      default:
        print('Unknowm method ${call.method}');
        throw MissingPluginException();
    }
  }

  @override
  initState() {
    super.initState();
    _channel.setMethodCallHandler(_platformCallHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
