import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(

      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.person),
      //       onPressed: () {
      //         context.push('/profile');
      //       },
      //     ),
      //   ],
      //   elevation: 4,
      //   shadowColor: Colors.black.withOpacity(0.2),
      // ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.manage_accounts_outlined),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      // ✅ Background Image
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/sky.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 380,
              child: Lottie.asset(
                'assets/animations/sky.json',
                fit: BoxFit.fill,
              ),
            ),
            // ✅ Welcome Text
            Text(
              "WELCOME BACK !",
              style: GoogleFonts.bebasNeue(
                fontSize: 50,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            // SizedBox(height: 4),
            Text(
              "Guidance you require is fingertips away 💓",
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
                "personal cooking assistant",
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
