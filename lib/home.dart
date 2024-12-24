import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'news.dart';
import 'search.dart';
import 'categories.dart';
import 'bookmarks.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final List<Article> newsData;

  const HomePage({super.key, required this.newsData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavigationBarIndex = 0;
  List<Article> newsData = [];
  final List<Widget> _pages = [];
  bool _isNewsFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isNewsFetched) {
      getNewsData();
      _isNewsFetched = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const Center(child: CircularProgressIndicator()),
      const SearchPage(),
      CategoriesPage(),
      const BookmarksPage()
    ]);
  }

  Future<void> getNewsData() async {
    NewsAPI newsAPI = NewsAPIProvider
        .of(context)
        .newsAPI;
    List<Article> fetchedNewsData = await getNewsWithCategory(newsAPI);

    if (context.mounted) {
      setState(() {
        newsData.addAll(fetchedNewsData);
        _pages[0] = NewsPage(newsData: newsData);
      });
    }
  }

  void _onSelected(index) {
    setState(() {
      _bottomNavigationBarIndex = index;
    });
  }

  void _onPressProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const ProfilePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Echo News',
            style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w800)),
        flexibleSpace: const FlexibleSpaceBar(
          background: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.red, Colors.orange],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft))),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => _onPressProfile(context),
            icon: const Icon(Icons.person_2_sharp)),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: _pages[_bottomNavigationBarIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Bookmarks')
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: _bottomNavigationBarIndex,
        onTap: _onSelected,
        showUnselectedLabels: true,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future<void> _onPressSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      _navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
            onPressed: () => _onPressSignOut(context),
            child: const Text("Sign Out")),
      ),
    );
  }
}