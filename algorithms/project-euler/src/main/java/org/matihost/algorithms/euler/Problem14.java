package org.matihost.algorithms.euler;

/**

 The following iterative sequence is defined for the set of positive integers:

 n → n/2 (n is even)
 n → 3n + 1 (n is odd)

 Using the rule above and starting with 13, we generate the following sequence:
 13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1

 It can be seen that this sequence (starting at 13 and finishing at 1) contains 10 terms. Although it has not been proved yet (Collatz Problem), it is thought that all starting numbers finish at 1.

 Which starting number, under one million, produces the longest chain?

 NOTE: Once the chain starts the terms are allowed to go above one million.

 */
public class Problem14 {


    public static long collatzChainLength(long startNumber){
        long currentNumber = startNumber;
        long chainLength = 1;
        while (currentNumber != 1L){
            currentNumber = nextCollatzNumber(currentNumber);
            chainLength++;
        }
        return chainLength;
    }

    private static long nextCollatzNumber(long n){
        if (n % 2L == 0){
            return n /2L;
        } else {
            return 3L * n + 1L;
        }
    }


    public static long maxCollatzChainIndex(long maxIndex){
        long longestChainIndex = maxIndex;
        long longestChain = 0;

        for (long i=maxIndex;i>1;i--){
            long currentChainLentgh = collatzChainLength(i);
            if (currentChainLentgh > longestChain){
                longestChain = currentChainLentgh;
                longestChainIndex = i;
            }
        }

        return longestChainIndex;
    }


    public static void main(String [] args){
        System.out.println(collatzChainLength(999999L));

        System.out.println(maxCollatzChainIndex(1_000_000L));
    }

}

