package org.matihost.algorithms.euler;

import static org.matihost.algorithms.euler.Problem21.*;

/**


 A perfect number is a number for which the sum of its proper divisors is exactly equal to the number.
 For example, the sum of the proper divisors of 28 would be 1 + 2 + 4 + 7 + 14 = 28, which means that 28 is a perfect number.

 A number n is called deficient if the sum of its proper divisors is less than n and it is called abundant if this sum exceeds n.

 As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16, the smallest number that can be written as the sum of two abundant numbers is 24.
 By mathematical analysis, it can be shown that all integers greater than 28123 can be written as the sum of two abundant numbers. However, this upper limit cannot be reduced any further by analysis even though it is known that the greatest number that cannot be expressed as the sum of two abundant numbers is less than this limit.

 Find the sum of all the positive integers which cannot be written as the sum of two abundant numbers.

 */
public class Problem23 {

    private static boolean [] abudantTable(int maxNumber){
        boolean [] abudantTable = new boolean[maxNumber];
        for (int i = 11; i <maxNumber; i++) {
            if (sum(divisors(i+1)) > i + 1){
                abudantTable[i] = true;
            }
        }
        return abudantTable;
    }


    private static boolean [] abudantSums(int maxNumber) {
        boolean [] abudantTable = new boolean[maxNumber];
        boolean [] abudantSums =  new boolean[maxNumber];
        for (int i = 11; i <maxNumber; i++) {
            if (sum(divisors(i+1)) > i + 1){
                abudantTable[i] = true;
            }
            for (int j=i-1;j>0;j--){
                if (abudantTable[j-1] && abudantTable[i-j]){
                    abudantSums[i] = true;
                    break;
                }
            }
        }
        return abudantSums;
    }

    public static void main(String[] args) {
//        boolean[] abudantTable = abudantTable(28123);
//        for (int i = 0; i < abudantTable.length; i++) {
//            System.out.println(i+1 + "->" + abudantTable[i]);
//        }
        boolean[] abudantsSums = abudantSums(28123);
        for (int i = 0; i < abudantsSums.length; i++) {
            System.out.println(i+1 + "->" + abudantsSums[i]);
        }
        int totalSum = 0;
        for (int i = 0; i < abudantsSums.length; i++) {
            if (!abudantsSums[i]){
                totalSum += i+1;
            }
        }
        System.out.println(totalSum);
    }
}
