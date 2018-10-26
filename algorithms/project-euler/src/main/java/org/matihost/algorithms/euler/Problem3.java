package org.matihost.algorithms.euler;

import java.util.*;

/**
 * The prime factors of 13195 are 5, 7, 13 and 29.
 * <p>
 * What is the largest prime factor of the number 600851475143 ?
 */
public class Problem3 {

  public static long largestPrimeFactor(long n) {
    if (n < 2) {
      return 1;
    }
    if (n < 3) {
      return n;
    }
    long nLargestPrimeFactor = 1;
    long currentLargestPrimeFactor = 3;
    long primeFactorBoundary = (long) Math.sqrt(n) + 1L;
    List<Long> primes = new LinkedList<>(Arrays.asList(2L, 3L));
    for (long i = 5; currentLargestPrimeFactor < primeFactorBoundary; i = i + 2) {
      if (isPrime(i, primes)) {
        primes.add(i);
        currentLargestPrimeFactor = i;
        if (n % i == 0) {
          nLargestPrimeFactor = i;
        }
      }
    }
    return nLargestPrimeFactor;

  }

  public static List<Long> primesUpTo(long n) {
    if (n < 2) {
      return Collections.emptyList();
    }
    if (n == 2) {
      return Arrays.asList(2L);
    }
    List<Long> primes = new LinkedList<>(Arrays.asList(2L, 3L));
    for (long i = 5; i <= n; i = i + 2) {
      if (isPrime(i, primes)) {
        primes.add(i);
      }
    }
    return primes;
  }


  public static boolean isPrime(long number, List<Long> primes) {
    long primeBoundary = (long) Math.sqrt(number) + 1L;
    for (long prime : primes) {
      if (number % prime == 0) {
        return false;
      }
      if (prime > primeBoundary) {
        return true;
      }
    }
    return true;
  }


  public static void main(String args[]) {
    for (long prime : primesUpTo(113L)) {
      System.out.print(prime + ",");
    }
    System.out.println();


    System.out.println(largestPrimeFactor(13195));

    System.out.println(largestPrimeFactor(600851475143L));
  }

}

