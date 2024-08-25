

import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget{
  const CategoryItem({super.key, required this.categoryTitle, required this.categoryColor});

  final String categoryTitle;
  final Color categoryColor;
  @override
  Widget build(BuildContext context) {
    
    return Row(children: [
      Container(height: 20, width: 20, decoration: BoxDecoration(color: categoryColor), ),
      SizedBox(width: 10),
      Text(categoryTitle, style: const TextStyle(fontSize: 16, color: Colors.white), ),
      const Spacer(),
      

    ],);
  }
}