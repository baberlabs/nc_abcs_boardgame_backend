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
        handleHttpRequest(request);
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

  handleHttpRequest(HttpRequest request) {
    print("HTTP request: ${request.method} ${request.uri.path}");

    if (request.uri.path == "/health") {
      request.response
        ..statusCode = HttpStatus.ok
        ..write("OK")
        ..close();
    } else if (request.uri.path == "/") {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(
            "<html><body><h1>Northchess Server</h1></h2>Made by Team ABCs</h2><p>WebSocket endpoint availalbe.</p></body></html>")
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write("Not Found")
        ..close();
    }
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
