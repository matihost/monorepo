package org.matihost.algorithms.euler;

import java.math.BigInteger;

/**
 * 
 * 
 * 
 * 2^15 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.
 * 
 * What is the sum of the digits of the number 2^1000?
 * 
 */
public class Problem16 {


  public static void main(String[] args) {
    BigInteger result = basePower(2L, 1000);

    long sum = digitsSum(result);

    System.out.println(result.toString());
    System.out.println(sum);
  }

  public static long digitsSum(BigInteger value) {
    long sum = 0;
    String resultStr = value.toString();
    int length = resultStr.length();
    for (int i = 0; i < length; i++) {
      sum += Character.digit(resultStr.charAt(i), 10);
    }
    return sum;
  }

  /*
   * base^power, for example 2^1000 is when base is 2 and power is 1000
   */
  public static BigInteger basePower(long base, int power) {
    BigInteger result = BigInteger.ONE;
    for (int i = 1; i <= power; i++) {
      result = result.multiply(BigInteger.valueOf(base));
    }
    return result;
  }

}

