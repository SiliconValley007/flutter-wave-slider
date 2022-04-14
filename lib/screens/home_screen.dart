import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave_slider/widgets/wave_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _age = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select your age',
                style: TextStyle(
                  fontSize: 45,
                ),
              ),
              const SizedBox(height: 10),
              WaveSlider(
                onChanged: (value) => setState(() {
                  _age = (value * 100).round();
                }),
                onChangeStart: (value) => setState(() {
                  _age = (value * 100).round();
                }),
              ),
              const SizedBox(height: 50.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const SizedBox(width: 15),
                  Text(
                    '$_age',
                    style: const TextStyle(fontSize: 45),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'YEARS',
                    style: GoogleFonts.textMeOne(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
