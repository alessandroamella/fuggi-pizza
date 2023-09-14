class ConnectionInfo {
  final String? serverName;
  final String serverAddress;
  final int serverPort;

  const ConnectionInfo({
    this.serverName,
    required this.serverAddress,
    required this.serverPort,
  });
}
