import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketServer {
  void main(String cheat) async {
    String? ip = await getInternalIpAddress();
    if (ip != null) {
      HttpServer server = await HttpServer.bind(ip, 55444, shared: true);
      server.transform(WebSocketTransformer()).listen((WebSocket client) {
        client.add(cheat);
        stop(55444);
      });
    } else {
      print('No IP found');
    }
  }

  void sendDraw(String text) async {
    String? ip = await getInternalIpAddress();
    if (ip != null) {
      debugPrint("ws: " + ip);
      HttpServer server = await HttpServer.bind(ip, 55544, shared: true);
      server.transform(WebSocketTransformer()).listen((WebSocket client) {
        client.add(text);
        stop(55544);
      });
    } else {
      print('No IP found');
    }
  }

  Future<String?> getInternalIpAddress() async {
    try {
      // Get the list of network interfaces
      var interfaces = await NetworkInterface.list();

      // Specify the prefix of your local LAN IP address (e.g., "192.168.")
      String interfacePrefix = 'wlan0';

      // Iterate through the network interfaces to find the IPv4 address on a local network

      if (Platform.isIOS) {
        for (var interface in interfaces) {
          // Iterate through the addresses associated with the interface
          for (var addr in interface.addresses) {
            // Check if the address is IPv4 and is not a loopback address

            if (addr.type.name == 'IPv4' && !addr.isLoopback) {
              // Check if the address is in the specified subnet

              // Return the address string
              debugPrint(addr.address);
              return addr.address;
            }
          }
        }
      } else {
        for (var interface in interfaces) {
          // Iterate through the addresses associated with the interface
          for (var addr in interface.addresses) {
            // Check if the address is IPv4 and is not a loopback address
            if (interface.name.startsWith(interfacePrefix)) {
              if (addr.type.name == 'IPv4' && !addr.isLoopback) {
                // Check if the address is in the specified subnet
                if (interface.name.startsWith(interfacePrefix)) {
                  // Return the address string
                  debugPrint(addr.address);
                  return addr.address;
                }
              }
            }
          }
        }
      }

      print('No local LAN IP address found.');
    } catch (e) {
      print('Error: $e');
    }
  }

  void stop(int port) async {
    String? ip = await getInternalIpAddress();
    if (ip != null) {
      HttpServer.bind(ip, port, shared: true).then((server) => server.close());
    }
  }
}
