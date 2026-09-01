import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class SocketApi {
  static io.Socket? socket;
  static bool _isInitialized = false;

  static void init(String baseUrl, String userId) {
    if (_isInitialized) {
      debugPrint('⚠️ Socket already initialized');
      return;
    }

    try {
      debugPrint('🟡 Connecting to: $baseUrl with user: $userId');

      socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'id': userId})
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(999)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .build(),
      );

      _setupCoreListeners(userId);
      socket!.connect();

      _isInitialized = true;
    } catch (e) {
      debugPrint("⚠xx Socket init failed: $e");
    }
  }

  static void _setupCoreListeners(String userId) {
    if (socket == null) return;

    socket!.onConnect((_) {
      debugPrint('✅ Socket connected - UserID: $userId');
    });

    // socket!.onDisconnect((_) {
    //   debugPrint("==========️ Socket disconnected");
    // });

    socket!.onConnectError((err) {
      debugPrint("❌ Connect Error: $err");
    });

    socket!.on('socket-error', (data) {
      debugPrint("❌ Socket Error Event: $data");
    });
  }

  static void on(String event, Function(dynamic) callback) {
    socket?.on(event, callback);
  }

  static void off(String event) {
    socket?.off(event);
  }

  static void emit(String event, dynamic data) {
    if (socket == null || !socket!.connected) {

      debugPrint("❌ Cannot emit - socket not connected");
      return;
    }
    debugPrint("=================================SOCKET NOT NULL AND CONNECTED==========================================");
    debugPrint("📤 Emit [$event]: $data");
    socket!.emit(event, data);
  }

  static bool get isConnected => socket?.connected ?? false;

  // static void disconnect() {
  //   socket?.disconnect();
  // }

  static void dispose() {
    socket?.dispose();
    socket = null;
    _isInitialized = false;
  }
}