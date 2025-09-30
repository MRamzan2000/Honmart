import 'dart:io';
import 'package:app/pages/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const HonmartApp());
}

class HonmartApp extends StatelessWidget {
  const HonmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Honmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WebViewController _controller;
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _hasInternet = true;

  final List<String> _urls = [
    "https://honmartshop.com/",
    "https://honmartshop.com/shop/",
    "https://honmartshop.com/cart/",
    "https://honmartshop.com/my-account/",
  ];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    Connectivity().onConnectivityChanged.listen((status) {
      _checkInternet();
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_urls[_selectedIndex]));
  }

  /// ✅ Check actual internet by pinging Google
  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() => _hasInternet = false);
    } else {
      try {
        final lookup = await InternetAddress.lookup("google.com");
        if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
          setState(() => _hasInternet = true);
        } else {
          setState(() => _hasInternet = false);
        }
      } on SocketException catch (_) {
        setState(() => _hasInternet = false);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(_urls[index]));
  }

  Future<void> _reloadPage() async {
    await _checkInternet();
    if (_hasInternet) {
      await _controller.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2b7cef), // ✅ Client requested color
      body: !_hasInternet
          ? _buildNoInternetScreen()
          : Stack(
        children: [
          // ✅ WebView tab visible hoga jab page load complete ho
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: RefreshIndicator(
                onRefresh: _reloadPage,
                child: WebViewWidget(controller: _controller),
              ),
            ),

          // ✅ Loader tab show hoga jab page load ho raha ho
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            "No Internet Connection",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _reloadPage,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("Retry", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
    );
  }
}
