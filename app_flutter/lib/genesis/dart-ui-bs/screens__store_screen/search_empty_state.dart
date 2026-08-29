// 🧼 אטום · SearchEmptyState — מצב-ריק מרכז-מסך (גליף גדול + הודעה), גלילה-מלאה.
// שונה מ-EmptyStateCard שבמדף (שם כרטיס-מסגרת, כאן מילוי-גובה). מוצא:
// screens__store_screen.dart:1576 (_EmptyState). ההודעה מחושבת בקופסה
// (t_86e9cfb0 כשאין שאילתה / תבנית לא-נמצאו-תוצאות עם השאילתה).
import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    required this.glyph, required this.message, required this.mutedColor, super.key,
  });
  final String glyph, message;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(glyph, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(color: mutedColor, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
