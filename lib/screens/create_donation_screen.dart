import 'package:flutter/material.dart';
import '../services/donation_service.dart';
import '../services/ngo_listing_service.dart';
import '../models/ngo_listing_model.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _donationService = DonationService();
  final _ngoListingService = NgoListingService();
  String _selectedCategory = 'Food';
  final _categories = ['Food', 'Clothes', 'Books', 'Blood', 'Other'];
  bool _isLoading = false;
  bool _isLoadingNgos = true;
  NgoListingModel? _selectedNgo;
  List<NgoListingModel> _ngos = [];

  // Track if we came from the NGO directory screen with a pre-selected NGO
  bool _wasNgoPreselected = false;

  @override
  void initState() {
    super.initState();
    _loadNgos();
    // Will handle any NGO ID passed as arguments when the widget is built
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if we were given a specific NGO to pre-select from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && args.containsKey('ngoId')) {
      final ngoId = args['ngoId'] as String;
      _wasNgoPreselected = true; // Flag that we came from NGO directory
      
      // Only try to pre-select if we don't already have a selection and NGOs are loaded
      if (_selectedNgo == null && !_isLoadingNgos && _ngos.isNotEmpty) {
        // Find the NGO in our list by ID
        final ngo = _ngos.firstWhere(
          (ngo) => ngo.id == ngoId, 
          orElse: () => _ngos.first
        );
        
        setState(() {
          _selectedNgo = ngo;
        });
      }
    }
  }

  Future<void> _loadNgos() async {
    setState(() => _isLoadingNgos = true);
    try {
      final ngos = await _ngoListingService.getNgos();
      if (mounted) {
        setState(() {
          _ngos = ngos;
          _isLoadingNgos = false;
        });
        
        // Check if we need to pre-select an NGO after loading
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args != null && args is Map<String, dynamic> && args.containsKey('ngoId')) {
          final ngoId = args['ngoId'] as String;
          if (_selectedNgo == null && ngos.isNotEmpty) {
            // Set the pre-selected flag
            _wasNgoPreselected = true;
            
            // Find the NGO in our list by ID
            try {
              final ngo = ngos.firstWhere(
                (ngo) => ngo.id == ngoId,
              );
              
              setState(() {
                _selectedNgo = ngo;
              });
            } catch (e) {
              // If no matching NGO is found, just use the first one
              if (ngos.isNotEmpty) {
                setState(() {
                  _selectedNgo = ngos.first;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading NGOs: $e')),
        );
        setState(() => _isLoadingNgos = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedNgo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an NGO to donate to')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _donationService.createDonation(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        ngoId: _selectedNgo!.id,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating donation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Donation')),
      body: _isLoadingNgos 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // If NGO was pre-selected, show the selected NGO instead of selection list
                    if (_wasNgoPreselected && _selectedNgo != null) ...[
                      Text(
                        'Donating to:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.deepPurple.shade50,
                        child: ListTile(
                          title: Text(
                            _selectedNgo!.organizationName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${_selectedNgo!.categories.join(", ")} • ${_selectedNgo!.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: _selectedNgo!.profileImagePath != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(_selectedNgo!.profileImagePath!),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.deepPurple.shade100,
                                  child: const Icon(Icons.business),
                                ),
                          trailing: const Icon(Icons.check_circle, color: Colors.deepPurple),
                        ),
                      ),
                    ] else ...[
                      // Original NGO selection section
                      const Text(
                        'Select NGO to donate to:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNgoSelection(),
                    ],
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Location (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Address where item can be picked up',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitDonation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Submit Donation'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildNgoSelection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _ngos.isEmpty
          ? const Center(child: Text('No NGOs available'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _ngos.length,
              itemBuilder: (context, index) {
                final ngo = _ngos[index];
                final isSelected = _selectedNgo?.id == ngo.id;
                
                return Card(
                  elevation: 1,
                  color: isSelected ? Colors.deepPurple.shade50 : null,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      ngo.organizationName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${ngo.categories.join(", ")} • ${ngo.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: ngo.profileImagePath != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(ngo.profileImagePath!),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: const Icon(Icons.business),
                          ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.deepPurple)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedNgo = ngo;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
