import 'dart:convert';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:web3dart/web3dart.dart';

Router dRouter(
  Web3Client _web3client,
  DeployedContract _contract,
  ContractFunction _listItem,
  ContractFunction _purchaseItem,
  ContractFunction _addReview,
  ContractFunction _getItem,
  ContractFunction _getReviews,
  String privateKey,
) {
  final router = Router();

  router.get('/items', (shelf.Request request) async {
    try {
      final itemCount = await _web3client.call(
        contract: _contract,
        function: _contract.function('itemCount'),
        params: [],
      );

      List<Map<String, dynamic>> items = [];
      for (int i = 1; i <= itemCount[0].toInt(); i++) {
        final item = await _web3client.call(
          contract: _contract,
          function: _getItem,
          params: [BigInt.from(i)],
        );

        items.add({
          'itemId': item[0][0].toInt(),
          'seller': item[0][1],
          'name': item[0][2],
          'description': item[0][3],
          'price': item[0][4].toInt(),
          'sold': item[0][5],
        });
      }

      print('items');
      print(items);

      // Use a custom encoder to handle EthereumAddress
      return shelf.Response.ok(
        jsonEncode(items, toEncodable: (object) {
          if (object is EthereumAddress) {
            return object.hexEip55;
          }
          if (object is BigInt) {
            return object.toString();
          }
          return object;
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Error fetching items: $e');
      print('Stack trace: $stackTrace');
      return shelf.Response.internalServerError(body: 'Error fetching items: $e');
    }
  });

  router.post('/items', (shelf.Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      print('Listing item:');
      print('Name: ${data['name']}');
      print('Description: ${data['description']}');
      print('Price: ${data['price']}');
      final _senderAddress = EthPrivateKey.fromHex(privateKey).address;
      final nonce = await _web3client.getTransactionCount(_senderAddress);
      final chainId = await _web3client.getChainId();

      final transaction = Transaction.callContract(
        contract: _contract,
        function: _listItem,
        parameters: [data['name'], data['description'], BigInt.parse(data['price'])],
        from: _senderAddress,
        nonce: nonce,
      );

      final signedTransaction = await _web3client.signTransaction(
        EthPrivateKey.fromHex(privateKey),
        transaction,
        chainId: chainId.toInt(),
      );

      final transactionHash = await _web3client.sendRawTransaction(signedTransaction);
      print('Transaction hash: $transactionHash');

      return shelf.Response.ok(jsonEncode({'transactionHash': transactionHash}));
    } catch (e) {
      print('Error listing item: $e');
      return shelf.Response.internalServerError(body: 'Error listing item: $e');
    }
  });

  router.post('/purchase/<itemId>', (shelf.Request request, String itemId) async {
    try {
      // Get the item details
      final item = await _web3client.call(
        contract: _contract,
        function: _getItem,
        params: [BigInt.parse(itemId)],
      );

      // Ensure the item exists and is not sold
      if (item[0][0] == BigInt.zero || item[0][5] == true) {
        return shelf.Response.notFound('Item not found or already sold');
      }

      final transaction = Transaction.callContract(
        contract: _contract,
        function: _purchaseItem,
        parameters: [BigInt.parse(itemId)],
        value: EtherAmount.inWei(item[0][4]), // Use the item's price
      );

      final chainId = await _web3client.getChainId();

      final result = await _web3client.sendTransaction(
        EthPrivateKey.fromHex(privateKey),
        transaction,
        chainId: chainId.toInt(),
      );

      return shelf.Response.ok(jsonEncode({'transactionHash': result}));
    } catch (e, stackTrace) {
      print('Error in /purchase POST: $e');
      print('Stack trace: $stackTrace');
      return shelf.Response.internalServerError(body: 'Error: $e');
    }
  });

  router.post('/review/<itemId>', (shelf.Request request, String itemId) async {
    final _senderAddress = EthPrivateKey.fromHex(privateKey).address;
    final nonce = await _web3client.getTransactionCount(_senderAddress);
    final chainId = await _web3client.getChainId();
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    await _web3client.sendTransaction(
      EthPrivateKey.fromHex(privateKey), // Replace with your private key
      Transaction.callContract(
        contract: _contract,
        function: _addReview,
        parameters: [BigInt.parse(itemId), BigInt.from(data['rating']), data['comment']],
        from: _senderAddress,
        nonce: nonce,
      ),
      chainId: chainId.toInt(),
    );

    return shelf.Response.ok('Review added successfully');
  });

  router.get('/reviews/<itemId>', (shelf.Request request, String itemId) async {
    try {
      final reviews = await _web3client.call(
        contract: _contract,
        function: _getReviews,
        params: [BigInt.parse(itemId)],
      );

      List<Map<String, dynamic>> formattedReviews = [];
      for (var review in reviews[0]) {
        formattedReviews.add({
          'rating': review[1].toInt(),
          'comment': review[2],
        });
      }

      return shelf.Response.ok(
        jsonEncode(formattedReviews),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching reviews: $e');
      return shelf.Response.internalServerError(body: 'Error fetching reviews: $e');
    }
  });

  return router;
}
