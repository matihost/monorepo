package org.matihost.algorithms.euler;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * 
 * By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see that the 6th prime is
 * 13.
 * 
 * What is the 10 001st prime number?
 * 
 * 
 * Some useful facts: 1 is not a prime. All primes except 2 are odd. All primes greater than 3 can
 * be written in the form 6k+/-1. Any number n can have only one primefactor greater than n . The
 * consequence for primality testing of a number n is: if we cannot find a number f less than or
 * equal n that divides n then n is prime: the only primefactor of n is n itself Let’s design an
 * algorithm that tests the primality of a number n based on these facts:
Function isPrime(n)
 if n=1 then return false
 else
 if n<4 then return true //2 and 3 are prime
 else
 if n mod 2=0 then return false
 else
 if n<9 then return true //we have already excluded 4,6 and 8.
 else
 if n mod 3=0 then return false
 else
 r=floor( n ) // n rounded to the greatest integer r so that r*r<=n
 f=5
 while f<=r
 if n mod f=0 then return false (and step out of the function)
 if n mod(f+2)=0 then return false (and step out of the function)
 f=f+6
 endwhile
 return true (in all other cases)
 End Function

 */
public class Problem7 {
  public static long getNthPrime(int n) {
    if (n < 1) {
      return 1;
    }
    List<Long> primes = new LinkedList<>(Arrays.asList(2L));
    for (long i = 2; primes.size() < n; i++) {
      if (isPrime(i, primes)) {
        primes.add(i);
      }
    }
    return primes.get(n - 1);
  }


  private static boolean isPrime(long number, List<Long> primes) {
    for (long prime : primes) {
      if (number % prime == 0) {
        return false;
      }
    }
    return true;
  }


  public static void main(String args[]) {

    System.out.println(getNthPrime(10_001));

  }

}
