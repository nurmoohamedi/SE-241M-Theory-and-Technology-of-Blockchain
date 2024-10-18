import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:marketplace_backend/router/router.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:web3dart/web3dart.dart';

const privateKey = '87d588b852d086890a3487bd70ae90068d7d37846f6890a7c160c90ee155469b';

class MarketplaceBackend {
  MarketplaceBackend();

  late Web3Client _web3client;
  late DeployedContract _contract;
  late ContractFunction _listItem;
  late ContractFunction _purchaseItem;
  late ContractFunction _addReview;
  late ContractFunction _getItem;
  late ContractFunction _getReviews;

  Future<void> initialize() async {
    await _initializeWeb3();
  }

  Future<void> _initializeWeb3() async {
    final client = Client();
    _web3client = Web3Client('http://localhost:7545', client);
    await _getDeployedContract();
  }

  Future<void> _getDeployedContract() async {
    final abiString = await File('build/contracts/Marketplace.json').readAsString();
    final jsonABI = jsonDecode(abiString);
    final contractAddress = jsonABI['networks']['5777']['address'];

    final contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'Marketplace'),
      EthereumAddress.fromHex(contractAddress),
    );
    _contract = contract;
    _listItem = contract.function('listItem');
    _purchaseItem = contract.function('purchaseItem');
    _addReview = contract.function('addReview');
    _getItem = contract.function('getItem');
    _getReviews = contract.function('getReviews');
  }

  Future<void> startServer() async {
    final ip = InternetAddress.anyIPv4;
    final router =
        dRouter(_web3client, _contract, _listItem, _purchaseItem, _addReview, _getItem, _getReviews, privateKey);

    // Add CORS middleware
    final corsMiddleware = corsHeaders(
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
      },
    );
    final handler =
        const shelf.Pipeline().addMiddleware(corsMiddleware).addMiddleware(shelf.logRequests()).addHandler((request) {
      if (request.method == 'OPTIONS') {
        return shelf.Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
        });
      }
      return router(request);
    });
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final server = await io.serve(handler, ip, port);
    print('Server listening on port ${server.port}');
  }
}

void main() async {
  final backend = MarketplaceBackend();
  await backend.initialize();
  await backend.startServer();
}
