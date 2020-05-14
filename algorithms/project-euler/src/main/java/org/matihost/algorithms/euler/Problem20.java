package org.matihost.algorithms.euler;

import java.math.BigInteger;

/**
 Factorial digit sum

 n! means n * (n - 1) * ... * 3 * 2 * 1

 For example, 10! = 10 * 9 * ... * 3 * 2 * 1 = 3628800,
 and the sum of the digits in the number 10! is 3 + 6 + 2 + 8 + 8 + 0 + 0 = 27.

 Find the sum of the digits in the number 100!

 */
public class Problem20 {

    /*
 base^power, for example 2^1000 is when base is 2 and power is 1000
 */
    public static BigInteger factorial(long n) {
        BigInteger result = BigInteger.ONE;
        for (long i=1;i<= n;i++) {
            result = result.multiply(BigInteger.valueOf(i));
        }
        return result;
    }

    public static void main(String [] args){
        BigInteger result = factorial(100L);

        long sum = Problem16.digitsSum(result);

        System.out.println(result.toString());
        System.out.println(sum);
    }

}
