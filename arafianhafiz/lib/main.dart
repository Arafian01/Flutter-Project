import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//================== UTILS & DUMMY DATA ==================
class Utils {
  static GlobalKey<NavigatorState> mainAppNav = GlobalKey<NavigatorState>();

  // Tema warna
  static const Color mainColor = Color(0xFFFF5656);
  static const Color mainDark = Color(0xFFB22222);

  // Aset gambar lokal (pastikan file-file berikut ada di folder assets/images/)
  static const String foodLogo = 'assets/images/logo.jpg';
  static const String foodPromo1 = 'assets/images/food_promo1.jpg';
  static const String foodPromo2 = 'assets/images/food_promo2.jpg';
  static const String foodPromo3 = 'assets/images/food_promo3.jpg';
  static const String foodTitleCart = 'assets/images/food_title_cart.jpg';

  // Data dummy untuk daftar Food
  static List<FoodModel> foodItems = [
    FoodModel(
      food_id: '1',
      foodName: 'Roti Manis',
      food_category: 'Bread',
      food_weight: '200g',
      food_type: 'Snack',
      food_description: 'Roti manis lezat untuk sarapan atau cemilan.',
      food_image: 'assets/images/roti_manis.jpg',
      food_quantity: '3.50',
    ),
    FoodModel(
      food_id: '2',
      foodName: 'Pizza Margherita',
      food_category: 'Pizza',
      food_weight: '500g',
      food_type: 'Main Course',
      food_description: 'Pizza klasik dengan keju mozzarella dan saus tomat.',
      food_image: 'assets/images/pizza_margherita.jpg',
      food_quantity: '8.99',
    ),
    FoodModel(
      food_id: '3',
      foodName: 'Martabak Telur',
      food_category: 'Martabak',
      food_weight: '350g',
      food_type: 'Snack',
      food_description: 'Martabak telur gurih dengan isian daging dan sayuran.',
      food_image: 'assets/images/martabak_telur.jpg',
      food_quantity: '5.50',
    ),
    FoodModel(
      food_id: '4',
      foodName: 'Pisang Goreng',
      food_category: 'Fritter',
      food_weight: '150g',
      food_type: 'Snack',
      food_description: 'Pisang goreng renyah dengan taburan gula.',
      food_image: 'assets/images/pisang_goreng.jpg',
      food_quantity: '2.99',
    ),
    FoodModel(
      food_id: '5',
      foodName: 'Bakso Sapi',
      food_category: 'Meatball',
      food_weight: '300g',
      food_type: 'Main Course',
      food_description: 'Bakso sapi kenyal dengan kuah kaldu gurih.',
      food_image: 'assets/images/bakso_sapi.jpg',
      food_quantity: '6.50',
    ),
  ];
}

//================== MODELS ==================
class FoodModel {
  final String food_id;
  final String foodName;
  final String food_category;
  final String food_weight;
  final String food_type;
  final String food_description;
  final String food_image;
  final String food_quantity;

  FoodModel({
    required this.food_id,
    required this.foodName,
    required this.food_category,
    required this.food_weight,
    required this.food_type,
    required this.food_description,
    required this.food_image,
    required this.food_quantity,
  });
}

// Model untuk item di keranjang dengan quantity
class FoodCartItem {
  final FoodModel food;
  int quantity;
  FoodCartItem({required this.food, this.quantity = 1});
}

// Model untuk filter bar (kategori)
class FoodFilterBarItem {
  final String id;
  final String label;
  FoodFilterBarItem({required this.id, required this.label});
}

//================== PROVIDERS ==================

// Provider untuk mengelola daftar food, filtering, dan navigasi detail
class FoodService extends ChangeNotifier {
  List<FoodFilterBarItem> filterBarItems = [
    FoodFilterBarItem(id: 'all', label: 'All'),
    FoodFilterBarItem(id: 'Bread', label: 'Bread'),
    FoodFilterBarItem(id: 'Pizza', label: 'Pizza'),
    FoodFilterBarItem(id: 'Martabak', label: 'Martabak'),
    FoodFilterBarItem(id: 'Fritter', label: 'Fritter'),
    FoodFilterBarItem(id: 'Meatball', label: 'Meatball'),
  ];
  String selectedFoodCategory = 'all';
  List<FoodModel> filteredFoods = [];

  // Food yang dipilih untuk detail
  late FoodModel selectedFood;

  FoodService() {
    filteredFoods = List.from(Utils.foodItems);
  }

