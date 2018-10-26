package org.matihost.algorithms;

public class Fib {

  public static int fib(int n) {
    if (n < 0)
      throw new IllegalArgumentException("Negative number provided to fib function");
    if (n < 2) {
      return n + 1;
    } else {
      int p2 = 1;
      int p1 = 1;
      int result = 0;
      for (int i = 2; i < n; i++) {
        result = p1 + p2;
        p2 = p1;
        p1 = result;
      }
      return result;
    }
  }


  public static void main(String args[]) {
    // given
    int n = 11;

    // when
    int result = fib(n);

    // then
    System.out.println(result);
  }

}
