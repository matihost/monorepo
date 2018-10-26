package org.matihost.algorithms;

import java.util.LinkedList;
import java.util.List;

/**
 * All permutations of the set {1, 2, ..., n}
 */
public class Permutation {

  public static List<int[]> permutation(int n) {
    List<int[]> results = new LinkedList<int[]>();
    generate(0, new int[n], new boolean[n], results, n);
    return results;
  }


  public static void generate(int position, int[] permutation, boolean[] used, List<int[]> results,
      int n) {
    for (int i = 0; i < n; i++) {
      if (!used[i]) {
        used[i] = true;
        permutation[position] = i;
        if (position == n - 1) {
          int[] copy = new int[n];
          System.arraycopy(permutation, 0, copy, 0, n);
          results.add(copy);
        } else {
          generate(position + 1, permutation, used, results, n);
        }
        used[i] = false;
      }
    }
  }


  public static void main(String[] args) {
    List<int[]> permutations = permutation(6);
    for (int[] p : permutations) {
      for (int l : p) {
        System.out.print(l);
      }
      System.out.println();
    }
  }
}
