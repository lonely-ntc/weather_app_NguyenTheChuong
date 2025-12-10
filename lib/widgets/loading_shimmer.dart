import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 20),
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
            const SizedBox(height: 10),
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
          ],
        ),
      ),
    );
  }
}