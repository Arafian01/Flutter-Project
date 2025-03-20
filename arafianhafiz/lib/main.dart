import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodBottomBarSelectionService()),
        ChangeNotifierProvider(create: (_) => FoodService()),
        ChangeNotifierProvider(create: (_) => FoodShoppingCartService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        navigatorKey: Utils.mainAppNav,
        routes: {
          '/': (context) => SplashPage(),
          '/main': (context) => FoodShopMain(),
          '/details': (context) => FoodDetailsPage(),
          '/shoppingcart': (context) => FoodShoppingCartPage(),
          '/favorites': (context) => FoodFavoritesPage(),
        },
      ),
    ),
  );
}

// 1. Splash Screen
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  AnimationController? foodController;
  Animation<double>? progressAnimation;

  @override
  void initState() {
    super.initState();
    foodController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: foodController!, curve: Curves.linear),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Utils.mainAppNav.currentState!.pushReplacementNamed('/main');
    });
  }
  @override
  void dispose() {
    foodController!.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 100, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Landing Page (FoodShopMain)
class FoodShopMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: FoodSideMenu()),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.red[900]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(Utils.foodLogo, width: 120),
      ),
      body: Column(
        children: [
          Expanded(
            child: Navigator(
              key: Utils.mainListNav,
              initialRoute: '/main',
              onGenerateRoute: (RouteSettings settings) {
                Widget page;
                switch (settings.name) {
                  case '/main':
                    page = FoodMainPage();
                    break;
                  case '/favorites':
                    page = FoodFavoritesPage();
                    break;
                  case '/shoppingcart':
                    page = FoodShoppingCartPage();
                    break;
                  default:
                    page = FoodMainPage();
                    break;
                }
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => page,
                  transitionDuration: Duration(seconds: 0),
                );
              },
            ),
          ),
          FoodBottomBar(),
        ],
      ),
    );
  }
}

// 3. Food Main Page: Menampilkan FoodPager, FoodFilterBar, dan FoodList
class FoodMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoodPager(),
        FoodFilterBar(),
        Expanded(
          child: Consumer<FoodService>(
            builder: (context, foodService, child) {
              return FoodList(foods: foodService.filteredFoods);
            },
          ),
        ),
      ],
    );
  }
}

// 4. FoodPager & PageViewIndicator
class FoodPager extends StatefulWidget {
  @override
  _FoodPagerState createState() => _FoodPagerState();
}
class _FoodPagerState extends State<FoodPager> {
  List<FoodPage> pages = [
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
    controller!.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
              children: List.generate(pages.length, (index) {
                FoodPage page = pages[index];
                return Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(page.imgUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(page.logoImgUrl!, width: 100),
                  ),
                );
              }),
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
            controller!.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            width: 15,
            height: 15,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: currentPage == index ? Colors.red[400] : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}

// 5. FoodSideMenu (Drawer)
class FoodSideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red[900],
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(Utils.foodLogo, width: 100),
          SizedBox(height: 20),
          Text("Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
          // Tambahkan menu lainnya jika diperlukan...
        ],
      ),
    );
  }
}

