import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import 'dart:math' as math;

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  late TabController _tabController;
  Map<String, dynamic> _analyticsData = {};
  String _userRole = 'donor';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalytics();
    _getUserRole();
    
    // Add listener to update UI when tab changes
    _tabController.addListener(() {
      setState(() {});  // Rebuild UI whenever tab controller changes
    });
  }

  Future<void> _getUserRole() async {
    final userModel = await _authService.getCurrentUserModel();
    if (userModel != null && mounted) {
      setState(() {
        _userRole = userModel.role.toLowerCase();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() => _isLoading = true);
      final data = await _analyticsService.getAllAnalytics();
      if (mounted) {
        setState(() {
          _analyticsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About analytics',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Analytics'),
                  content: const Text(
                    'Analytics dashboard shows your donation impact and trends. '
                    'Data is updated in real-time as donations are made and processed.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildTabItem(0, 'Overview', Icons.dashboard),
                  const SizedBox(width: 16),
                  _buildTabItem(1, 'Donation Trends', Icons.trending_up),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading analytics...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAnalytics,
                    color: Colors.deepPurple,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildTrendsTab(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _tabController.index == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabController.animateTo(index)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withOpacity(0.2) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final impact = _analyticsData['impact'] as Map<String, dynamic>? ?? {};
    final trends = _analyticsData['trends'] as Map<String, dynamic>? ?? {};
    final totalDonations = trends['totalDonations'] as int? ?? 0;
    final completedDonations = impact['completedDonations'] as int? ?? 0;
    final uniquePartners = impact['uniquePartners'] as int? ?? 0;
    final estimatedImpact = impact['estimatedImpact'] as int? ?? 0;
    
    final String partnerLabel = _userRole == 'ngo' ? 'Unique Donors' : 'NGOs Supported';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Impact Summary',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _buildImpactCard(
          totalDonations,
          completedDonations,
          uniquePartners,
          estimatedImpact,
          partnerLabel,
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildRecentActivitySummary(),
        const SizedBox(height: 24),
        _buildQuickSummaryCharts(),
      ],
    );
  }

  Widget _buildImpactCard(
    int totalDonations,
    int completedDonations,
    int uniquePartners,
    int estimatedImpact,
    String partnerLabel,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Impact',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactMetricItem(
                    Icons.card_giftcard,
                    totalDonations.toString(),
                    'Total Donations',
                  ),
                ),
                Expanded(
                  child: _buildImpactMetricItem(
                    Icons.check_circle,
                    completedDonations.toString(),
                    'Completed',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactMetricItem(
                    Icons.people,
                    uniquePartners.toString(),
                    partnerLabel,
                  ),
                ),
                Expanded(
                  child: _buildImpactMetricItem(
                    Icons.favorite,
                    estimatedImpact.toString(),
                    'People Helped',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySummary() {
    final trends = _analyticsData['trends'] as Map<String, dynamic>? ?? {};
    final statusCounts = trends['statusCounts'] as Map<String, dynamic>? ?? {};
    
    int pendingCount = statusCounts['pending'] as int? ?? 0;
    int acceptedCount = statusCounts['accepted'] as int? ?? 0;
    int completedCount = statusCounts['completed'] as int? ?? 0;
    int rejectedCount = statusCounts['rejected'] as int? ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatusProgressBar(
              'Pending',
              pendingCount,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildStatusProgressBar(
              'Accepted',
              acceptedCount,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildStatusProgressBar(
              'Completed',
              completedCount,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildStatusProgressBar(
              'Rejected',
              rejectedCount,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusProgressBar(String label, int count, Color color) {
    final trends = _analyticsData['trends'] as Map<String, dynamic>? ?? {};
    final totalDonations = trends['totalDonations'] as int? ?? 1; // Avoid division by zero
    final percentage = totalDonations > 0 ? (count / totalDonations * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$count (${percentage.toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildQuickSummaryCharts() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 250, // Increased height to accommodate legend
              child: _buildCategoryPieChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    final trends = _analyticsData['trends'] as Map<String, dynamic>? ?? {};
    final monthlyTrends = trends['monthlyTrends'] as Map<String, dynamic>? ?? {};
    
    // Sort months chronologically
    final sortedMonths = monthlyTrends.keys.toList()
      ..sort();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Donation Trends Over Time',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 300,
              child: _buildMonthlyTrendsChart(sortedMonths, monthlyTrends),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Monthly Breakdown',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...sortedMonths.map((month) {
          final count = monthlyTrends[month] as int? ?? 0;
          final parts = month.split('-');
          final year = parts[0];
          final monthNum = int.parse(parts[1]);
          final monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];
          final monthName = monthNames[monthNum - 1];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('$monthName $year'),
              trailing: Chip(
                label: Text('$count donations'),
                backgroundColor: Colors.deepPurple.shade100,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryPieChart() {
    final trends = _analyticsData['trends'] as Map<String, dynamic>? ?? {};
    final categoryTrends = trends['categoryTrends'] as Map<String, dynamic>? ?? {};
    
    if (categoryTrends.isEmpty) {
      return const Center(child: Text('No category data available'));
    }
    
    final categories = categoryTrends.keys.toList();
    final categoryColors = {
      'Food': Colors.green,
      'Clothes': Colors.blue,
      'Books': Colors.orange,
      'Electronics': Colors.purple,
      'Furniture': Colors.brown,
      'Medicine': Colors.red,
      'Toys': Colors.pink,
      'Money': Colors.amber,
      'Other': Colors.grey,
    };
    
    // Calculate totals for percentages
    final total = categoryTrends.values.fold<int>(
      0, (sum, count) => sum + (count as int));
    
    // Create a list to track assigned colors for the legend
    final Map<String, Color> assignedColors = {};
    
    // Build the pie chart sections
    final sections = categories.map((category) {
      final value = categoryTrends[category] as int;
      final percentage = total > 0 ? (value / total) : 0;
      
      final color = categoryColors[category] ?? 
                Colors.primaries[categories.indexOf(category) % Colors.primaries.length];
      
      // Save the assigned color for the legend
      assignedColors[category] = color;
                
      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 90, // Slightly smaller to accommodate legend
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart title removed as it's redundant with the card title
        const SizedBox(height: 10),
        // Fixed height container for the pie chart
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 20,
              sections: sections,
            ),
          ),
        ),
        // Add more space between the chart and legend
        const SizedBox(height: 18),
        // Legend title
        const Text(
          'Categories:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Legend with better spacing
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: categories.map((category) {
            final value = categoryTrends[category] as int;
            final percentage = total > 0 ? (value / total * 100) : 0;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: assignedColors[category],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$category (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendsChart(
    List<String> sortedMonths, 
    Map<String, dynamic> monthlyTrends,
  ) {
    if (sortedMonths.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                  final month = sortedMonths[value.toInt()];
                  final parts = month.split('-');
                  return Text(
                    '${parts[1]}/${parts[0].substring(2)}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: sortedMonths.length.toDouble() - 1,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(sortedMonths.length, (index) {
              final month = sortedMonths[index];
              final count = monthlyTrends[month] as int;
              return FlSpot(index.toDouble(), count.toDouble());
            }),
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.deepPurple.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}