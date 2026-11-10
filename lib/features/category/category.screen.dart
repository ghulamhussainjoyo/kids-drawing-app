import 'package:flutter/cupertino.dart';

import 'widget/category.carousel.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                CupertinoButton(
                  onPressed: null,
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.settings),
                ),
                Spacer(),
                CupertinoButton(
                  onPressed: null,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Try free for 7 days'),
                ),
              ],
            ),
            Expanded(
              child: CategoryCarousel(names: ['Animals', 'Vehicles', 'Food']),
            ),
            Row(
              children: [
                Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: null,
                  child: Text('Bottom left'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
