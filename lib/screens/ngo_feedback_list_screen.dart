import 'package:flutter/material.dart';
import '../models/ngo_listing_model.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';
import 'ngo_feedback_screen.dart';

class NGOFeedbackListScreen extends StatefulWidget {
  const NGOFeedbackListScreen({super.key});

  @override
  State<NGOFeedbackListScreen> createState() => _NGOFeedbackListScreenState();
}

class _NGOFeedbackListScreenState extends State<NGOFeedbackListScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isLoading = true;
  List<FeedbackModel> _feedbackList = [];
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    final ngo = ModalRoute.of(context)!.settings.arguments as NgoListingModel;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final feedbackList = await _feedbackService.getFeedbackForNgo(ngo.id);
      setState(() {
        _feedbackList = feedbackList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load feedback: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addRating() async {
    final ngo = ModalRoute.of(context)!.settings.arguments as NgoListingModel;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NGOFeedbackScreen(),
        settings: RouteSettings(arguments: ngo),
      ),
    );

    if (result == true) {
      _loadFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngo = ModalRoute.of(context)!.settings.arguments as NgoListingModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('${ngo.organizationName} Reviews'),
      ),
      body: Column(
        children: [
          // Rating summary card
          _buildRatingSummary(ngo),
          
          // Feedback list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadFeedback,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _feedbackList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No reviews yet'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _addRating,
                                  child: const Text('Be the first to review'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadFeedback,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _feedbackList.length,
                              itemBuilder: (context, index) {
                                return _buildFeedbackCard(_feedbackList[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRating,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.rate_review),
      ),
    );
  }

  Widget _buildRatingSummary(NgoListingModel ngo) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Average Rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        ngo.rating?.toStringAsFixed(1) ?? '0.0',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ngo.feedbackCount ?? _feedbackList.length} ${(ngo.feedbackCount ?? _feedbackList.length) == 1 ? 'review' : 'reviews'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            ngo.rating != null && index < ngo.rating!.round() 
                                ? Icons.star 
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add your rating',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    feedback.donorName.isNotEmpty
                        ? feedback.donorName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: Colors.deepPurple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.donorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(feedback.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < feedback.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                feedback.comment!,
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}