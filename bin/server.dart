import 'dart:io';
import 'dart:async';

class ChessServer {
  final List<WebSocket> _clients = [];

  Future<void> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('Listening on ${server.address.address}:${server.port}');

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        handleWebSocket(request);
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        request.response.close();
      }
    }
  }

  void handleWebSocket(HttpRequest request) async {
    final socket = await WebSocketTransformer.upgrade(request);
    _clients.add(socket);
    print('Client connected');

    socket.listen(
      (message) {
        print("Message: $message");
        broadcastMessage(message);
      },
      onDone: () {
        print("Client disconnected");
        _clients.remove(socket);
      },
      onError: (error) {
        print('Error: $error');
        _clients.remove(socket);
      },
    );
  }

  void broadcastMessage(String message) {
    for (var client in _clients) {
      client.add(message);
    }
  }
}

void main() {
  ChessServer().start(8080);
}
