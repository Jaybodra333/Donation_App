import 'package:flutter/material.dart';
import '../models/ngo_listing_model.dart';
import '../services/feedback_service.dart';

class NGOFeedbackScreen extends StatefulWidget {
  const NGOFeedbackScreen({super.key});

  @override
  State<NGOFeedbackScreen> createState() => _NGOFeedbackScreenState();
}

class _NGOFeedbackScreenState extends State<NGOFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;
  bool _hasExistingRating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkExistingRating();
  }

  Future<void> _checkExistingRating() async {
    final ngo = ModalRoute.of(context)!.settings.arguments as NgoListingModel;
    try {
      final existingFeedback = await _feedbackService.getUserFeedbackForNgo(ngo.id);
      if (existingFeedback != null) {
        setState(() {
          _hasExistingRating = true;
          _rating = existingFeedback.rating;
          _commentController.text = existingFeedback.comment ?? '';
        });
      }
    } catch (e) {
      print('Error checking existing rating: $e');
    }
  }

  Future<void> _submitFeedback() async {
    final ngo = ModalRoute.of(context)!.settings.arguments as NgoListingModel;
    
    if (_rating == 0) {
      setState(() {
        _errorMessage = 'Please select a rating';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _feedbackService.submitFeedback(
        ngoId: ngo.id,
        rating: _rating,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate successful submission
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit feedback: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ngo = ModalRoute.of(context)!.settings.arguments as NgoListingModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate NGO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate your experience with ${ngo.organizationName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRatingSelector(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Add a comment (optional):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _hasExistingRating ? 'Update Rating' : 'Submit Rating',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            if (_hasExistingRating) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'You have already rated this NGO. Your new rating will replace the previous one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              icon: Icon(
                starValue <= _rating ? Icons.star : Icons.star_border,
                color: starValue <= _rating ? Colors.amber : Colors.grey,
                size: 36,
              ),
              onPressed: () {
                setState(() {
                  _rating = starValue.toDouble();
                  _errorMessage = null;
                });
              },
            );
          }),
        ),
        Center(
          child: Text(
            _getRatingDescription(),
            style: TextStyle(
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingDescription() {
    if (_rating == 0) return 'Tap a star to rate';
    if (_rating == 1) return 'Poor';
    if (_rating == 2) return 'Fair';
    if (_rating == 3) return 'Good';
    if (_rating == 4) return 'Very Good';
    return 'Excellent';
  }
}