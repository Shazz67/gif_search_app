import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gif_model.dart';
import '../services/giphy_service.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import 'package:lottie/lottie.dart';
import '../widgets/shared/network_image_with_placeholder.dart';
import '../widgets/shared/gradient_app_bar.dart';
import '../widgets/shared/gif_grid_item.dart';
import '../widgets/shared/error_message.dart';

class DetailedGifScreen extends ConsumerStatefulWidget {
  final GifModel gif;

  const DetailedGifScreen({super.key, required this.gif});

  @override
  ConsumerState<DetailedGifScreen> createState() => _DetailedGifScreenState();
}

class _DetailedGifScreenState extends ConsumerState<DetailedGifScreen> {
  late final GiphyService _giphyService;
  late List<GifModel> _relatedGifs;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 16;
  final Set<String> _displayedGifs = {};
  bool _isReturningFromHero = false;
  String? _error;
  String? _loadMoreError;

  bool? _previousConnectivity;

  @override
  void initState() {
    super.initState();
    _giphyService = ref.read(giphyServiceProvider);
    _relatedGifs = [];
    _fetchRelatedGifs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRelatedGifs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _loadMoreError = null;
    });

    try {
      final fetchedGifs = await _giphyService.searchGifs(widget.gif.title,
          offset: _offset, limit: _limit);
      if (!mounted) return;
      final parsedGifs =
          fetchedGifs.map((gif) => GifModel.fromJson(gif)).toList();
      parsedGifs.shuffle();

      final filteredGifs =
          parsedGifs.where((gif) => gif.id != widget.gif.id).toList();

      if (filteredGifs.length == 16) {
      } else if (filteredGifs.length == 15) {
        filteredGifs.removeLast();
      }

      if (!mounted) return;
      setState(() {
        _relatedGifs.addAll(filteredGifs);
        _offset += _limit;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load related GIFs';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreRelatedGifs() async {
    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
      _error = null;
    });

    try {
      final fetchedGifs = await _giphyService.searchGifs(widget.gif.title,
          offset: _offset, limit: _limit);
      if (!mounted) return;
      final parsedGifs =
          fetchedGifs.map((gif) => GifModel.fromJson(gif)).toList();
      parsedGifs.shuffle();

      final filteredGifs =
          parsedGifs.where((gif) => gif.id != widget.gif.id).toList();

      if (filteredGifs.length == 16) {
      } else if (filteredGifs.length == 15) {
        filteredGifs.removeLast();
      }

      if (!mounted) return;
      setState(() {
        _relatedGifs.addAll(filteredGifs);
        _offset += _limit;
        _loadMoreError = null;
      });
    } catch (e) {
      setState(() {
        _loadMoreError = 'Failed to load more related GIFs';
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoadingMore) {
      _loadMoreRelatedGifs();
    }
  }

  Widget _buildGifItem(String imageUrl, GifModel gif) {
    final shouldFadeIn =
        !_displayedGifs.contains(imageUrl) && !_isReturningFromHero;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _displayedGifs.add(imageUrl);
      }
    });

    return GifGridItem(
      gif: gif,
      imageUrl: imageUrl,
      heroTag: imageUrl,
      shouldFadeIn: shouldFadeIn,
      onTap: () {
        setState(() {
          _isReturningFromHero = true;
        });
        Navigator.of(context).pushNamed('/detailed', arguments: gif).then((_) {
          if (!mounted) return;
          setState(() {
            _isReturningFromHero = false;
          });
        });
      },
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 0) {
          setState(() {
            _displayedGifs.add(imageUrl);
          });
        } else {
          setState(() {
            _displayedGifs.remove(imageUrl);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);

    connectivityState.whenData((isConnected) {
      if (_previousConnectivity == false && isConnected) {
        setState(() {
          _error = null;
          _loadMoreError = null;
        });
        _fetchRelatedGifs();
      }

      _previousConnectivity = isConnected;
    });

    final gifUrl = widget.gif.images.original.url;
    final width = widget.gif.images.original.width ?? 300;
    final height = widget.gif.images.original.height ?? 300;

    Future<void> refreshContent() async {
      setState(() {
        _offset = 0;
        _relatedGifs.clear();
        _error = null;
      });
      await _fetchRelatedGifs();
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
        appBar: GradientAppBar(
          title:
              widget.gif.title.isNotEmpty ? widget.gif.title : 'Untitled GIF',
          titleOffset: -18.0,
          titleStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          height: Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 243, 241, 255),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: RefreshIndicator(
                onRefresh: refreshContent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 0.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          children: [
                            const SizedBox(height: 10),
                            Hero(
                              tag: gifUrl,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.6,
                                    maxWidth: MediaQuery.of(context).size.width,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: width / height,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Stack(
                                        children: [
                                          const PulsatingPlaceholder(),
                                          Positioned.fill(
                                            child: Image.network(
                                              gifUrl,
                                              fit: BoxFit.contain,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const SizedBox.shrink();
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.error,
                                                    size: 50);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: widget.gif.user != null
                                          ? NetworkImage(
                                              widget.gif.user!.avatarUrl)
                                          : null,
                                      radius: 20,
                                      child: widget.gif.user == null
                                          ? const Icon(Icons.public)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.gif.user != null) ...[
                                            Text(
                                              widget.gif.user!.displayName
                                                      .isNotEmpty
                                                  ? widget.gif.user!.displayName
                                                  : 'Unknown User',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '@${widget.gif.user!.username}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ] else if (widget.gif.source !=
                                                  null &&
                                              widget
                                                  .gif.source!.isNotEmpty) ...[
                                            Text(
                                              'Source',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(
                                              widget.gif.source!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ] else ...[
                                            Text(
                                              'Unknown Source',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        final gifUrl =
                                            widget.gif.images.original.url;
                                        Share.share(
                                            'Check out this awesome GIF: $gifUrl');
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (widget.gif.tags.isNotEmpty)
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: widget.gif.tags.map((tag) {
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              '/home',
                                              arguments: tag,
                                            );
                                          },
                                          child: SizedBox(
                                            height: 30.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color.fromARGB(
                                                        255, 202, 205, 255),
                                                    blurRadius: 10,
                                                    spreadRadius: -6,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Chip(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                label: Transform.translate(
                                                  offset: const Offset(0, -1.5),
                                                  child: ShaderMask(
                                                    shaderCallback: (bounds) =>
                                                        LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 75, 78, 255),
                                                        Color.fromARGB(
                                                            255, 75, 78, 255),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ).createShader(bounds),
                                                    child: Text(
                                                      tag,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  side: BorderSide(
                                                    color: const Color.fromARGB(
                                                        0, 216, 219, 255),
                                                    width: 0,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                          ));
                                    }).toList(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4.0),
                                Text(
                                  'Related GIFs',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                            if (_isLoading)
                              Center(
                                child: SizedBox(
                                  height: 45,
                                  child: Lottie.asset(
                                      'assets/animations/loading2.json'),
                                ),
                              ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10.0,
                                ),
                                child: ErrorMessage(message: _error!),
                              ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10.0,
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isLandscape ? 4 : 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: _relatedGifs.length,
                                itemBuilder: (context, index) {
                                  final gif = _relatedGifs[index];
                                  final imageUrl = gif.images.fixedHeight.url;
                                  return _buildGifItem(imageUrl, gif);
                                },
                              ),
                            ),
                            if (_isLoadingMore)
                              Transform.translate(
                                offset: const Offset(0, -6.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 4.0,
                                  ),
                                  child: SizedBox(
                                    height: 45,
                                    child: Lottie.asset(
                                      'assets/animations/loading2.json',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            if (_loadMoreError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 19.0,
                                  top: 7.0,
                                ),
                                child: ErrorMessage(message: _loadMoreError!),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
