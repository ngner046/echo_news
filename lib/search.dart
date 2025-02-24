import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:intl/intl.dart';
import 'news.dart';
import 'news_api_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = "publishedAt";
  final Map<String, String> _sortOptions = {
    'relevancy': 'Relevancy',
    'popularity': 'Popularity',
    'publishedAt': 'Published At'
  };

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          _fromDate = pickedDate;
        } else {
          _toDate = pickedDate;
        }
      });
    }
  }

  Future<void> _navigateToSearchedContentPage(
      BuildContext context, String query) async {
    final NewsAPI newsAPI = NewsAPIProvider.of(context).newsAPI;
    List<News> newsData = await getNewsWithSearch(newsAPI, query,
        fromDate: _fromDate, toDate: _toDate, sortBy: _sortBy);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SearchContentPage(query: query, newsData: newsData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text("From Date"),
          subtitle: Text(_fromDate == null
              ? "Select a date"
              : DateFormat('yyyy-MM-dd').format(_fromDate!)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _pickDate(context, true),
        ),
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text("To Date"),
          subtitle: Text(_toDate == null
              ? "Select a date"
              : DateFormat('yyyy-MM-dd').format(_toDate!)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _pickDate(context, false),
        ),
        Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.sort),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _sortBy,
              items: _sortOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            )
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          showCursor: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            suffixIcon: Icon(Icons.arrow_back_sharp),
            label: Text("Enter a keyword"),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          onSubmitted: (value) =>
              _navigateToSearchedContentPage(context, value),
        )
      ],
    );
  }
}

class SearchContentPage extends StatelessWidget {
  final String query;
  final List<News> newsData;

  const SearchContentPage(
      {super.key, required this.query, required this.newsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(query, style: Theme.of(context).textTheme.headlineSmall),
        flexibleSpace: const FlexibleSpaceBar(
          background: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: NewsPage(newsData: newsData),
    );
  }
}
