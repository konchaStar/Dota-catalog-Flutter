import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../CardItem.dart';


class ProductDetail extends StatefulWidget {
  final CardItem cardItem;

  const ProductDetail({Key? key, required this.cardItem}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _currentSlide = 0;
  late List<String> _image;
  bool isFavorited = false;

  Future<void> addToFavorites(String userId, String productId) async {
    try {
      QuerySnapshot usr = await FirebaseFirestore.instance.collection('usrs')
          .where('uid', isEqualTo: userId)
          .get();
      String id = usr.docs[0].id;
      await FirebaseFirestore.instance.collection('usrs').doc(id).update({
        'favourites': FieldValue.arrayUnion([productId]),
      });
    } catch (e) {
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

  Future<bool> isProductInFavorites(String userId, String productId) async {
    try {
      QuerySnapshot usr = await FirebaseFirestore.instance.collection('usrs')
          .where('uid', isEqualTo: userId)
          .get();
      String id = usr.docs[0].id;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usrs')
          .doc(id)
          .get();

      final List<dynamic> favorites =
          (userDoc.data() as Map<String, dynamic>)['favourites'] ?? [];

      return favorites.contains(productId);
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _image = widget.cardItem.images;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (mounted) {
      isProductInFavorites(userId, widget.cardItem.id).then((inFavorites) {
        setState(() {
          isFavorited = inFavorites;
        });
      });
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
        title: Text(widget.cardItem.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: isFavorited ? Colors.pink[400] : null,
            ),
            onPressed: () {
              setState(() {
                isFavorited = !isFavorited;
                String userId = FirebaseAuth.instance.currentUser!.uid;
                if (isFavorited) {
                  addToFavorites(userId, widget.cardItem.id);
                } else {
                  removeFromFavorites(userId, widget.cardItem.id);
                }
              });
            },
          ),
        ],
      ),
      body:  Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CarouselSlider(
            options: CarouselOptions(
                height: 200.0,
                enlargeCenterPage: true,
                onPageChanged: (index, _) {
                  setState(() {
                    _currentSlide = index;
                  });
                }),
            items: _image.map((image) {
              return Builder(
                builder: (context) {
                  return Image.network(
                    image,
                    fit: BoxFit.cover,
                  );
                },
              );
            }).toList(),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.cardItem.name,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      widget.cardItem.price,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'Hero',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.cardItem.hero,
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
