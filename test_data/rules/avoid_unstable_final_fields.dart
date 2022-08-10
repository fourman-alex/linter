// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_unstable_final_fields`

import 'dart:math' as math;

class A {
  final int i;
  A(this.i);
}

var jTop = 0;

class B1 extends A {
  int get i => ++jTop + super.i; //LINT
  B1(super.i);
}

class B2 implements A {
  int i; //LINT
  B2(this.i);
}

class B3 implements A {
  late final int i = jTop++; //OK
}

class B4 extends A {
  int get i => super.i - 1; //OK
  B4(super.i);
}

class B5 implements A {
  final int j;
  int get i => j; //OK
  B5(this.j);
}

class B6 implements A {
  int get i => 1; //OK
}

class B7 implements A {
  int get i { //OK
    return 1;
  }
}

class B8 implements A {
  int get i { //LINT
    return jTop;
  }
}

class B9 extends A {
  int get i => -super.i; //OK
  B9(super.i);
}

class B10 implements A {
  final bool b;
  final int j;
  int get i => b ? j : 10; //OK
  B10(this.b, this.j);
}

class B11 implements A {
  bool b;
  final int j;
  int get i => b ? 2 * j : 10; //LINT
  B11(this.b, this.j);
}

class B12 implements A {
  int get i => throw 0; //OK
}

class B13 implements A {
  int get i { //OK
    throw 0;
  }
}

class C<X> {
  final C<X>? next;
  final C<X>? nextNext = null;
  final X? value = null;
  const C(this.next);
}

const cNever = C<Never>(null);

class D1<X> implements C<X> {
  late X x;
  C<X>? get next => cNever; //OK
  C<X>? get nextNext => this.next?.next; //OK
  X? get value => x; //LINT
}

class E {
  final Object? o;
  E(this.o);
}

class F1 implements E {
  Function get o => m; //LINT
  void m() {}
  static late final Function fStatic = () {};
}

class F2 implements E {
  Function get o => () {}; //LINT
}

class F3 implements E {
  Function get o => print..toString(); //OK
}

class F4 implements E {
  Function get o => math.cos; //OK
}

class F5 implements E {
  Function get o => F1.fStatic; //OK
}

class F6 implements E {
  List<int> get o => []; //LINT
}

class F7 implements E {
  Set<double> get o => const {}; //OK
}

class F8 implements E {
  Object get o => <String, String>{}; //LINT
}

class F9 implements E {
  Symbol get o => #symbol; //OK
}

class F10 implements E {
  Type get o => int; //OK
}

class F11<X> implements E {
  Type get o => X; //LINT
}

class F12<X> implements E {
  Type get o => F12<X>; //OK
}

class F13 implements E {
  F13 get o => const F13(42); //OK
  const F13(int whatever);
}

class F14 implements E {
  F14 get o => F14(jTop); //LINT
  F14(int whatever);
}

class F15 implements E {
  String get o => 'Something $cNever, and ${1 * 1} more things'; //OK
}

class F16 implements E {
  String get o => 'Stuff, $cNever, but not $jTop'; //LINT
}

class F17 implements E {
  bool get o => this is E; //OK
}

class F18 implements E {
  bool get o => jTop is int; //LINT
}

class F19 extends E {
  Object get o => super.o!; //OK
  F19(super.o);
}

class F20Helper {
  const F20Helper.named(int i);
}

class F20 implements E {
  F20Helper get o => const F20Helper.named(15); //OK
}

class F21 implements E {
  bool get o => identical(const <int>[], const <int>[]); //OK
}

class F22 implements E {
  bool get o => identical(<int>[], const <int>[]); //LINT
}

class G {
  @Object()
  final String s;
  G(this.s);
}

class H1 implements G {
  String get s => '${++jTop}'; //OK
}

class I {
  final int i;
  I(this.i);
}

mixin J1 on I {
  int get i => ++jTop + super.i; //LINT
}

mixin J2 implements I {
  int get i => ++jTop; //LINT
}

mixin J3 on I {
  int get i => super.i - 1; //OK
}

