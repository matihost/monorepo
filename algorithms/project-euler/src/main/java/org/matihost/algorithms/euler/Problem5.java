package org.matihost.algorithms.euler;

import java.util.List;

/**
 * 2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any
 * remainder.
 * 
 * What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?
 */
public class Problem5 {

  public static long smallestDivisibleNumberForRange(int maxRange) {
    List<Long> longs = Problem3.primesUpTo(maxRange);
    Long[] primes = longs.toArray(new Long[longs.size()]);
    int[] range = new int[maxRange];
    for (int i = 0; i < maxRange; i++)
      range[i] = i + 1;

    for (int i = primes.length - 1; i >= 0; i--) {
      long prime = primes[i];
      primes[i] = 1L;
      boolean dividedByPrime = true;
      while (dividedByPrime) {
        dividedByPrime = false;
        for (int j = 0; j < maxRange; j++) {
          if (range[j] % prime == 0) {
            range[j] /= prime;
            dividedByPrime = true;
          }
        }
        if (dividedByPrime) {
          primes[i] *= prime;
        }
      }
    }

    long result = 1;
    for (long value : primes) {
      result *= value;
    }
    return result;
  }

  public static void main(String[] args) {
    System.out.print(smallestDivisibleNumberForRange(20));

  }

}
