import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return InternetConnectionChecker().onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
      );
});

final initialConnectivityProvider = FutureProvider<bool>((ref) async {
  return await InternetConnectionChecker().hasConnection;
});
