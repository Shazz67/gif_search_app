import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/giphy_service.dart';
import '../models/gif_model.dart';
import '../providers/connectivity_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/network_image_with_placeholder.dart';
import '../widgets/category_button.dart';
import '../widgets/gradient_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GiphyService _giphyService = GiphyService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _selectedCategory = 'Trending';
  late List<GifModel> _gifs = [];
  final Set<String> _displayedGifs = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _offset = 0;
  Timer? _debounce;
  final int _limit = 16;

  bool? _previousConnectivity;

  final List<String> _categories = [
    'Trending',
    'LOL',
    'Good morning',
    'Love you',
    'Cats',
    'Happy',
    'Sad',
  ];

  @override
  void initState() {
    super.initState();
    _fetchGifsByCategory(_selectedCategory);
    _scrollController.addListener(_onScroll);
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
        });
      }
    }
  }

  Future<void> _searchGifs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
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
        });
        setState(() {
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
        });
      }
    }
  }

  Future<void> _loadMoreGifs() async {
    setState(() {
      _isLoadingMore = true;
      _error = null;
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
        _error = 'Failed to load more GIFs';
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
      _error = null;
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
        _error = 'Failed to load more GIFs for $_selectedCategory';
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

    final String heroTag = imageUrl;

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
            Navigator.of(context).pushNamed(
              '/detailed',
              arguments: gif,
            );
          },
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: [
                  NetworkImageWithPlaceholder(
                    imageUrl: imageUrl,
                    shouldFadeIn: shouldFadeIn,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);

    connectivityState.whenData((isConnected) {
      if (_previousConnectivity == false && isConnected) {
        if (_searchQuery.isNotEmpty) {
          setState(() {
            _error = null;
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
    if (tagArgument != null && tagArgument.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_searchQuery != tagArgument) {
          setState(() {
            _isLoading = true;
            _searchQuery = tagArgument;
            _searchController.text = tagArgument;
            _offset = 0;
            _gifs = [];
          });
          _searchGifs().then((_) {
            setState(() {
              _isLoading = false;
            });
          }).catchError((_) {
            setState(() {
              _isLoading = false;
            });
          });
        }
      });
    }

    Future<void> refreshContent() async {
      if (_searchQuery.isNotEmpty) {
        await _searchGifs();
      } else {
        await _fetchGifsByCategory(_selectedCategory);
      }
    }

    return Scaffold(
      appBar: GradientAppBar(
        title: 'GIFFY | GIFs for everybody',
        canPop: ModalRoute.of(context)?.canPop ?? false,
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "What's on your mind?",
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 75, 78, 255),
                        fontSize: 18,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 152, 163, 255),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 77, 77, 240),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color.fromARGB(255, 75, 78, 255)),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _gifs = [];
                                  _fetchGifsByCategory(_selectedCategory);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
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
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 10.0,
                  ),
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
              Expanded(
                child: _isLoading && _gifs.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 45,
                              child: Lottie.asset(
                                'assets/loading.json',
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
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
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
                                    'assets/loading.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
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