  void filteredFoodsByCategory(String category) {
    selectedFoodCategory = category;
    if (category == 'all') {
      filteredFoods = List.from(Utils.foodItems);
    } else {
      filteredFoods = Utils.foodItems
          .where((food) => food.food_category == category)
          .toList();
    }
    notifyListeners();
  }

  void onFoodSelected(FoodModel food) {
    selectedFood = food;
    Navigator.of(Utils.mainAppNav.currentContext!).push(
      MaterialPageRoute(builder: (context) => FoodDetailsPage()),
    );
  }
}

// Provider untuk mengelola keranjang belanja
class FoodShoppingCartService extends ChangeNotifier {
  List<FoodCartItem> cartItems = [];

  void addToCart(FoodModel food) {
    int index = cartItems.indexWhere((item) => item.food.food_id == food.food_id);
    if (index != -1) {
      cartItems[index].quantity++;
    } else {
      cartItems.add(FoodCartItem(food: food, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(FoodModel food) {
    cartItems.removeWhere((item) => item.food.food_id == food.food_id);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  double getTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      double price = double.tryParse(item.food.food_quantity) ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  bool isFoodInCart(FoodModel food) {
    return cartItems.any((item) => item.food.food_id == food.food_id);
  }

  void updateQuantity(FoodModel food, int quantity) {
    int index = cartItems.indexWhere((item) => item.food.food_id == food.food_id);
    if (index != -1) {
      cartItems[index].quantity = quantity;
      notifyListeners();
    }
  }
}

// Provider untuk Favorites
class FoodFavoritesService extends ChangeNotifier {
  List<FoodModel> favorites = [];

  void toggleFavorite(FoodModel food) {
    if (favorites.any((item) => item.food_id == food.food_id)) {
      favorites.removeWhere((item) => item.food_id == food.food_id);
    } else {
      favorites.add(food);
    }
    notifyListeners();
  }

  bool isFavorite(FoodModel food) {
    return favorites.any((item) => item.food_id == food.food_id);
  }
}

// Provider untuk Bottom Bar (jika diperlukan)
class FoodBottomBarSelectionService extends ChangeNotifier {
  String tabSelection = 'home';
  void setTabSelection(String selection) {
    tabSelection = selection;
    notifyListeners();
  }
}

//================== MAIN APPLICATION & PAGES ==================
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodService()),
        ChangeNotifierProvider(create: (_) => FoodShoppingCartService()),
        ChangeNotifierProvider(create: (_) => FoodFavoritesService()),
        ChangeNotifierProvider(create: (_) => FoodBottomBarSelectionService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      debugShowCheckedModeBanner: false,
      navigatorKey: Utils.mainAppNav,
      home: SplashPage(),
    );
  }
}

//----- Splash Page -----
class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => FoodShopMain()),
      );
    });
    return Scaffold(
      body: Container(
        color: Utils.mainColor,
        child: Stack(
          children: [
            Center(child: Icon(Icons.fastfood, size: 90, color: Colors.white)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 80),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//----- Main Page with Drawer, AppBar, and Bottom Navigation -----
class FoodShopMain extends StatefulWidget {
  @override
  _FoodShopMainState createState() => _FoodShopMainState();
}

class _FoodShopMainState extends State<FoodShopMain> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    FoodMainPage(),
    FoodFavoritesPage(),
    FoodShoppingCartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Provider.of<FoodBottomBarSelectionService>(context, listen: false)
          .setTabSelection(index == 0 ? 'home' : index == 1 ? 'favorites' : 'cart');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Utils.mainColor,
          padding: EdgeInsets.all(30),
          child: Center(child: Icon(Icons.fastfood, size: 80, color: Colors.white)),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Utils.mainColor),
        title: Center(child: Image.asset(Utils.foodLogo, width: 120)),
        actions: [
          Consumer<FoodShoppingCartService>(
            builder: (context, cartService, child) {
              return FoodShoppingCartBadge();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Utils.mainDark,
        unselectedItemColor: Utils.mainColor,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

//----- Home Page (Food List) -----
class FoodMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodPager(),
          FoodFilterBar(),
          FoodListView(),
        ],
      ),
    );
  }
}

//----- Food Pager (promo) -----
class FoodPager extends StatefulWidget {
  @override
  _FoodPagerState createState() => _FoodPagerState();
}

class _FoodPagerState extends State<FoodPager> {
  final List<FoodPage> pages = [
    FoodPage(imgUrl: Utils.foodPromo1, logoImgUrl: Utils.foodLogo),
    FoodPage(imgUrl: Utils.foodPromo2, logoImgUrl: Utils.foodLogo),
    FoodPage(imgUrl: Utils.foodPromo3, logoImgUrl: Utils.foodLogo),
  ];
  int currentPage = 0;
  PageController? controller;

  @override
  void initState() {
    controller = PageController(initialPage: 0);
    super.initState();
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(page.imgUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.asset(page.logoImgUrl!, width: 100),
                    ),
                  ),
                );
              },
            ),
          ),
          PageViewIndicator(
            controller: controller,
            numberOfPages: pages.length,
            currentPage: currentPage,
          ),
        ],
      ),
    );
  }
}

