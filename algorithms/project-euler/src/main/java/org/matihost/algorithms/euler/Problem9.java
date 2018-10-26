package org.matihost.algorithms.euler;

/**
 * 
 * 
 * A Pythagorean triplet is a set of three natural numbers, a < b < c, for which, a_2 + b_2 = c_2
 * 
 * For example, 3_2 + 4_2 = 9 + 16 = 25 = 52.
 * 
 * There exists exactly one Pythagorean triplet for which a + b + c = 1000. Find the product abc.
 * 
 */
public class Problem9 {

  public static void main(String[] args) {
    int a;
    int b = 0;
    int c = 0;
    a: for (a = 2; a < 501; a++) {
      for (b = 500; b > 1; b--) {
        c = 1000 - a - b;
        if (a * a + b * b == c * c && a < b && b < c) {
          break a;
        }
      }
    }



    System.out.println(a + " " + b + " " + c);
    System.out.println("a*b*c=" + a * b * c);
  }
}
