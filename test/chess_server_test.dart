import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:test/test.dart';
import '../bin/server.dart'; 

void main() {
  late ChessServer server;
  late HttpServer httpServer;

  setUp(() async {
    server = ChessServer();
    httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 8082, shared: true);
    server.start(8082);
    await Future.delayed(Duration(seconds: 1)); 
  });

  tearDown(() async {
    await httpServer.close();
  });

  test('Server starts and listens on port 8082', () async {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/'));
    final response = await request.close();
    
    expect(response.statusCode, equals(HttpStatus.ok));
  });

  test('Server responds to /health endpoint', () async {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/health'));
    final response = await request.close();
    
    expect(response.statusCode, equals(HttpStatus.ok));
    final responseBody = await response.transform(utf8.decoder).join();
    expect(responseBody, equals('OK'));
  });

  test('Server returns 404 for non-existent routes', () async {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/nonexistent'));
    final response = await request.close();
    
    expect(response.statusCode, equals(HttpStatus.notFound));
  });

  test('Server responds to root route with correct HTML content', () async {
  final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/'));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  expect(response.statusCode, equals(HttpStatus.ok));
  expect(responseBody, contains('<html>'));
  expect(responseBody, contains('<h1>Northchess Server</h1>'));
});

test('Server responds to /health with correct content', () async {
  final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/health'));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  expect(response.statusCode, equals(HttpStatus.ok));
  expect(responseBody, equals('OK'));
});

test('Server returns 404 for non-existent routes', () async {
  final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/nonexistent'));
  final response = await request.close();
  
  expect(response.statusCode, equals(HttpStatus.notFound));
});

test('Server responds with correct headers', () async {
  final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/'));
  final response = await request.close();
  
  expect(response.headers.contentType.toString(), equals('text/html; charset=utf-8'));
});

test('Server responds in a timely manner', () async {
  final request = await HttpClient().getUrl(Uri.parse('http://localhost:8082/'));
  final stopwatch = Stopwatch()..start();
  await request.close();
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(500)); 
});

}
