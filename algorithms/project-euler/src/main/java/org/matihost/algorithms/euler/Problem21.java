package org.matihost.algorithms.euler;

import java.util.*;

/**
 Let d(n) be defined as the sum of proper divisors of n (numbers less than n which divide evenly into n).
 If d(a) = b and d(b) = a, where a != b, then a and b are an amicable pair and each of a and b are called amicable numbers.

 For example, the proper divisors of 220 are 1, 2, 4, 5, 10, 11, 20, 22, 44, 55 and 110; therefore d(220) = 284.
 The proper divisors of 284 are 1, 2, 4, 71 and 142; so d(284) = 220.

 Evaluate the sum of all the amicable numbers under 10000.

 */
public class Problem21 {

    public static Integer [] divisors(int n){
        // brute version, reevaluate problem 12 to have better version
        LinkedList<Integer> results = new LinkedList<>(Collections.singletonList(1));
        for (int i=2;i<=n/2;i++){
            if (n % i ==0){
                results.add(i);
            }
        }
        return results.toArray(new Integer[results.size()]);
    }

    public static Integer [] amicableNumbersUpTo(int n) {
        Set<Integer> amicableNumbers = new HashSet<>();
        Map<Integer,Long> divisorsSumCache = new HashMap<>();
        for (int i=2;i<n;i++){
            Long divisorsSum = getDivisorsSum(divisorsSumCache, i);
            if (divisorsSum < n){
                Long divisorsSum2 = getDivisorsSum(divisorsSumCache, divisorsSum.intValue());
                if (divisorsSum2.intValue() == i && i != divisorsSum.intValue()) {
                    amicableNumbers.add(i);
                    amicableNumbers.add(divisorsSum.intValue());
                }
            }


        }
        return amicableNumbers.toArray(new Integer[amicableNumbers.size()]);
    }

    private static Long getDivisorsSum(Map<Integer, Long> divisorsSumCache, int i) {
        Long divisorsSum = divisorsSumCache.get(i);
        if (divisorsSum == null){
            divisorsSum = sum(divisors(i));
            divisorsSumCache.put(i,divisorsSum);
        }
        return divisorsSum;
    }


    public static long sum(Integer [] numbers){
        long sum = 0;
        for (int number : numbers){
            sum+=number;
       }
       return sum;
    }
    public static void main(String [] args){
        System.out.println(sum(divisors(220)));
        System.out.println(sum(divisors(284)));
        System.out.println(sum(amicableNumbersUpTo(10_000)));
    }
}
