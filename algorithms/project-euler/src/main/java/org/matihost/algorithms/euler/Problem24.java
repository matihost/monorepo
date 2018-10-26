package org.matihost.algorithms.euler;

/**


 A permutation is an ordered arrangement of objects. For example, 3124 is one possible permutation of the digits 1, 2, 3 and 4. If all of the permutations are listed numerically or alphabetically, we call it lexicographic order. The lexicographic permutations of 0, 1 and 2 are:

 012   021   102   120   201   210

 What is the millionth lexicographic permutation of the digits 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9?

 */
public class Problem24 {

    interface PermutationAction {
        void doSthWithPermutation(int [] permutation);
    }

    public static void permutations(PermutationAction action, int ... elements){
        int length = elements.length;
        int [] permutation = new int[length];
        boolean [] used = new boolean[length];
        generate(0, elements, permutation, used, action);
    }

    private static void generate(int position, int[] elements, int[] permutation, boolean[] used, PermutationAction action) {
        if (position == elements.length){
          action.doSthWithPermutation(permutation);
        } else {
            for (int i = 0; i < elements.length; i++) {
                if (!used[i]) {
                    used[i] = true;
                    permutation[position] = elements[i];
                    generate(position + 1, elements, permutation, used, action);
                    used[i] = false;
                }
            }
        }
    }


    public static void main(String[] args) {
        permutations(permutation -> {
            for (int v : permutation) {
                System.out.print(v);
            }
            System.out.println();
        }, 0,1,2);
        permutations(new PermutationAction() {
            int count = 0;
            @Override
            public void doSthWithPermutation(int[] permutation) {
                count++;
                if (count == 1_000_000) {
                    for (int v : permutation) {
                        System.out.print(v);
                    }
                    System.out.println();
                    System.exit(0);
                }
            }
        }, 0,1,2,3,4,5,6,7,8,9);
    }
}
