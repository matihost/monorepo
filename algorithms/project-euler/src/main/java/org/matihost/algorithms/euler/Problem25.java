package org.matihost.algorithms.euler;

import java.math.BigInteger;

/**


 The Fibonacci sequence is defined by the recurrence relation:

 Fn = Fn−1 + Fn−2, where F1 = 1 and F2 = 1.

 Hence the first 12 terms will be:

 F1 = 1
 F2 = 1
 F3 = 2
 F4 = 3
 F5 = 5
 F6 = 8
 F7 = 13
 F8 = 21
 F9 = 34
 F10 = 55
 F11 = 89
 F12 = 144

 The 12th term, F12, is the first term to contain three digits.

 What is the first term in the Fibonacci sequence to contain 1000 digits?

 */
public class Problem25 {

    public static int fibLimit(int digits){
        BigInteger p2 = BigInteger.ONE;
        BigInteger p1 = BigInteger.ONE;
        BigInteger result = BigInteger.ZERO;
        int i=2;
        for (;result.toString().length()<digits;i++){
            result = p1.add(p2);
            p2 = p1;
            p1 = result;
        }
        return i;

    }

    public static void main(String[] args) {
        System.out.println(fibLimit(1_000));
    }
}
