import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../CardItem.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late List<String> favoriteProductIds = [];
  late List<CardItem> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot usr = await FirebaseFirestore.instance.collection('usrs')
          .where('uid', isEqualTo: userId)
          .get();
      String id = usr.docs[0].id;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usrs')
          .doc(id)
          .get();

      List<dynamic> favorites =
          (userDoc.data() as Map<String, dynamic>)['favourites'] ?? [];
      if (favorites != null) {
        setState(() {
          favoriteProductIds = List<String>.from(favorites);
          getFavoriteProductsDetails(favoriteProductIds);
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      QuerySnapshot usr = await FirebaseFirestore.instance.collection('usrs')
          .where('uid', isEqualTo: userId)
          .get();
      String id = usr.docs[0].id;
      await FirebaseFirestore.instance.collection('usrs').doc(id).update({
        'favourites': FieldValue.arrayRemove([productId]),
      });
    } catch (e) {
    }
  }

  Future<void> getFavoriteProductsDetails(List<String> productIds) async {
    try {
      for (String productId in productIds) {
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        Map<String, dynamic>? data =
        productDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          CardItem item = CardItem(
            id: productDoc.id,
            name: data['name'],
            price: data['cost'],
            hero: data['hero'],
            images: List<String>.from(data['images']),
          );
          setState(() {
            favoriteProducts.add(item);
          });
        }
      }
    } catch (e) {
      print('Error loading favorite products details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        title: const Text('Favourites'),
      ),
      body: Container(
          color: Colors.grey[300],
      child : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    CardItem product = favoriteProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white70,
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            product.images.isNotEmpty
                                ? product.images[0]
                                : '',
                            height: 90,
                            width: 90,
                          ),
                          const SizedBox(width: 15.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? 'No Title',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                product.price,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  String userId = FirebaseAuth.instance.currentUser!.uid;
                                  await removeFromFavorites(userId, product.id);
                                  setState(() {
                                    favoriteProducts.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.favorite, color: Colors.pink),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}