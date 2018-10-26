package org.matihost.algorithms.euler;

/**
 * If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9.
 * The sum of these multiples is 23.
 * <p>
 * Find the sum of all the multiples of 3 or 5 below 1000.
 */
public class Problem1 {

  public static int multiples(int num1, int num2, int maxMultiple) {
    int sum = 0;
    int i = 1;
    int currentMultiple;

    do {
      int currentMultiple1 = num1 * i;
      if (currentMultiple1 < maxMultiple && i % num2 != 0) {
        sum += currentMultiple1;
      }
      int currentMultiple2 = num2 * i;
      if (currentMultiple2 < maxMultiple) {
        sum += currentMultiple2;
      }
      currentMultiple = Math.min(currentMultiple1, currentMultiple2);
      i++;
    } while (currentMultiple < maxMultiple);
    return sum;
  }


  public static void main(String[] args) {
    System.out.println(multiples(3, 5, 1000));
  }
}
