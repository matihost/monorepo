package org.matihost.algorithms.euler;

import java.util.List;

/**
 * The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.
 * 
 * Find the sum of all the primes below two million.
 */
public class Problem10 {

  public static void main(String[] args) {
    long primeSum = 0;
    List<Long> longs = Problem3.primesUpTo(1_999_999);
    for (long prime : longs) {
      primeSum += prime;
    }
    System.out.println(primeSum);
  }
}
