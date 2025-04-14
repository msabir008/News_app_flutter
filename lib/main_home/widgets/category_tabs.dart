import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final TabController tabController;

  const CategoryTabs({
    Key? key,
    required this.categories,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      height: 32,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(7),
        ),
        padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.start,
        labelPadding: EdgeInsets.symmetric(horizontal: 2),
        tabs: categories.map((category) {
          return Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}