import 'package:google_fonts/google_fonts.dart';
import 'package:json_converter/features/johnverter.dart';
import 'package:flutter/material.dart';
import 'package:json_converter/features/request_dto_generator.dart';

class FeatureSelectionPage extends StatelessWidget {
  const FeatureSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withAlpha(180),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withAlpha(200),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withAlpha(220),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent,
              ),
              child: Text(
                'J',
                style: GoogleFonts.oswald().copyWith(
                  fontSize: 400,
                  color: Colors.white.withAlpha(50),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                      (states) => const Size(500, 50),
                    ),
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (final context) => const Johnverter(),
                      ),
                    );
                  },
                  child: Text(
                    'Johnverter',
                    style: GoogleFonts.oswald(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                      (states) => const Size(500, 50),
                    ),
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (final context) => const RequestDtoGenerator(),
                      ),
                    );
                  },
                  child: Text(
                    'Request DTO generator',
                    style: GoogleFonts.oswald(),
                  ),
                ),
                // const SizedBox(
                //   height: 16,
                // ),
                // ElevatedButton(
                //   style: ButtonStyle(
                //     minimumSize: MaterialStateProperty.resolveWith(
                //           (states) => const Size(500, 50),
                //     ),
                //     shape: MaterialStateProperty.resolveWith(
                //           (states) => RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10)
                //       ),
                //     ),
                //   ),
                //   onPressed: () {},
                //   child: const Text('Request ENTITY generator'),
                // ),
                // const SizedBox(
                //   height: 16,
                // ),
                // ElevatedButton(
                //   style: ButtonStyle(
                //     minimumSize: MaterialStateProperty.resolveWith(
                //           (states) => const Size(500, 50),
                //     ),
                //     shape: MaterialStateProperty.resolveWith(
                //           (states) => RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10)
                //       ),
                //     ),
                //   ),
                //   onPressed: () {},
                //   child: const Text('Service generator'),
                // ),
                // const SizedBox(
                //   height: 16,
                // ),
                // ElevatedButton(
                //   style: ButtonStyle(
                //     minimumSize: MaterialStateProperty.resolveWith(
                //           (states) => const Size(500, 50),
                //     ),
                //     shape: MaterialStateProperty.resolveWith(
                //           (states) => RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10)
                //       ),
                //     ),
                //   ),
                //   onPressed: () {},
                //   child: const Text('Use case generator'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
