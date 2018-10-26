package org.matihost.algorithms.euler;

/**
 * 
 * The sum of the squares of the first ten natural numbers is, 1_2 + 2_2 + ... + 10_2 = 385
 * 
 * The square of the sum of the first ten natural numbers is, (1 + 2 + ... + 10)_2 = 55_2 = 3025
 * 
 * Hence the difference between the sum of the squares of the first ten natural numbers and the
 * square of the sum is 3025 − 385 = 2640.
 * 
 * Find the difference between the sum of the squares of the first one hundred natural numbers and
 * the square of the sum.
 * 
 */
public class Problem6 {

  public static long bruteDifference(int maxNumber) {
    int sum = 0;
    int sqSum = 0;
    for (int i = 1; i <= maxNumber; i++) {
      sum += i;
      sqSum += i * i;
    }
    sum *= sum;
    return sum - sqSum;
  }

  public static void main(String args[]) {
    System.out.println(bruteDifference(100));
  }
}
