void main() {
//  Animal().move();
  Fish().move();
  Bird().move();
  Duck().canFly();
  Duck().canSwim();
}

class Animal {
  void move() {}
}

class Fish extends Animal {
  @override
  void move() {
    super.move();
    print('by Swimming');
  }
}

class Bird extends Animal {
  @override
  void move() {
    super.move();
    print('by Flying');
  }
}

mixin CanSwim {
  void canSwim() {
    print('Changing positioning by Swimming');
  }
}

mixin CanFly {
  void canFly() {
    print('Changing positioning by Flying');
  }
}

class Duck extends Fish with CanSwim, CanFly {
  @override
  void move() {
    super.move();
  }

  @override
  void canFly() {
    super.canFly();
  }

  @override
  void canSwim() {
    super.canSwim();
  }
}
