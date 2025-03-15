import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dementia Cooking Assistant"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.push('/pml');
              },
              child: Text("PML"),
            ),
            SizedBox(width: 20), // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                context.push('/recipes');
              },
              child: Text("Recipes"),
            ),
          ],
        ),
      ),
    );
  }
}
