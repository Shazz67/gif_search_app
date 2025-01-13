import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gif_model.dart';
import '../data/giphy_service.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/connectivity_provider.dart';
import 'package:lottie/lottie.dart';
import '../widgets/network_image_with_placeholder.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/gradient_app_bar.dart';

class DetailedGifScreen extends ConsumerStatefulWidget {
  final GifModel gif;

  const DetailedGifScreen({super.key, required this.gif});

  @override
  ConsumerState<DetailedGifScreen> createState() => _DetailedGifScreenState();
}

class _DetailedGifScreenState extends ConsumerState<DetailedGifScreen> {
  late List<GifModel> _relatedGifs;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _offset = 0;
  final int _limit = 16;
  final Set<String> _displayedGifs = {};
  bool _isReturningFromHero = false;
  String? _error;

  bool? _previousConnectivity;

  @override
  void initState() {
    super.initState();
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
      _isLoadingMore = true;
    });

    try {
      final fetchedGifs = await GiphyService()
          .searchGifs(widget.gif.title, offset: _offset, limit: _limit);
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
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load related GIFs';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoadingMore) {
      _fetchRelatedGifs();
    }
  }

  Widget _buildGifItem(String imageUrl, GifModel gif) {
    final shouldFadeIn =
        !_displayedGifs.contains(imageUrl) && !_isReturningFromHero;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _displayedGifs.add(imageUrl);
    });

    return VisibilityDetector(
        key: Key(imageUrl),
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
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isReturningFromHero = true;
            });
            Navigator.of(context)
                .pushNamed('/detailed', arguments: gif)
                .then((_) {
              if (!mounted) return;
              setState(() {
                _isReturningFromHero = false;
              });
            });
          },
          child: Hero(
            tag: imageUrl,
            child: NetworkImageWithPlaceholder(
              imageUrl: imageUrl,
              shouldFadeIn: shouldFadeIn,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ));
  }

  AppBar buildGradientAppBar(BuildContext context) {
    final title =
        widget.gif.title.isNotEmpty ? widget.gif.title : 'Untitled GIF';

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Transform.translate(
        offset: const Offset(-18.0, 0.0),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 0, 93),
                Color(0xFF3D3DFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);

    connectivityState.whenData((isConnected) {
      if (_previousConnectivity == false && isConnected) {
        setState(() {
          _error = null;
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

    return Scaffold(
        appBar: buildGradientAppBar(context),
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
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Center(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 19, 106),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
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
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
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
                                      'assets/loading2.json',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
