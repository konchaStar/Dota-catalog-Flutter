import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/account_screen.dart';
import 'package:untitled/screens/favorites_cart.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/product_details.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../CardItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CardItem> cardItems = [];
  String searchText = '';


  @override
  void initState() {
    super.initState();
    loadCardItems();
  }

  Future<void> loadCardItems() async {
    try {

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();


      List<CardItem> items = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;


        items.add(CardItem(
          id: doc.id,
          name: data['name'],
          price: data['cost'],
          hero: data['hero'],
          images: List<String>.from(data['images']),
        ));
      });

      setState(() {
        cardItems = items;
      });
    } catch (e) {
      print('Error loading card items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if(user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Catalog'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favorites(),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.favorite_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.grey[300]),
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.all(5.0),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                                fontSize: 14, color: Colors.black),
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: GridView.count(
                      crossAxisCount: 1,
                      childAspectRatio: 0.60,
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 3.0,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: cardItems
                          .where((cardItem) => cardItem.name
                          .toLowerCase()
                          .contains(searchText.toLowerCase())
                          || cardItem.hero.
                          toLowerCase()
                          .contains(searchText.toLowerCase()))
                          .map((cardItem) {
                        return buildCard(cardItem);
                      }).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(CardItem cardItem) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProductDetail(cardItem: cardItem)));
      },
      child: Card(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: PageView.builder(
                  itemCount: cardItem.images.length,
                  onPageChanged: (int index) {
                    setState(() {
                      cardItem.currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      cardItem.images[index],
                    );
                  }),
            ),
            ListTile(
              leading: Text(
                  cardItem.hero,
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              title: Text(
                cardItem.name,
                style: TextStyle(color: Colors.purple),
              ),
              subtitle: Text(cardItem.price),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }
}


