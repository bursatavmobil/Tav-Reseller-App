import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  void init(String url, {String? token}) {
    try {
      Map<String, dynamic> options = {
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 2000,
      };

      if (token != null) {
        options['query'] = 'token=$token';
      }

      _socket = IO.io(url, options);
    } catch (e) {
      log("SOCKET Init error: $e");
    }
  }

  void connect() {
    if (_socket == null) return;
    _socket!.connect();
    _socket!.onConnect((_) => log("SOCKET CONNECTED"));
    _socket!.onDisconnect((_) => log("SOCKET DISCONNECTED"));
    _socket!.onConnectError((data) => log("SOCKET ERROR: $data"));
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void joinRoom(String roomId, String userId) {
    final payload = {"room_id": roomId, "user_id": userId};
    _socket?.emit("join_room", payload);
    log("SOCKET JOIN ROOM: $payload");
  }

  void onReceiveMessage(Function(dynamic data) callback) {
    _socket?.off("receive_message");
    _socket?.on("receive_message", (data) {
      if (data != null) callback(data);
    });
  }

  void onUpdateNominal(Function(dynamic data) callback) {
    _socket?.off("update_nominal");
    _socket?.on("update_nominal", (data) {
      if (data != null) callback(data);
    });
  }

  void onReceiveApproval(Function(dynamic data) callback) {
    _socket?.off("receive_approval");
    _socket?.on("receive_approval", (data) {
      if (data != null) callback(data);
    });
  }

  void clearChatListeners() {
    _socket?.off("receive_message");
    _socket?.off("update_nominal");
    _socket?.off("receive_approval");
  }

  void sendChatMessage(Map<String, dynamic> payload) {
    _socket?.emit("send_message", payload);
    log("SOCKET SEND MESSAGE: $payload");
  }

  void onCustomEvent(String eventName, Function(dynamic data) callback) {
    _socket?.off(eventName);
    _socket?.on(eventName, (data) => callback(data));
  }
}
