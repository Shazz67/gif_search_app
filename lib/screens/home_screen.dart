import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/giphy_service.dart';
import '../models/gif_model.dart';
import '../providers/providers.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/category_button.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gif_grid_item.dart';
import '../widgets/error_message.dart';
import '../widgets/search_bar.dart' as custom;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final GiphyService _giphyService;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _selectedCategory = 'Trending';
  late List<GifModel> _gifs = [];
  final Set<String> _displayedGifs = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _loadMoreError;
  int _offset = 0;
  Timer? _debounce;
  final int _limit = 16;

  bool? _previousConnectivity;
  bool _hasProcessedTag = false;

  final List<String> _categories = [
    'Trending',
    'LOL',
    'Good morning',
    'Love you',
    'Hug',
    'Happy',
    'Sad',
    'Cats',
    'Goodnight',
    'Puppies',
    'Dance',
    'Annoyed'
  ];

  @override
  void initState() {
    super.initState();
    _giphyService = ref.read(giphyServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay the fetch logic until the widget is fully initialized.
      final tagArgument = ModalRoute.of(context)?.settings.arguments as String?;
      if (tagArgument != null) {
        _processTagArgument(tagArgument);
      } else {
        _fetchGifsByCategory(_selectedCategory);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _processTagArgument(String tag) {
    setState(() {
      _searchQuery = tag;
      _searchController.text = tag;
      _offset = 0;
      _gifs = [];
      _error = null; // Clear previous errors
    });
    _searchGifs(); // Trigger search for the tag
  }

  @override
  void dispose() {
    for (var key in _displayedGifs) {
      VisibilityDetectorController.instance.forget(Key(key));
    }
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        setState(() {
          _searchQuery = query;
          _offset = 0;
          _gifs = [];
        });
        _searchGifs();
      } else {
        setState(() {
          _searchQuery = '';
          _gifs = [];
          _fetchGifsByCategory(_selectedCategory);
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoadingMore) {
      if (_searchQuery.isNotEmpty) {
        _loadMoreGifs();
      } else {
        _loadMoreCategoryGifs();
      }
    }
  }

  Future<void> _fetchGifsByCategory(String category) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _loadMoreError = null;
    });
    try {
      final gifs =
          await _giphyService.getGifsByCategory(category, offset: _offset);
      if (!mounted) return;
      if (gifs.isEmpty) {
        setState(() {
          _error = 'No GIFs found for $category';
        });
      } else {
        final gifModels = gifs.map((json) => GifModel.fromJson(json)).toList();
        setState(() {
          _error = null;
          _gifs = gifModels;
          _offset += _limit;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load GIFs for $category';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchGifs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _loadMoreError = null;
      _gifs = [];
    });

    try {
      final fetchedGifs =
          await _giphyService.searchGifs(_searchQuery, offset: _offset);
      if (!mounted) return;
      if (fetchedGifs.isEmpty) {
        setState(() {
          _error = 'No GIFs found for your search query';
          _gifs = [];
        });
      } else {
        final gifModels = fetchedGifs
            .map<GifModel>((json) => GifModel.fromJson(json))
            .toList();
        setState(() {
          _error = null;
          _gifs = gifModels;
          _offset += _limit;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load GIFs';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreGifs() async {
    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final fetchedMoreGifs = await _giphyService.searchGifs(
        _searchQuery,
        offset: _offset,
      );
      if (fetchedMoreGifs.isNotEmpty) {
        final moreGifModels = fetchedMoreGifs
            .map<GifModel>((json) => GifModel.fromJson(json))
            .toList();

        setState(() {
          _gifs.addAll(moreGifModels);
          _offset += _limit;
        });
      }
    } catch (e) {
      setState(() {
        _loadMoreError = 'Failed to load more GIFs';
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreCategoryGifs() async {
    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final fetchedMoreGifs = await _giphyService.getGifsByCategory(
        _selectedCategory,
        offset: _offset,
      );
      if (fetchedMoreGifs.isNotEmpty) {
        final moreGifModels = fetchedMoreGifs
            .map<GifModel>((json) => GifModel.fromJson(json))
            .toList();

        setState(() {
          _gifs.addAll(moreGifModels);
          _offset += _limit;
        });
      }
    } catch (e) {
      setState(() {
        _loadMoreError = 'Failed to load more GIFs for $_selectedCategory';
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = category == _selectedCategory;

    return CategoryButton(
      category: category,
      isSelected: isSelected,
      onPressed: () {
        setState(() {
          _selectedCategory = category;
          _gifs = [];
          _offset = 0;
          _fetchGifsByCategory(category);
        });
      },
    );
  }

  Widget _buildGifItem(String imageUrl, GifModel gif) {
    final shouldFadeIn = !_displayedGifs.contains(imageUrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _displayedGifs.add(imageUrl);
    });

    return GifGridItem(
      gif: gif,
      imageUrl: imageUrl,
      heroTag: imageUrl,
      shouldFadeIn: shouldFadeIn,
      onTap: () {
        Navigator.of(context).pushNamed(
          '/detailed',
          arguments: gif,
        );
      },
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 0) {
          _displayedGifs.add(imageUrl);
        } else {
          _displayedGifs.remove(imageUrl);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);

    connectivityState.whenData((isConnected) {
      if (_previousConnectivity == false && isConnected) {
        if (_searchQuery.isNotEmpty) {
          setState(() {
            _error = null;
            _loadMoreError = null;
          });

          _searchGifs();
        } else {
          setState(() {
            _error = null;
          });

          _fetchGifsByCategory(_selectedCategory);
        }
      }

      _previousConnectivity = isConnected;
    });

    final tagArgument = ModalRoute.of(context)?.settings.arguments as String?;
    if (tagArgument != null && !_hasProcessedTag) {
      setState(() {
        _hasProcessedTag = true; // Mark tag as processed
        _searchQuery = tagArgument;
        _searchController.text = tagArgument;
        _offset = 0;
        _gifs = [];
      });
      _searchGifs();
    }

    Future<void> refreshContent() async {
      if (_searchQuery.isNotEmpty) {
        await _searchGifs();
      } else {
        await _fetchGifsByCategory(_selectedCategory);
      }
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'GIFFY | GIFs for everybody',
        canPop: ModalRoute.of(context)?.canPop ?? false,
        height: Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight,
      ),
      body: Container(
        decoration: const BoxDecoration(
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 44,
                  child: custom.SearchBar(
                    controller: _searchController,
                    hintText: "What's on your mind?",
                    onChanged: _onSearchChanged,
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _gifs = [];
                        _fetchGifsByCategory(_selectedCategory);
                      });
                    },
                  ),
                ),
              ),
              if (_searchQuery.isEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                    child: Row(
                      children: _categories
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildCategoryButton(category),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              if (_error != null && _gifs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: ErrorMessage(message: _error!),
                ),
              Expanded(
                child: _isLoading && _gifs.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 45,
                              child: Lottie.asset(
                                'assets/animations/loading.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        controller: _scrollController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              10.0,
                              0.0,
                              10.0,
                              10.0,
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
                              itemCount: _gifs.length,
                              itemBuilder: (context, index) {
                                final gif = _gifs[index];
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
                                    'assets/animations/loading.json',
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
                              child: ErrorMessage(
                                  message:
                                      _loadMoreError!), // Show load more error here
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