// 6. FoodBottomBar
class FoodBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Consumer<FoodBottomBarSelectionService>(
        builder: (context, bottomBarSelectionService, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home,
                    color: bottomBarSelectionService.tabSelection == 'main'
                        ? Colors.red[900]
                        : Colors.red[400]),
                onPressed: () {
                  bottomBarSelectionService.setTabSelection('main');
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite,
                    color: bottomBarSelectionService.tabSelection == 'favorites'
                        ? Colors.red[900]
                        : Colors.red[400]),
                onPressed: () {
                  bottomBarSelectionService.setTabSelection('favorites');
                },
              ),
              GestureDetector(
                onTap: () {
                  bottomBarSelectionService.setTabSelection('shoppingcart');
                },
                child: Consumer<FoodShoppingCartService>(
                  builder: (context, cartService, child) {
                    int cartItems = cartService.cartFoods.length;
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cartItems > 0
                            ? (bottomBarSelectionService.tabSelection == 'shoppingcart'
                            ? Colors.red[900]
                            : Colors.red[400])
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        children: [
                          cartItems > 0
                              ? Text(
                            '$cartItems',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                              : SizedBox(height: 10),
                          Icon(Icons.shopping_cart,
                              color: cartItems > 0
                                  ? Colors.white
                                  : (bottomBarSelectionService.tabSelection == 'shoppingcart'
                                  ? Colors.red[900]
                                  : Colors.red[400])),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 7. FoodFilterBar
class FoodFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Consumer<FoodService>(
        builder: (context, foodService, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(foodService.filterBarItems.length, (index) {
              FoodFilterBarItem item = foodService.filterBarItems[index];
              return GestureDetector(
                onTap: () {
                  foodService.filteredFoodsByType(item.id!);
                },
                child: Text(
                  item.label!,
                  style: TextStyle(
                    color: foodService.selectedFoodType == item.id ? Colors.red[400] : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// 8. FoodList & FoodCard
class FoodList extends StatefulWidget {
  final List<FoodModel>? foods;
  FoodList({this.foods});
  @override
  _FoodListState createState() => _FoodListState();
}
class _FoodListState extends State<FoodList> {
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  List<FoodModel> insertedItems = [];

  @override
  void initState() {
    super.initState();
    var future = Future(() {});
    for (var i = 0; i < widget.foods!.length; i++) {
      future = future.then((_) {
        return Future.delayed(Duration(milliseconds: 125), () {
          insertedItems.add(widget.foods![i]);
          _key.currentState!.insertItem(i);
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _key,
      scrollDirection: Axis.horizontal,
      initialItemCount: insertedItems.length,
      itemBuilder: (context, index, animation) {
        FoodModel currentFood = widget.foods![index];
        return SlideTransition(
          position: Tween(begin: Offset(0.2, 0), end: Offset(0, 0)).animate(animation),
          child: FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: FoodCard(foodInfo: currentFood),
          ),
        );
      },
    );
  }
}
class FoodCard extends StatelessWidget {
  final FoodModel? foodInfo;
  FoodCard({this.foodInfo});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var foodService = Provider.of<FoodService>(context, listen: false);
        foodService.onFoodSelected(foodInfo!);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 10, top: 80, right: 10, bottom: 20),
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodInfo!.foodName,
                  style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '\$${foodInfo!.food_quantity}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Hero(
              tag: foodInfo!.foodName,
              child: Image.asset(foodInfo!.foodImage, width: 150, height: 150, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

// 9. Providers
class FoodBottomBarSelectionService extends ChangeNotifier {
  String? tabSelection = 'main';
  void setTabSelection(String selection) {
    Utils.mainListNav.currentState!.pushNamedAndRemoveUntil(
      '/' + selection,
          (route) => false,
    );
    tabSelection = selection;
    notifyListeners();
  }
}
class FoodService extends ChangeNotifier {
  List<FoodFilterBarItem> filterBarItems = [
    FoodFilterBarItem(id: 'all', label: 'All'),
    FoodFilterBarItem(id: 'bread', label: 'Bread'),
    FoodFilterBarItem(id: 'pizza', label: 'Pizza'),
    FoodFilterBarItem(id: 'martabak', label: 'Martabak'),
    FoodFilterBarItem(id: 'fritter', label: 'Fritter'),
    FoodFilterBarItem(id: 'meatball', label: 'Meatball'),
  ];
  String? selectedFoodType;
  List<FoodModel> filteredFoods = [];
  late FoodModel selectedFood;
  FoodService() {
    selectedFoodType = filterBarItems.first.id;
    filteredFoodsByType(selectedFoodType!);
  }
  void filteredFoodsByType(String type) {
    selectedFoodType = type;
    if (type == 'all') {
      filteredFoods = Utils.foods;
    } else {
      filteredFoods = Utils.foods.where((f) => f.food_category == type).toList();
    }
    notifyListeners();
  }
  void onFoodSelected(FoodModel food) {
    selectedFood = food;
    Utils.mainAppNav.currentState!.pushNamed('/details');
  }
}
class FoodShoppingCartService extends ChangeNotifier {
  List<FoodModel> cartFoods = [];
  void addToCart(FoodModel food) {
    cartFoods.add(food);
    notifyListeners();
  }
  void removeFromCart(FoodModel food) {
    cartFoods.removeWhere((f) => f.food_id == food.food_id);
    notifyListeners();
  }
  void clearCart() {
    cartFoods.clear();
    notifyListeners();
  }
  double getTotal() {
    double total = 0.0;
    for (var food in cartFoods) {
      total += double.tryParse(food.food_quantity) ?? 0;
    }
    return total;
  }
  bool isFoodInCart(FoodModel food) {
    return cartFoods.any((f) => f.food_id == food.food_id);
  }
}

// 10. Food Details Page
class FoodDetailsPage extends StatefulWidget {
  @override
  _FoodDetailsPageState createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage>
    with SingleTickerProviderStateMixin {
  FoodModel? selectedFood;
  AnimationController? controller;
  Animation<double>? rotationAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller!, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FoodService foodService =
    Provider.of<FoodService>(context, listen: false);
    selectedFood = foodService.selectedFood;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.red[900]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(Utils.foodLogo, width: 120),
        actions: [
          FoodShoppingCartBadge(),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -40,
                  right: -120,
                  child: Hero(
                    tag: selectedFood!.foodName,
                      child: Image.asset(
                        selectedFood!.foodImage,
                        width: MediaQuery.of(context).size.width * 1.25,
                        fit: BoxFit.contain,
                      ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedFood!.foodName,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite_outline),
                        color: Colors.red[900],
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${selectedFood!.food_quantity}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(selectedFood!.food_description),
                  SizedBox(height: 20),
                  Consumer<FoodShoppingCartService>(
                    builder: (context, cartService, child) {
                      if (!cartService.isFoodInCart(selectedFood!)) {
                        return GestureDetector(
                          onTap: () {
                            cartService.addToCart(selectedFood!);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red[900]!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart,
                                    color: Colors.red[900]),
                                SizedBox(width: 20),
                                Text('Add To Cart',
                                    style: TextStyle(
                                        color: Colors.red[900])),
                              ],
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                color: Colors.red[900]),
                            SizedBox(width: 20),
                            Text('Added to Cart',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900])),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 11. FoodShoppingCartBadge
class FoodShoppingCartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FoodShoppingCartService>(
      builder: (context, cartService, child) {
        if (cartService.cartFoods.isEmpty) {
          return SizedBox();
        }
        return Transform.scale(
          scale: 0.7,
          child: Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Text('${cartService.cartFoods.length}',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(Icons.shopping_cart,
                    size: 25, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 12. FoodShoppingCartPage
class FoodShoppingCartPage extends StatefulWidget {
  @override
  _FoodShoppingCartPageState createState() =>
      _FoodShoppingCartPageState();
}

class _FoodShoppingCartPageState extends State<FoodShoppingCartPage>
    with SingleTickerProviderStateMixin {
  AnimationController? titleAnimation;

  @override
  void initState() {
    super.initState();
    titleAnimation = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    titleAnimation!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                parent: titleAnimation!, curve: Curves.easeInOut)),
            child: Image.asset(Utils.foodTitleCart, width: 170),
          ),
          Expanded(
            child: Consumer<FoodShoppingCartService>(
              builder: (context, cartService, child) {
                if (cartService.cartFoods.isEmpty) {
                  return Center(
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart,
                              color: Colors.grey[300], size: 50),
                          SizedBox(height: 20),
                          Text(
                            'Your cart is empty!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return FoodShoppingList(
                  foodCart: cartService.cartFoods,
                  cartService: cartService,
                );
              },
            ),
          ),
          Consumer<FoodShoppingCartService>(
            builder: (context, cartService, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cartService.cartFoods.isEmpty
                      ? SizedBox()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total',
                          style:
                          TextStyle(color: Colors.red[900])),
                      Text(
                        '\$${cartService.getTotal().toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Material(
                      color: cartService.cartFoods.isEmpty
                          ? Colors.grey[200]
                          : Colors.red[400]!.withOpacity(0.2),
                      child: InkWell(
                        splashColor:
                        Colors.red[900]!.withOpacity(0.2),
                        highlightColor:
                        Colors.red[900]!.withOpacity(0.5),
                        onTap: cartService.cartFoods.isEmpty
                            ? null
                            : () {
                          cartService.clearCart();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever,
                                  color: cartService.cartFoods.isEmpty
                                      ? Colors.grey
                                      : Colors.red[900]),
                              Text('Clear Cart',
                                  style: TextStyle(
                                      color: cartService.cartFoods.isEmpty
                                          ? Colors.grey
                                          : Colors.red[900])),
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
    );
  }
}

// 13. FoodShoppingList & FoodShoppingListRow
class FoodShoppingList extends StatefulWidget {
  final List<FoodModel>? foodCart;
  final FoodShoppingCartService? cartService;
  FoodShoppingList({this.foodCart, this.cartService});
  @override
  _FoodShoppingListState createState() => _FoodShoppingListState();
}

class _FoodShoppingListState extends State<FoodShoppingList> {
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  List<FoodModel> insertedItems = [];

  @override
  void initState() {
    super.initState();
    var future = Future(() {});
    for (var i = 0; i < widget.foodCart!.length; i++) {
      future = future.then((_) {
        return Future.delayed(Duration(milliseconds: 125), () {
          insertedItems.add(widget.foodCart![i]);
          _key.currentState!.insertItem(i);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _key,
      initialItemCount: insertedItems.length,
      itemBuilder: (context, index, animation) {
        FoodModel currentFood = widget.foodCart![index];
        return SlideTransition(
          position: Tween(
              begin: Offset(0, 0.2), end: Offset(0, 0))
              .animate(CurvedAnimation(
              parent: animation, curve: Curves.easeInOut)),
          child: FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                parent: animation, curve: Curves.easeInOut)),
            child: FoodShoppingListRow(
              food: currentFood,
              onDeleteRow: () {
                widget.cartService!.removeFromCart(currentFood);
              },
            ),
          ),
        );
      },
    );
  }
}

class FoodShoppingListRow extends StatelessWidget {
  final FoodModel? food;
  final Function? onDeleteRow;
  FoodShoppingListRow({this.food, required this.onDeleteRow});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Image.asset('${food!.foodImage}', width: 80, height: 80),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${food!.foodName}',
                    style: TextStyle(
                        color: Colors.red[900],
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        width: 2,
                        color: Colors.red[900]!.withOpacity(0.2)),
                  ),
                  child: Text('\$${food!.food_quantity}',
                      style: TextStyle(
                          color: Colors.red[900]!.withOpacity(0.4),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              onDeleteRow!();
            },
            icon: Icon(Icons.delete_forever, color: Colors.red[400]),
          ),
        ],
      ),
    );
  }
}

// 14. FoodFavoritesPage (Layout sederhana)
class FoodFavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Food Favorites Page',
          style: TextStyle(fontSize: 24, color: Colors.red[900])),
    );
  }
}

// 15. Model Data dan Utils

class FoodModel {
  final String food_id;
  final String foodName;
  final String food_category;
  final String food_weigth;
  final String food_type;
  final String food_description;
  final String foodImage;
  final String food_quantity;

  FoodModel({
    required this.food_id,
    required this.foodName,
    required this.food_category,
    required this.food_weigth,
    required this.food_type,
    required this.food_description,
    required this.foodImage,
    required this.food_quantity,
  });
}

class FoodFilterBarItem {
  final String? id;
  final String? label;
  FoodFilterBarItem({this.id, this.label});
}

class FoodPage {
  final String? imgUrl;
  final String? logoImgUrl;
  FoodPage({this.imgUrl, this.logoImgUrl});
}

class Utils {
  static GlobalKey<NavigatorState> mainListNav = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> mainAppNav = GlobalKey<NavigatorState>();

  // Tema warna: menggunakan nuansa merah untuk aplikasi Food
  static const Color mainColor = Color(0xFFFF4C4C); // merah terang
  static const Color mainDark = Color(0xFFB22222);  // merah gelap

  // Data asset dari folder lokal
  static const String foodLogo = 'assets/images/logo.jpg';
  static const String foodPromo1 = 'assets/images/food_promo1.jpg';
  static const String foodPromo2 = 'assets/images/food_promo2.jpg';
  static const String foodPromo3 = 'assets/images/food_promo3.jpg';
  static const String foodTitleCart = 'assets/images/food_title_cart.jpg';

// Data dummy untuk list Food
  static List<FoodModel> foods = [
    FoodModel(
      food_id: '1',
      foodName: 'Roti Manis',
      food_category: 'bread',
      food_weigth: '200g',
      food_type: 'snack',
      food_description: 'Roti manis lezat yang pas untuk sarapan atau cemilan.',
      foodImage: 'assets/images/roti_manis.jpg',
      food_quantity: '3.50',
    ),
    FoodModel(
      food_id: '2',
      foodName: 'Pizza Margherita',
      food_category: 'pizza',
      food_weigth: '500g',
      food_type: 'main course',
      food_description: 'Pizza klasik dengan keju mozzarella dan saus tomat segar.',
      foodImage: 'assets/images/pizza_margherita.jpg',
      food_quantity: '8.99',
    ),
    FoodModel(
      food_id: '3',
      foodName: 'Martabak Telur',
      food_category: 'martabak',
      food_weigth: '350g',
      food_type: 'snack',
      food_description: 'Martabak telur gurih dengan isian daging dan sayuran.',
      foodImage: 'assets/images/martabak_telur.jpg',
      food_quantity: '5.50',
    ),
    FoodModel(
      food_id: '4',
      foodName: 'Pisang Goreng',
      food_category: 'fritter',
      food_weigth: '150g',
      food_type: 'snack',
      food_description: 'Pisang goreng renyah dengan taburan gula halus.',
      foodImage: 'assets/images/pisang_goreng.jpg',
      food_quantity: '2.99',
    ),
    FoodModel(
      food_id: '5',
      foodName: 'Bakso Sapi',
      food_category: 'meatball',
      food_weigth: '300g',
      food_type: 'main course',
      food_description: 'Bakso sapi kenyal disajikan dengan kuah kaldu gurih.',
      foodImage: 'assets/images/bakso_sapi.jpg',
      food_quantity: '6.50',
    ),
  ];
}