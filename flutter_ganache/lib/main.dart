import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLoading = true;

  final String _privatekey = '423614998ea46360de036952acbec8b808624a007ce3f9dd6d49b68b97fad2bf';

  late Web3Client web3client;

  final String wsUrl = 'ws://127.0.0.1:7545';
  @override
  void initState() {
    super.initState();

    web3client = Web3Client(
      "http://localhost:7545",
      http.Client(),
      socketConnector: () => WebSocketChannel.connect(Uri.parse(wsUrl)).cast<String>(),
    );
    ready();
  }

  Future<void> ready() async {
    await getABI();
    await getCredentials();
    await getDeployedContract();
  }

  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;

  Future<void> getABI() async {
    try {
      String abiFile = await rootBundle.loadString('build/contracts/HelloWorld.json');
      print("ABI file loaded successfully");

      var jsonABI = jsonDecode(abiFile);
      print("Networks: ${jsonABI['networks']}");

      _abiCode = ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'HelloWorld');

      // Try to get the network ID dynamically
      final networkId = jsonABI["networks"]["5777"];
      print('networkId');
      print(networkId);

      _contractAddress = EthereumAddress.fromHex(networkId["address"]);
      print('Contract Address: $_contractAddress');
    } catch (e) {
      print("Error in getABI: $e");
    }
  }

  late EthPrivateKey _creds;
  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privatekey);
  }

  late DeployedContract _deployedContract;
  late ContractFunction _getMessage;
  late ContractFunction _setMessage;

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);
    _getMessage = _deployedContract.function('getMessage');
    _setMessage = _deployedContract.function('setMessage');

    await fetchUsers();
  }

  Future<void> fetchUsers() async {
    var data = await web3client.call(
      contract: _deployedContract,
      function: _getMessage,
      params: [],
    );

    final hello = data;
    print(hello);
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
