import 'package:json_converter/features/johnverter.dart';
import 'package:flutter/material.dart';
import 'package:json_converter/features/request_dto_generator.dart';

class FeatureSelectionPage extends StatelessWidget {
  const FeatureSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
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
              child: const Text('Johnverter'),
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
              child: const Text('Request DTO generator'),
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
      ),
    );
  }
}
