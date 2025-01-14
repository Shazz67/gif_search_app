import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:gif_search_app/data/giphy_service.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return InternetConnectionChecker().onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
      );
});

final initialConnectivityProvider = FutureProvider<bool>((ref) async {
  return await InternetConnectionChecker().hasConnection;
});

final giphyServiceProvider = Provider<GiphyService>((ref) => GiphyService());
