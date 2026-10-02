import 'dart:ui';

const Color mainColor = Color(0xFF7C3AED);
const Color bgColor = Color(0xFFF8F7FF);
const Color darkBgColor = Color(0xFF0F0B1A);
const Color lightDarkColor = Color(0xFF1A1D24);

Color categoryColorOf(String category) {
  switch (category) {
    case 'Work':
      return const Color(0xFFFF5252);
    case 'Personal':
      return const Color(0xFFFFB300);
    case 'Meeting':
      return const Color(0xFF00BFA5);
    case 'Study':
      return const Color(0xFF00ACC1);
    default:
      return const Color(0xFF7C4DFF);
  }
}