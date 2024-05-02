import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController favPersonaController = TextEditingController();
  final TextEditingController favTeamController = TextEditingController();
  final TextEditingController hatedHeroController = TextEditingController();
  final TextEditingController mmrController = TextEditingController();
  final TextEditingController signHeroController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController favArcanaController = TextEditingController();

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  Future<void> _loadUserDataFromDatabase() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot usr = await FirebaseFirestore.instance.collection('usrs')
          .where('uid', isEqualTo: userId)
          .get();
      String id = usr.docs[0].id;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('usrs')
          .doc(id)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          nameController.text = userSnapshot['name'] ?? '';
          surnameController.text = userSnapshot['surname'] ?? '';
          favArcanaController.text = userSnapshot['fav_arcana'] ?? '';
          favPersonaController.text = userSnapshot['fav_persona'] ?? '';
          favTeamController.text = userSnapshot['fav_team'] ?? '';
          nicknameController.text = userSnapshot['nickname'] ?? '';
          ageController.text = userSnapshot['age'] ?? '';
          hatedHeroController.text = userSnapshot['hated_hero'] ?? '';
          mmrController.text = userSnapshot['mmr'] ?? '';
          signHeroController.text = userSnapshot['sign_hero'] ?? '';
        });
      } else {}
    } catch (e) {}
  }

  Future<void> _saveUserDataToDatabase() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot usr = await FirebaseFirestore.instance.collection('usrs')
          .where('uid', isEqualTo: userId)
          .get();
      String id = usr.docs[0].id;
      await FirebaseFirestore.instance.collection('usrs').doc(id).set({
        'name': nameController.text,
        'surname': surnameController.text,
        'age': ageController.text,
        'mmr': mmrController.text,
        'nickname': nicknameController.text,
        'sign_hero': signHeroController.text,
        'hated_hero': hatedHeroController.text,
        'fav_arcana': favArcanaController.text,
        'fav_persona': favPersonaController.text,
        'fav_team': favTeamController.text
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data was successfully updated!'),
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserDataFromDatabase();
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
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(labelText: 'Surname'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: favTeamController,
                decoration: const InputDecoration(labelText: 'Favourite team'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: favPersonaController,
                decoration: const InputDecoration(
                    labelText: 'Favourite persona'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: favArcanaController,
                decoration: const InputDecoration(
                    labelText: 'Favourite arcana'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: mmrController,
                decoration: const InputDecoration(labelText: 'Mmr'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: hatedHeroController,
                decoration: const InputDecoration(labelText: 'Hated hero'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: signHeroController,
                decoration: const InputDecoration(labelText: 'Signature hero'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _saveUserDataToDatabase();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text(
                    'Update', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () => _signOut(),
                child: const Text(
                    'Sign out', style: TextStyle(color: Colors.purple)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