class FoodPage {
  final String? imgUrl;
  final String? logoImgUrl;
  FoodPage({this.imgUrl, this.logoImgUrl});
}

class PageViewIndicator extends StatelessWidget {
  final PageController? controller;
  final int numberOfPages;
  final int currentPage;
  PageViewIndicator({this.controller, required this.numberOfPages, required this.currentPage});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numberOfPages, (index) {
        return GestureDetector(
          onTap: () {
            controller!.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            width: 15,
            height: 15,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: currentPage == index ? Utils.mainColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}

//----- Food Filter Bar -----
class FoodFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Consumer<FoodService>(
        builder: (context, foodService, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: foodService.filterBarItems.map((item) {
              return GestureDetector(
                onTap: () {
                  foodService.filteredFoodsByCategory(item.id);
                },
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: foodService.selectedFoodCategory == item.id ? Utils.mainColor : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

//----- Food List View -----
class FoodListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FoodService>(
      builder: (context, foodService, child) {
        return Container(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodService.filteredFoods.length,
            itemBuilder: (context, index) {
              return FoodCard(foodInfo: foodService.filteredFoods[index]);
            },
          ),
        );
      },
    );
  }
}

//----- Food Card -----
class FoodCard extends StatelessWidget {
  final FoodModel? foodInfo;
  FoodCard({this.foodInfo});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<FoodService>(context, listen: false).onFoodSelected(foodInfo!);
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar di paling atas dengan top rounded (sesuai card)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.asset(
                foodInfo!.food_image,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  // Harga di bawah
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Utils.mainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('\$${foodInfo!.food_quantity}',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
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

//----- Food Shopping Cart Badge -----
class FoodShoppingCartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FoodShoppingCartService>(
      builder: (context, cartService, child) {
        if (cartService.cartItems.isEmpty) {
          return SizedBox();
        }
        return Transform.scale(
          scale: 0.7,
          child: Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Utils.mainColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Text('${cartService.cartItems.length}',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(Icons.shopping_cart, size: 25, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}

//----- Food Details Page -----
// Detail page menampilkan gambar (dengan gradient overlay di bawah), field tambahan (weight, category, type, description),
// tombol Add To Cart dan tombol Favorite yang berfungsi (nama dihapus karena sudah ada di AppBar)
class FoodDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final foodService = Provider.of<FoodService>(context, listen: false);
    final selectedFood = foodService.selectedFood;
    final favoritesService = Provider.of<FoodFavoritesService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Utils.mainDark),
        title: Container(), // Nama dihapus karena sudah ada di topbar
        actions: [
          IconButton(
            icon: Consumer<FoodFavoritesService>(
              builder: (context, favService, child) {
                bool isFav = favService.isFavorite(selectedFood);
                return Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Utils.mainColor,
                );
              },
            ),
            onPressed: () {
              favoritesService.toggleFavorite(selectedFood);
            },
          ),
          FoodShoppingCartBadge(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar produk dengan gradient overlay di bagian bawah (mirip detail donut)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40)),
                  child: Image.asset(
                    selectedFood.food_image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Detail informasi (tanpa nama, karena sudah ada di AppBar)
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weight: ${selectedFood.food_weight}',
                      style: TextStyle(fontSize: 16, color: Utils.mainDark)),
                  SizedBox(height: 5),
                  Text('Category: ${selectedFood.food_category}',
                      style: TextStyle(fontSize: 16, color: Utils.mainDark)),
                  SizedBox(height: 5),
                  Text('Type: ${selectedFood.food_type}',
                      style: TextStyle(fontSize: 16, color: Utils.mainDark)),
                  SizedBox(height: 10),
                  Text(
                    selectedFood.food_description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Utils.mainDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${selectedFood.food_quantity}',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Consumer<FoodShoppingCartService>(
                        builder: (context, cartService, child) {
                          bool inCart = cartService.isFoodInCart(selectedFood);
                          return inCart
                              ? Text('Added to Cart',
                              style: TextStyle(
                                  color: Utils.mainDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))
                              : ElevatedButton(
                            onPressed: () {
                              cartService.addToCart(selectedFood);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Utils.mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text('Add To Cart'),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//----- Food Favorites Page -----
class FoodFavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FoodFavoritesService>(
      builder: (context, favService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Favorites', style: TextStyle(color: Utils.mainDark)),
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Utils.mainDark),
          ),
          body: favService.favorites.isEmpty
              ? Center(child: Text('No favorites yet!', style: TextStyle(fontSize: 20, color: Utils.mainColor)))
              : ListView.builder(
            itemCount: favService.favorites.length,
            itemBuilder: (context, index) {
              FoodModel food = favService.favorites[index];
              return ListTile(
                leading: Image.asset(food.food_image, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(food.foodName),
                subtitle: Text('\$${food.food_quantity}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Utils.mainDark),
                  onPressed: () {
                    favService.toggleFavorite(food);
                  },
                ),
                onTap: () {
                  Provider.of<FoodService>(context, listen: false).onFoodSelected(food);
                },
              );
            },
          ),
        );
      },
    );
  }
}

//----- Food Shopping Cart Page -----
class FoodShoppingCartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart', style: TextStyle(color: Utils.mainDark)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Utils.mainDark),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(Utils.foodTitleCart, width: 170),
            Expanded(
              child: Consumer<FoodShoppingCartService>(
                builder: (context, cartService, child) {
                  if (cartService.cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.grey[300], size: 50),
                          SizedBox(height: 20),
                          Text('Your cart is empty!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: cartService.cartItems.length,
                    itemBuilder: (context, index) {
                      FoodCartItem cartItem = cartService.cartItems[index];
                      return FoodShoppingListRow(
                        cartItem: cartItem,
                        onDeleteRow: () {
                          cartService.removeFromCart(cartItem.food);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<FoodShoppingCartService>(
              builder: (context, cartService, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cartService.cartItems.isEmpty
                        ? SizedBox()
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: TextStyle(color: Utils.mainDark)),
                        Text(
                          '\$${cartService.getTotal().toStringAsFixed(2)}',
                          style: TextStyle(color: Utils.mainDark, fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Material(
                        color: cartService.cartItems.isEmpty ? Colors.grey[200] : Utils.mainColor.withOpacity(0.2),
                        child: InkWell(
                          splashColor: Utils.mainDark.withOpacity(0.2),
                          highlightColor: Utils.mainDark.withOpacity(0.5),
                          onTap: cartService.cartItems.isEmpty ? null : () { cartService.clearCart(); },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.delete_forever, color: cartService.cartItems.isEmpty ? Colors.grey : Utils.mainDark),
                                SizedBox(width: 5),
                                Text('Clear Cart', style: TextStyle(color: cartService.cartItems.isEmpty ? Colors.grey : Utils.mainDark)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//----- Food Shopping List Row (with quantity adjustment) -----
class FoodShoppingListRow extends StatelessWidget {
  final FoodCartItem? cartItem;
  final Function? onDeleteRow;
  FoodShoppingListRow({this.cartItem, required this.onDeleteRow});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Image.asset(cartItem!.food.food_image, width: 80, height: 80, fit: BoxFit.cover),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem!.food.foodName,
                    style: TextStyle(color: Utils.mainDark, fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: Utils.mainDark.withOpacity(0.2)),
                  ),
                  child: Text('\$${cartItem!.food.food_quantity}',
                      style: TextStyle(color: Utils.mainDark.withOpacity(0.4), fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        int newQty = cartItem!.quantity > 1 ? cartItem!.quantity - 1 : 1;
                        Provider.of<FoodShoppingCartService>(context, listen: false)
                            .updateQuantity(cartItem!.food, newQty);
                      },
                      icon: Icon(Icons.remove_circle_outline, color: Utils.mainDark),
                    ),
                    Text('${cartItem!.quantity}', style: TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () {
                        int newQty = cartItem!.quantity + 1;
                        Provider.of<FoodShoppingCartService>(context, listen: false)
                            .updateQuantity(cartItem!.food, newQty);
                      },
                      icon: Icon(Icons.add_circle_outline, color: Utils.mainDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              onDeleteRow!();
            },
            icon: Icon(Icons.delete_forever, color: Utils.mainColor),
          ),
        ],
      ),
    );
  }
}