mixin J4 implements I {
  int get i => 1; //OK
}

mixin J5 on I {
  int get i => -super.i; //OK
}

class K {
  final Object? o;
  K(this.o);
}

mixin L1 on K {
  Object get o => super.o!; //OK
}

class M {
  @Object()
  final String s;
  M(this.s);
}

mixin N1 on M {
  String get s => '$jTop'; //OK
}

mixin N2 implements M {
  String get s => '${-jTop}'; //OK
}

abstract class O {
  final int i;
  O(this.i);
}

enum P1 implements O {
  a, b, c;
  final int i = jTop++; //OK
}

enum P2 implements O {
  a(10), b(12), c(14);
  final int j;
  int get i => j; //OK
  const P2(this.j);
}

enum P3 implements O {
  a, b, c;
  int get i => 1; //OK
}

enum P4 implements O {
  a, b, c;
  int get i { //OK
    return 1;
  }
}

enum P5 implements O {
  a, b, c;
  int get i { //LINT
    return jTop;
  }
}

enum P6 implements O {
  aa(true, 4), bb(true, 8), cc(false, 12);
  final bool b;
  final int j;
  int get i => b ? j : 10; //OK
  const P6(this.b, this.j);
}

bool bTop = true;

enum P7 implements O {
  aa(3), bb(5), cc(7);
  final int j;
  int get i => bTop ? 2 * j : 10; //LINT
  const P7(this.j);
}

enum P8 implements O {
  a, b, c;
  int get i => throw 0; //OK
}

enum P9 implements O {
  a, b, c;
  int get i { //OK
    throw 0;
  }
}

abstract class Q {
  abstract final Object? o;
}

enum R1 implements Q {
  a, b, c;
  Function get o => m; //LINT
  void m() {}
  static late final Function fStatic = () {};
}

enum R2 implements Q {
  a, b, c;
  Function get o => () {}; //LINT
}

enum R3 implements Q {
  a, b, c;
  Function get o => print..toString(); //OK
}

enum R4 implements Q {
  a, b, c;
  Function get o => math.cos; //OK
}

enum R5 implements Q {
  a, b, c;
  Function get o => F1.fStatic; //OK
}

enum R6 implements Q {
  a, b, c;
  List<int> get o => []; //LINT
}

enum R7 implements Q {
  a, b, c;
  Set<double> get o => const {}; //OK
}

enum R8 implements Q {
  a, b, c;
  Object get o => <String, String>{}; //LINT
}

enum R9 implements Q {
  a, b, c;
  Symbol get o => #symbol; //OK
}

enum R10 implements Q {
  a, b, c;
  Type get o => int; //OK
}

enum R11<X> implements Q {
  a, b, c;
  Type get o => X; //LINT
}

enum R12<X> implements Q {
  a, b, c;
  Type get o => F12<X>; //OK
}

enum R13 implements Q {
  a(-1), b(-2), c(-3);
  F13 get o => const F13(42); //OK
  const R13(int whatever);
}

enum R14 implements Q {
  a(-10), b(-20), c(-30);
  F14 get o => F14(jTop); //LINT
  const R14(int whatever);
}

enum R15 implements Q {
  a, b, c;
  String get o => 'Something $cNever, and ${1 * 1} more things'; //OK
}

enum R16 implements Q {
  a, b, c;
  String get o => 'Stuff, $cNever, but not $jTop'; //LINT
}

enum R17 implements Q {
  a, b, c;
  bool get o => this is Q; //OK
}

enum R18 implements Q {
  a, b, c;
  bool get o => jTop is int; //LINT
}

enum R20Helper {
  a.named(999), b.named(-0.888), c.named(77.7);
  const R20Helper.named(num n);
}

enum R20 implements Q {
  a, b, c;
  R20Helper get o => R20Helper.b; //OK
}

enum R21 implements Q {
  a, b, c;
  bool get o => identical(const <int>[], const <int>[]); //OK
}

enum R22 implements Q {
  a, b, c;
  bool get o => identical(<int>[], const <int>[]); //LINT
}