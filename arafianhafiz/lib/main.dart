import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => DonutBottomBarSelectionService(),
            ),
            ChangeNotifierProvider(
              create: (_) => DonutService(),
            )
          ],
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: '/',
              navigatorKey: Utils.mainAppNav,
              routes: {
                '/': (context) => SplashPage(),
                '/main': (context) => DonutShopMain()
              }
          )
      )
  );
}

class SplashPage extends StatefulWidget {

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  AnimationController? donutController;
  Animation<double>? rotationAnimation;

  @override
  void initState() {
    super.initState();
    donutController = AnimationController(
        duration: const Duration(seconds: 5),
        vsync: this)..repeat();

    rotationAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: donutController!, curve: Curves.linear));
  }

  @override
  void dispose() {
    donutController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(seconds: 2), () {
      Utils.mainAppNav.currentState!.pushReplacementNamed('/main');
    });

    return Scaffold(
        backgroundColor: Utils.mainColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RotationTransition(
                turns: rotationAnimation!,
                child: Image.network(Utils.donutLogoWhiteNoText, width: 100, height: 100),
              ),
              Image.network(Utils.donutLogoWhiteText, width: 150, height: 150)
            ],
          ),
        )
    );
  }
}

class DonutShopMain extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
            child: DonutSideMenu()
        ),
        appBar: AppBar(
            iconTheme: const IconThemeData(color: Utils.mainDark),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Image.network(Utils.donutLogoRedText, width: 120)
        ),
        body: Column(
            children: [
              Expanded(
                  child: Navigator(
                      key: Utils.mainListNav,
                      initialRoute: '/main',
                      onGenerateRoute: (RouteSettings settings) {
                        Widget page;
                        switch(settings.name) {
                          case '/main':
                            page = DonutMainPage();
                            break;
                          case '/favorites':
                            page = Center(child: Text('favorites'));
                            break;
                          case '/shoppingcart':
                            page = Center(child: Text('shopping cart'));
                            break;
                          default:
                            page = Center(child: Text('main'));
                            break;
                        }

                        return PageRouteBuilder(pageBuilder: (_, __, ___) => page,
                            transitionDuration: const Duration(seconds: 0)
                        );
                      }

                  )


              ),
              DonutBottomBar()
            ]
        )
    );
  }
}

class DonutMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          DonutPager(),
          DonutFilterBar(),
          Expanded(
              child: Consumer<DonutService>(
                builder: (context, donutService, child) {
                  return DonutList(donuts: donutService.filteredDonuts);
                },
              )
          )
        ]
    );
  }
}

class DonutPager extends StatefulWidget {
  @override
  State<DonutPager> createState() => _DonutPagerState();
}

class _DonutPagerState extends State<DonutPager> {

  List<DonutPage> pages = [
    DonutPage(imgUrl: Utils.donutPromo1, logoImgUrl: Utils.donutLogoWhiteText),
    DonutPage(imgUrl: Utils.donutPromo2, logoImgUrl: Utils.donutLogoWhiteText),
    DonutPage(imgUrl: Utils.donutPromo3, logoImgUrl: Utils.donutLogoRedText),
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
        height: 350,
        child: Column(
          children: [
            Expanded(
                child: PageView(
                    scrollDirection: Axis.horizontal,
                    pageSnapping: true,
                    controller: controller,
                    onPageChanged: (int page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    children: List.generate(pages.length, (index) {
                      DonutPage currentPage = pages[index];
                      return Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0.0, 5.0)
                                )
                              ],
                              image: DecorationImage(
                                  image: NetworkImage(currentPage.imgUrl!),
                                  fit: BoxFit.cover
                              )
                          ),
                          child: Image.network(currentPage.logoImgUrl!, width: 120)
                      );
                    })
                )
            ),
            PageViewIndicator(
              controller: controller,
              numberOfPages: pages.length,
              currentPage: currentPage,
            )
          ],
        )
    );
  }
}

class PageViewIndicator extends StatelessWidget {

  PageController? controller;
  int? numberOfPages;
  int? currentPage;

  PageViewIndicator({ this.controller, this.numberOfPages, this.currentPage });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(numberOfPages!, (index) {

          return GestureDetector(
              onTap: () {
                controller!.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 15,
                  height: 15,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: currentPage == index ?
                      Utils.mainColor : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)
                  )
              )
          );


        })
    );
  }

}

class DonutSideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Utils.mainDark,
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                margin: EdgeInsets.only(top: 40),
                child: Image.network(Utils.donutLogoWhiteNoText,
                    width: 100
                )
            ),
            Image.network(Utils.donutLogoWhiteText,
                width: 150
            )
          ],
        )
    );
  }
}

class DonutBottomBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(30),
        child: Consumer<DonutBottomBarSelectionService>(
            builder: (context, bottomBarSelectionService, child) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(
                            Icons.trip_origin,
                            color: bottomBarSelectionService.tabSelection == 'main' ?
                            Utils.mainDark : Utils.mainColor
                        ),
                        onPressed: () {
                          bottomBarSelectionService.setTabSelection('main');
                        }
                    ),
                    IconButton(
                        icon: Icon(Icons.favorite,
                            color: bottomBarSelectionService.tabSelection == 'favorites' ?
                            Utils.mainDark : Utils.mainColor
                        ),
                        onPressed: () {
                          bottomBarSelectionService.setTabSelection('favorites');
                        }
                    ),
                    IconButton(
                        icon: Icon(Icons.shopping_cart,
                            color: bottomBarSelectionService.tabSelection == 'shoppingcart' ?
                            Utils.mainDark : Utils.mainColor
                        ),
                        onPressed: () {
                          bottomBarSelectionService.setTabSelection('shoppingcart');
                        }
                    )
                  ]
              );
            })
    );
  }
}

class DonutFilterBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Consumer<DonutService>(
            builder: (context, donutService, child) {
              return Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                            donutService.filterBarItems.length, (index) {

                          DonutFilterBarItem item = donutService.filterBarItems[index];

                          return  GestureDetector(
                              onTap: () {
                                donutService.filteredDonutsByType(item.id!);
                              },
                              child: Container(
                                  child: Text('${item.label!}',
                                      style: TextStyle(
                                          color: donutService.selectedDonutType == item.id ?
                                          Utils.mainColor : Colors.black, fontWeight: FontWeight.bold)
                                  )
                              )
                          );
                        }
                        )
                    ),
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: alignmentBasedOnTap(donutService.selectedDonutType),
                            child: Container(
                                width: MediaQuery.of(context).size.width / 3 - 20,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Utils.mainColor,
                                    borderRadius: BorderRadius.circular(20)
                                )
                            )
                        )
                      ],
                    )
                  ]
              );
            }
        )
    );
  }

  Alignment alignmentBasedOnTap(filterBarId) {

    switch(filterBarId) {
      case 'classic':
        return Alignment.centerLeft;
      case 'sprinkled':
        return Alignment.center;
      case 'stuffed':
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}

class DonutList extends StatefulWidget {
  List<DonutModel>? donuts;

  DonutList({ this.donuts });

  @override
  State<DonutList> createState() => _DonutListState();
}

class _DonutListState extends State<DonutList> {
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  List<DonutModel> insertedItems = [];

  @override
  void initState() {
    super.initState();

    var future = Future(() {});
    for (var i = 0; i < widget.donuts!.length; i++) {
      future = future.then((_) {
        return Future.delayed(const Duration(milliseconds: 125), () {
          insertedItems.add(widget.donuts![i]);
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

          DonutModel currentDonut = widget.donuts![index];

          return SlideTransition(
              position: Tween(
                begin: const Offset(0.2, 0.0),
                end: const Offset(0.0, 0.0),
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeInOut)
                  ),
                  child: DonutCard(donutInfo: currentDonut)
              )
          );
        }
    );
  }
}

class DonutCard extends StatelessWidget {
  DonutModel? donutInfo;
  DonutCard({ this.donutInfo });

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            padding: EdgeInsets.all(15),
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.only(left: 10, top: 80, right: 10, bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0.0, 4.0)
                  )
                ]
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${donutInfo!.name}',
                      style: TextStyle(
                          color: Utils.mainDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                      )
                  ),
                  SizedBox(height: 10),
                  Container(
                      decoration: BoxDecoration(
                        color: Utils.mainColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5
                      ),
                      child: Text('\$${donutInfo!.price!.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          )
                      )
                  )
                ]
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Image.network(
                donutInfo!.imgUrl!,
                width: 150, height: 150,
                fit: BoxFit.contain
            ),
          )
        ]
    );
  }
}

class DonutBottomBarSelectionService extends ChangeNotifier {

  String? tabSelection = 'main';

  void setTabSelection(String selection) {
    Utils.mainListNav.currentState!.pushReplacementNamed('/' + selection);
    tabSelection = selection;
    notifyListeners();
  }
}

