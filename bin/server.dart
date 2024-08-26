import "dart:io";
import "dart:async";

/*

BACKEND

player1 joins chess server, rooms/1, as white by default
player2 joins chess server, rooms/1, as black by default
player3 joins chess server, rooms/2, as white by default
player4 joins chess server, rooms/2, as black by default

FRONTEND

white side is chosen for player1 by the server
player1 can only play white pieces
player2 can only play black pieces

*/

class ChessServer {
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
    print('Client connected');

    socket.listen(
      (message) => print("Message: $message"),
      onDone: () => print("Disconnected"),
      onError: (error) => print('Error: $error'),
    );
  }
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

void main() {
  ChessServer().start(8080);
}
