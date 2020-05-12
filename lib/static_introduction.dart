class A {
  static const kNmae = 'Print this text';
}

class B {
  String text = 'This is a text' + A.kNmae;
}

void main() {
  print(A.kNmae);
  print(B().text);
}