class DonutService extends ChangeNotifier {

  List<DonutFilterBarItem> filterBarItems = [
    DonutFilterBarItem(id: 'classic', label: 'Classic'),
    DonutFilterBarItem(id: 'sprinkled', label: 'Sprinkled'),
    DonutFilterBarItem(id: 'stuffed', label: 'Stuffed'),
  ];

  String? selectedDonutType;
  List<DonutModel> filteredDonuts = [];

  DonutService() {
    selectedDonutType = filterBarItems.first.id;
    filteredDonutsByType(selectedDonutType!);
  }

  void filteredDonutsByType(String type) {
    selectedDonutType = type;
    filteredDonuts = Utils.donuts.where(
            (d) => d.type == selectedDonutType).toList();

    notifyListeners();
  }


}

class DonutFilterBarItem {
  String? id;
  String? label;

  DonutFilterBarItem({ this.id, this.label });
}

class DonutPage {
  String? imgUrl;
  String? logoImgUrl;

  DonutPage({ this.imgUrl, this.logoImgUrl });
}

class DonutModel {

  String? imgUrl;
  String? name;
  String? description;
  double? price;
  String? type;

  DonutModel({
    this.imgUrl,
    this.name,
    this.description,
    this.price,
    this.type
  });
}

class Utils {
  static GlobalKey<NavigatorState> mainListNav = GlobalKey();
  static GlobalKey<NavigatorState> mainAppNav = GlobalKey();

  static const Color mainColor = Color(0xFFFF0F7E);
  static const Color mainDark = Color(0xFF980346);
  static const String donutLogoWhiteNoText = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_shop_logowhite_notext.png';
  static const String donutLogoWhiteText = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_shop_text_reversed.png';
  static const String donutLogoRedText = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_shop_text.png';
  static const String donutTitleFavorites = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_favorites_title.png';
  static const String donutTitleMyDonuts = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_mydonuts_title.png';
  static const String donutPromo1 = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_promo1.png';
  static const String donutPromo2 = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_promo2.png';
  static const String donutPromo3 = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_promo3.png';

  static List<DonutModel> donuts = [
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutclassic/donut_classic1.png',
        name: 'Strawberry Sprinkled Glazed',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.99,
        type: 'classic'
    ),
    DonutModel(
      imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutclassic/donut_classic2.png',
      name: 'Chocolate Glazed Doughnut',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
      price: 2.99,
      type: 'classic',
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutclassic/donut_classic3.png',
        name: 'Chocolate Dipped Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 2.99,
        type: 'classic'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutclassic/donut_classic4.png',
        name: 'Cinamon Glazed Glazed',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 2.99,
        type: 'classic'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutclassic/donut_classic5.png',
        name: 'Sugar Glazed Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.99,
        type: 'classic'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutsprinkled/donut_sprinkled1.png',
        name: 'Halloween Chocolate Glazed',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 2.99,
        type: 'sprinkled'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutsprinkled/donut_sprinkled2.png',
        name: 'Party Sprinkled Cream',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.99,
        type: 'sprinkled'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutsprinkled/donut_sprinkled3.png',
        name: 'Chocolate Glazed Sprinkled',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.99,
        type: 'sprinkled'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutsprinkled/donut_sprinkled4.png',
        name: 'Strawbery Glazed Sprinkled',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 2.99,
        type: 'sprinkled'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutsprinkled/donut_sprinkled5.png',
        name: 'Reese\'s Sprinkled',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 3.99,
        type: 'sprinkled'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutstuffed/donut_stuffed1.png',
        name: 'Brownie Cream Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.99,
        type: 'stuffed'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutstuffed/donut_stuffed2.png',
        name: 'Jelly Stuffed Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 2.99,
        type: 'stuffed'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutstuffed/donut_stuffed3.png',
        name: 'Caramel Stuffed Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 2.59,
        type: 'stuffed'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutstuffed/donut_stuffed4.png',
        name: 'Maple Stuffed Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.99,
        type: 'stuffed'
    ),
    DonutModel(
        imgUrl: 'https://romanejaquez.github.io/flutter-codelab4/assets/donutstuffed/donut_stuffed5.png',
        name: 'Glazed Jelly Stuffed Doughnut',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce blandit, tellus condimentum cursus gravida, lorem augue venenatis elit, sit amet bibendum quam neque id sapien.',
        price: 1.59,
        type: 'stuffed'
    )
  ];
}