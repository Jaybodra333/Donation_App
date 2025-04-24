import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ngo_listing_model.dart';
import '../services/ngo_listing_service.dart';
import '../screens/ngo_feedback_list_screen.dart';
import '../screens/ngo_feedback_screen.dart';

class NgoListingScreen extends StatefulWidget {
  const NgoListingScreen({super.key});

  @override
  State<NgoListingScreen> createState() => _NgoListingScreenState();
}

class _NgoListingScreenState extends State<NgoListingScreen> {
  final NgoListingService _ngoService = NgoListingService();
  final TextEditingController _searchController = TextEditingController();
  late TextEditingController _locationFilterController;
  
  List<NgoListingModel> _ngos = [];
  List<NgoListingModel> _filteredNgos = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filters
  List<String> _selectedCategories = [];
  String _locationFilter = '';
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _locationFilterController = TextEditingController(text: _locationFilter);
    _loadNgos();
  }
  
  Future<void> _loadNgos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final ngos = await _ngoService.getNgos();
      setState(() {
        _ngos = ngos;
        _filteredNgos = ngos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load NGOs: $e';
        _isLoading = false;
      });
    }
  }
  
  void _applyFilters() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // If there's a search query, use the search method
      if (_searchQuery.isNotEmpty) {
        final searchResults = await _ngoService.searchNgos(_searchQuery);
        
        // Apply additional category filters if selected
        if (_selectedCategories.isNotEmpty) {
          _filteredNgos = searchResults.where((ngo) {
            return ngo.categories.any((category) => _selectedCategories.contains(category));
          }).toList();
        } else {
          _filteredNgos = searchResults;
        }
        
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // If no search query but have filters
      if (_selectedCategories.isNotEmpty || _locationFilter.isNotEmpty) {
        final filteredNgos = await _ngoService.getFilteredNgos(
          categories: _selectedCategories.isEmpty ? null : _selectedCategories,
          location: _locationFilter.isEmpty ? null : _locationFilter,
        );
        
        setState(() {
          _filteredNgos = filteredNgos;
          _isLoading = false;
        });
        return;
      }
      
      // No filters applied, show all NGOs
      setState(() {
        _filteredNgos = _ngos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to filter NGOs: $e';
        _isLoading = false;
      });
    }
  }
  
  void _performSearch(String value) async {
    setState(() {
      _searchQuery = value.trim();
      _isLoading = true;
    });
    
    try {
      if (_searchQuery.isEmpty) {
        // If search is cleared, apply just the category filters if any
        if (_selectedCategories.isNotEmpty) {
          final filteredNgos = await _ngoService.getFilteredNgos(
            categories: _selectedCategories,
          );
          
          setState(() {
            _filteredNgos = filteredNgos;
            _isLoading = false;
          });
        } else {
          // If no categories selected, show all NGOs
          setState(() {
            _filteredNgos = _ngos;
            _isLoading = false;
          });
        }
      } else {
        // Search by name, location, or category
        final searchResults = await _ngoService.searchNgos(_searchQuery);
        
        // Apply additional category filters if selected
        if (_selectedCategories.isNotEmpty) {
          _filteredNgos = searchResults.where((ngo) {
            return ngo.categories.any((category) => _selectedCategories.contains(category));
          }).toList();
        } else {
          _filteredNgos = searchResults;
        }
        
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search NGOs: $e';
        _isLoading = false;
      });
    }
  }
  
  void _openFilterDialog() {
    // Update the location filter controller text before showing the dialog
    _locationFilterController.text = _locationFilter;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter NGOs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: NgoCategory.getCategories().map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.deepPurple.shade100,
                      checkmarkColor: Colors.deepPurple,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationFilterController,
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setModalState(() {
                      _locationFilter = value.trim();
                    });
                  },
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategories = [];
                            _locationFilter = '';
                            _locationFilterController.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search NGOs by name, location, or category...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _applyFilters();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          
          // Selected filters display
          if (_selectedCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _selectedCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(category),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedCategories.remove(category);
                          });
                          _applyFilters();
                        },
                        backgroundColor: Colors.deepPurple.shade100,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          
          // Loading indicator or error message
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadNgos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          // NGO list
          else if (_filteredNgos.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No NGOs found matching your criteria'),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadNgos,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredNgos.length,
                  itemBuilder: (context, index) {
                    final ngo = _filteredNgos[index];
                    return _buildNgoCard(ngo);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildNgoCard(NgoListingModel ngo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NgoDetailScreen(ngoId: ngo.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with image (if available) and organization name
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: ngo.profileImagePath != null
                            ? NetworkImage(ngo.profileImagePath!)
                            : null,
                        child: ngo.profileImagePath == null
                            ? const Icon(Icons.business, size: 40, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ngo.organizationName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ngo.location,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          if (ngo.rating != null)
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(
                                  ' ${ngo.rating!.toStringAsFixed(1)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // NGO details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ngo.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ngo.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (ngo.donationsReceived != null)
                        Text(
                          '${ngo.donationsReceived} donations received',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NgoDetailScreen(ngoId: ngo.id),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _locationFilterController.dispose();
    super.dispose();
  }
}

class NgoDetailScreen extends StatefulWidget {
  final String ngoId;
  
  const NgoDetailScreen({
    super.key,
    required this.ngoId,
  });

  @override
  State<NgoDetailScreen> createState() => _NgoDetailScreenState();
}

class _NgoDetailScreenState extends State<NgoDetailScreen> {
  final NgoListingService _ngoService = NgoListingService();
  
  NgoListingModel? _ngo;
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadNgoDetails();
  }
  
  Future<void> _loadNgoDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final ngo = await _ngoService.getNgoDetails(widget.ngoId);
      setState(() {
        _ngo = ngo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load NGO details: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('NGO Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('NGO Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNgoDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_ngo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('NGO Details')),
        body: const Center(
          child: Text('NGO not found or no longer available'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_ngo!.organizationName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.deepPurple.shade50,
              child: _ngo!.profileImagePath != null
                  ? Image.network(
                      _ngo!.profileImagePath!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            
            // NGO information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _ngo!.organizationName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_ngo!.rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 16),
                              Text(
                                ' ${_ngo!.rating!.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact Person: ${_ngo!.name}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _ngo!.location,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ngo!.description.isEmpty
                        ? 'No description available'
                        : _ngo!.description,
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ngo!.categories.isEmpty
                        ? [const Chip(label: Text('General'))]
                        : _ngo!.categories.map((category) {
                            return Chip(
                              label: Text(category),
                              backgroundColor: Colors.deepPurple.shade50,
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (_ngo!.donationsReceived != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.volunteer_activism, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${_ngo!.donationsReceived} donations received',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Add a button to view ratings
                  Row(
                    children: [
                      const Icon(Icons.star_rate, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            // Debug line to print the NGO data
                            print('NGO Data - Rating: ${_ngo!.rating}, Feedback Count: ${_ngo!.feedbackCount}');
                            
                            // First check if there are ratings (feedback count greater than 0)
                            if (_ngo!.feedbackCount != null && _ngo!.feedbackCount! > 0) {
                              return Text(
                                'Rating: ${_ngo!.rating?.toStringAsFixed(1) ?? '0.0'} / 5.0 (${_ngo!.feedbackCount} ${_ngo!.feedbackCount == 1 ? 'review' : 'reviews'})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else {
                              return const Text(
                                'No ratings yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          }
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NGOFeedbackListScreen(),
                              settings: RouteSettings(arguments: _ngo),
                            ),
                          ).then((_) => _loadNgoDetails()); // Refresh after returning from feedback list
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                        ),
                        child: const Text('See reviews'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Rate this NGO'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NGOFeedbackScreen(),
                            settings: RouteSettings(arguments: _ngo),
                          ),
                        );
                        
                        // If rating was submitted, refresh the NGO details to show updated rating
                        if (result == true) {
                          _loadNgoDetails();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to donation screen
                        Navigator.pushNamed(
                          context,
                          '/create-donation',
                          arguments: {'ngoId': _ngo!.id},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Donate to this NGO',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}