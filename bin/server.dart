import 'dart:io';
import 'dart:async';

class GameInstance {
  final WebSocket whitePlayer;
  final WebSocket blackPlayer;
  GameInstance(this.whitePlayer, this.blackPlayer);
}

class ChessServer {
  final List<WebSocket> _clients = [];
  final List<GameInstance> games = [];

  WebSocket? _waitingToPlay = null;

  final Map<WebSocket, String> socketNameMap = {};
  final Map<WebSocket, GameInstance> socketGameMap = {};

  Future<void> start(int port) async {
    final server =
        await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
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
        handleMessage(message, socket);
        // broadcastMessage(message);
      },
      onDone: () {
        print("Client disconnected");
        _clients.remove(socket);

        if (_waitingToPlay == socket) {
          _waitingToPlay = null;
        }

        if (socketNameMap.containsKey(socket)) {
          socketNameMap.remove(socket);
        }

        if (socketGameMap.containsKey(socket)) {
          final currentGame = socketGameMap[socket];
          if (currentGame == null) return;
          socketGameMap.remove(currentGame.whitePlayer);
          socketGameMap.remove(currentGame.blackPlayer);
          games.remove(currentGame);
          currentGame.whitePlayer.add("disconnected");
          currentGame.blackPlayer.add("disconnected");
        }
      },
      onError: (error) {
        print('Error: $error');
        _clients.remove(socket);
      },
    );
  }

  void handleMessage(String message, WebSocket socket) {
    final [instruction, payload] = message.split(":");

    switch (instruction) {
      case "user":
        socketNameMap[socket] = payload;
        if (_waitingToPlay == null) {
          // add client to waiting to play if nones already waiting to play
          _waitingToPlay = socket;
          socket.add('user:$payload:white');
        } else {
          // send clients the oposition names
          socket.add('user:$payload:black');
          socket.add('user:${socketNameMap[_waitingToPlay]}:white');

          _waitingToPlay!.add('user:$payload:black');

          final newGame = GameInstance(_waitingToPlay!, socket);
          socketGameMap[socket] = newGame;
          socketGameMap[_waitingToPlay!] = newGame;
          games.add(newGame);

          _waitingToPlay = null;
        }
        print(socketNameMap);
        print(_waitingToPlay);
        print(games);
        break;
      case "move":
        final currentGame = socketGameMap[socket];
        if (currentGame == null) return;
        if (socket == currentGame.whitePlayer) {
          currentGame.blackPlayer.add('move:$payload');
        }
        if (socket == currentGame.blackPlayer) {
          currentGame.whitePlayer.add('move:$payload');
        }
        break;
      case "resign":
        final currentGame = socketGameMap[socket];
        if (currentGame == null) return;

        if (socket == currentGame.whitePlayer) {
          currentGame.blackPlayer.add('opponent-resigned');
        }
        if (socket == currentGame.blackPlayer) {
          currentGame.whitePlayer.add('opponent-resigned');
        }
        socketGameMap.remove(currentGame.whitePlayer);
        socketGameMap.remove(currentGame.blackPlayer);
        games.remove(currentGame);

        break;
      case "promote":
        final currentGame = socketGameMap[socket];
        if (currentGame == null) return;

        if (socket == currentGame.whitePlayer) {
          currentGame.blackPlayer.add('promote:$payload');
        }
        if (socket == currentGame.blackPlayer) {
          currentGame.whitePlayer.add('promote:$payload');
        }
        break;
      case "exit":
        final currentGame = socketGameMap[socket];
        if (currentGame == null) return;
        socketGameMap.remove(currentGame.whitePlayer);
        socketGameMap.remove(currentGame.blackPlayer);
        games.remove(currentGame);
        break;
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
}

void main() {
  ChessServer().start(8080);
}
