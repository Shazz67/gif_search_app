import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class AppLayout extends ConsumerStatefulWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  String _popupMessage = '';
  bool _initialCheckDone = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();

    Future.delayed(const Duration(seconds: 3), () {
      final isConnected = ref.read(connectivityProvider).valueOrNull ?? true;

      setState(() {
        _initialCheckDone = true;
      });

      if (!isConnected) {
        _wasOffline = true;
        _showConnectivityPopup(false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _showConnectivityPopup(bool hasConnection) {
    if (hasConnection && !_wasOffline) {
      return;
    }

    setState(() {
      _popupMessage = hasConnection ? 'Back online!' : 'No internet connection';
    });

    _animationController.forward();

    if (hasConnection) {
      _wasOffline = false;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_animationController.status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);

    connectivityState.whenData((isConnected) {
      if (_initialCheckDone) {
        _showConnectivityPopup(isConnected);
        if (!isConnected) {
          _wasOffline = true;
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: ClipRect(
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    width: double.infinity,
                    color: _popupMessage == 'Back online!'
                        ? Colors.green
                        : Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _popupMessage == 'Back online!'
                              ? Icons.check_circle
                              : Icons.error,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _popupMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
