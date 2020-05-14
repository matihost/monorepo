package org.matihost.algorithms.euler;

import java.math.BigInteger;
import java.util.concurrent.atomic.AtomicLong;

/**

 Starting in the top left corner of a 2*2 grid, and only being able to move to the right and down, there are exactly 6 routes to the bottom right corner.

 How many such routes are there through a 20*20 grid?

 */
public class Problem15 {


    public static long downLeftPaths(int n){
        n++;
        int max = n * n;
        int permutationMaxLength = 2 * n - 1;
        AtomicLong count = new AtomicLong(0L);
        boolean usage[] = new boolean[max];
        int[] permutation = new int[permutationMaxLength];

        generatePosition(0, count, usage, permutation, max, permutationMaxLength, n);

        return count.longValue();
    }

    private static void generatePosition(int currentPosition, AtomicLong count, boolean[] usage, int[] permutation, int max, int permutationMaxLength, int n) {
        if (currentPosition == 0){
            permutation[currentPosition] = 0;
            usage[0] = true;
            generatePosition(currentPosition + 1, count, usage, permutation, max, permutationMaxLength, n);
            usage[0] = false;
        } else if (currentPosition < permutationMaxLength -1){
            int prevValue = permutation[currentPosition-1];
            int currValue = prevValue + 1;
            if (currValue <= max - 1 && !usage[currValue] && prevValue % n != n - 1){
                usage[currValue] = true;
                permutation[currentPosition] = currValue;
                generatePosition(currentPosition + 1, count, usage, permutation, max, permutationMaxLength, n);
                usage[currValue] = false;
            }
            currValue = prevValue + n;
            if (currValue <= max - 1 && !usage[currValue]){
                usage[currValue] = true;
                permutation[currentPosition] = currValue;
                generatePosition(currentPosition + 1, count, usage, permutation, max, permutationMaxLength,n);
                usage[currValue] = false;
            }
        }  else {//currentPosition == permutationMaxLength - 1

//            permutation[currentPosition] = max - 1;
            count.incrementAndGet();
//            for (int i=0;i<permutationMaxLength;i++)
//            System.out.print(permutation[i] +",");
//            System.out.println();
//            permutation[currentPosition] = 0;
        }


    }


    public static void main(String [] args){
        System.out.println(downLeftPaths(6));
        // it is Pascal triangle where (2n n )
        BigInteger result = BigInteger.ONE;
        for (int i=20;i>0;i--) {
            result = result.multiply(BigInteger.valueOf(20L + i));
        }
        for (int i=20;i>0;i--) {
            result = result.divide(BigInteger.valueOf(i));
        }
        System.out.println(result);
    }

}
