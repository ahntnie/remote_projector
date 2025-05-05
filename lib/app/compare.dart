import 'package:path/path.dart';

import '../models/resource/resource_model.dart';

String normalize(String s) {
  return s.replaceAll(RegExp(r'\s\(\d+\)$'), '').toLowerCase();
}

int getNumberInParentheses(String s) {
  final match = RegExp(r'\((\d+)\)$').firstMatch(s);
  return match != null ? int.parse(match.group(1)!) : -1;
}

int fileNameAscendingCompare(ResourceModel resultA, ResourceModel resultB) {
  String a = basenameWithoutExtension(resultA.name ?? '');
  String b = basenameWithoutExtension(resultB.name ?? '');

  int result = normalize(a).compareTo(normalize(b));

  if (result == 0) {
    int numA = getNumberInParentheses(a);
    int numB = getNumberInParentheses(b);

    if (numA == -1 && numB != -1) {
      return -1;
    }
    if (numB == -1 && numA != -1) {
      return 1;
    }

    return numA.compareTo(numB);
  }

  return result;
}

int fileNameDescendingCompare(ResourceModel resultA, ResourceModel resultB) {
  String a = basenameWithoutExtension(resultA.name ?? '');
  String b = basenameWithoutExtension(resultB.name ?? '');

  int result = normalize(b).compareTo(normalize(a));

  if (result == 0) {
    int numA = getNumberInParentheses(a);
    int numB = getNumberInParentheses(b);

    if (numA == -1 && numB != -1) {
      return 1;
    }
    if (numB == -1 && numA != -1) {
      return -1;
    }

    return numB.compareTo(numA);
  }

  return result;
}
