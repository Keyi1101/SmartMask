import 'package:flutter/material.dart';
import 'package:test_app/model/product.dart';
import 'LocalNotificationManager.dart';
import 'model/create_item.dart';
import 'model/get_list.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'model/fastp.dart';
import 'model/create_item_fast.dart';
import 'model/get_stress.dart';

class testNotificationScreen extends StatefulWidget {
  const testNotificationScreen({Key key}) : super(key: key);

  @override
  _FirstScreen createState() => _FirstScreen();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _FirstScreen extends State<testNotificationScreen> {
  static final clientID = 0;
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  String _messageBuffer = '';
  List<_Message> messages = List<_Message>();

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.orangeAccent,
    'offBorderColor': Colors.blueAccent,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localNotificationManager.setOnNotificationReceive(onNotificationReceive);
    localNotificationManager.setOnNotificationClick(onNotificationClick);

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('Notification Received:${notification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload ');
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          show('Device connected');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(_onDataReceived).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Text> list = messages.map((_message) {
      return Text(
        (text) {
          return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
        }(_message.text.trim()),
        style: TextStyle(color: Colors.black),
      );
    }).toList();

    

    (list.length == 0 || list.last.data.length < 5)
        ? print('nothing to upload')
        : fastproduct.fromJson(jsonDecode(list.last.data)).mode == 'fast'
            ? createItemfast(fastproduct.fromJson(jsonDecode(list.last.data)))
            : print('uploading the list');

    (list.length == 0 || list.last.data.length < 5)
        ? print('nothing to upload')
        : createItem(Product(
            heartrate: Product.fromJson(jsonDecode(list.last.data)).heartrate,
            temperature:
                Product.fromJson(jsonDecode(list.last.data)).temperature,
            movement: Product.fromJson(jsonDecode(list.last.data)).movement,
            oxygenconc: Product.fromJson(jsonDecode(list.last.data)).oxygenconc,
            rr: Product.fromJson(jsonDecode(list.last.data)).rr,
            tim: (int.parse(Product.fromJson(jsonDecode(list.last.data)).tim) +
                    948693600)
                .toString(),
          ));
    //inside should be the list.last
    //(list.length == 0 || list.last.data.length < 5) ? print('nothing to upload') :  createItem(Product.fromJson(jsonDecode(list.last.data)));
    list.length > 5000
        ? list.clear()
        : print('list growing'); //prevent too many element stored in the list

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Data',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xff4B4B87),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            tabs: <Widget>[
              Tab(text: 'Real-Time'),
              Tab(text: 'mode'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style: TextStyle(fontSize: 12.0)),
                            Text(
                              'Heartrate               ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: Text(
                                list.length == 0 || list.last.data.length < 5
                                    ? 'Please'
                                    : Product.fromJson(
                                            jsonDecode(list.last.data))
                                        .heartrate,
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15.0, left: 80),
                              child: Text(
                                'bpm',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ]),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.pinkAccent,
                          ),
                        ),
                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style: TextStyle(fontSize: 12.0)),
                            Text(
                              'Temperature          ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: Text(
                                list.length == 0 || list.last.data.length < 5
                                    ? 'connect'
                                    : Product.fromJson(
                                            jsonDecode(list.last.data))
                                        .temperature,
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15.0, left: 95),
                              child: Text(
                                '°C',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ]),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Color(0xff7A54FF),
                          ),
                        ),
                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style: TextStyle(fontSize: 12.0)),
                            Text(
                              'Movement status ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: Text(
                                list.length == 0 || list.last.data.length < 5
                                    ? 'the'
                                    : (int.parse(Product.fromJson(
                                                    jsonDecode(list.last.data))
                                                .movement) <
                                            50
                                        ? 'still'
                                        : int.parse(Product.fromJson(jsonDecode(
                                                        list.last.data))
                                                    .movement) <
                                                1000
                                            ? 'walk'
                                            : 'run'),
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Color(0xffFF8F61),
                          ),
                        ),
                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style: TextStyle(fontSize: 12.0)),
                            Text(
                              'Blood Oxygen Conc.',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: Text(
                                list.length == 0 || list.last.data.length < 5
                                    ? 'Mask'
                                    : Product.fromJson(
                                            jsonDecode(list.last.data))
                                        .oxygenconc,
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15.0, left: 95),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ]),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Color(0xff2AC3FF),
                          ),
                        ),
                        buildGridCard(
                          title: "Battery",
                          color: Colors.greenAccent,
                          lable1: '100',
                          lable2: '%',
                        ),
                        Container(
                          child: RouteButtonToGrafana(),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                                future: getstress(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  return 
                                  snapshot.data.length == 0 ? 'getting from cloud':
                                  Text('stress level:'+
                                    snapshot
                                        .data[snapshot.data.length - 1].stress,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  );
                                }),
                  
                ],
              ),
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Visibility(
                    visible: _isButtonUnavailable &&
                        _bluetoothState == BluetoothState.STATE_ON,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.yellow,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Enable Bluetooth',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Switch(
                          value: _bluetoothState.isEnabled,
                          onChanged: (bool value) {
                            future() async {
                              if (value) {
                                await FlutterBluetoothSerial.instance
                                    .requestEnable();
                              } else {
                                await FlutterBluetoothSerial.instance
                                    .requestDisable();
                              }

                              await getPairedDevices();
                              _isButtonUnavailable = false;

                              if (_connected) {
                                _disconnect();
                              }
                            }

                            future().then((_) {
                              setState(() {});
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              "DEVICES",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.blue),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Device:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownButton(
                                  items: _getDeviceItems(),
                                  onChanged: (value) =>
                                      setState(() => _device = value),
                                  value:
                                      _devicesList.isNotEmpty ? _device : null,
                                ),
                                RaisedButton(
                                  onPressed: _isButtonUnavailable
                                      ? null
                                      : _connected
                                          ? _disconnect
                                          : _connect,
                                  child: Text(
                                      _connected ? 'Disconnect' : 'Connect'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                side: new BorderSide(
                                  color: _deviceState == 0
                                      ? colors['neutralBorderColor']
                                      : _deviceState == 1
                                          ? colors['onBorderColor']
                                          : colors['offBorderColor'],
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              elevation: _deviceState == 0 ? 4 : 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Perference",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: _deviceState == 0
                                              ? colors['neutralTextColor']
                                              : _deviceState == 1
                                                  ? colors['onTextColor']
                                                  : colors['offTextColor'],
                                        ),
                                      ),
                                    ),
                                    FlatButton(
                                      onPressed: _connected
                                          ? _sendOnMessageToBluetooth
                                          : null,
                                      child: Text("High update"),
                                    ),
                                    FlatButton(
                                      onPressed: _connected
                                          ? _sendOffMessageToBluetooth
                                          : null,
                                      child: Text("Low update"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              elevation: 2,
                              child: Text("Bluetooth Settings"),
                              onPressed: () {
                                FlutterBluetoothSerial.instance.openSettings();
                              },
                            ),
                            Image.asset('assets/wordtree.png'),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
     //   floatingActionButton: FloatingActionButton(
     //     onPressed: () async {
     //       await localNotificationManager.showNotification();
     //     },
     //     child: Icon(Icons.notifications),
     //   ),
      ),
    );
  }

  Widget buildGridCard({
    String title,
    String lable1,
    String lable2,
    Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      lable1,
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      lable2,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}

class RouteButtonToGrafana extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        launch('https://jirui.grafana.net/goto/16pqT06Gz');
      },
      child: Text('Grafana Data',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          primary: Color(0xFF7CB0E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          )),
    );
  }
}
