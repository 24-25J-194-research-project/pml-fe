import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // title: Text(
        //   "Personal Assistant",
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        // ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),

      // ✅ Background Image
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/landing.png"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Welcome Text
            Text(
              "WELCOME BACK !",
              style: GoogleFonts.bebasNeue(
                fontSize: 32,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            // SizedBox(height: 4),
            Text(
              "Guidane you require is fingertips away 💓",
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 32),

            // ✅ Personalized Memory Lane Button
            ElevatedButton(
              onPressed: () {
                context.push('/pml');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // Floating effect
              ),
              child: Text(
                "Personalized Memory Lane",
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16),

            // ✅ Recipes Button
            ElevatedButton(
              onPressed: () {
                context.push('/recipes');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50), // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // Floating effect
              ),
              child: Text(
                "Interactive cooking",
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16),

            // ✅ Companion Button
            ElevatedButton(
              onPressed: () {
                context.push('/companion');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50), // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // Floating effect
              ),
              child: Text(
                "Virtual Companion",
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
