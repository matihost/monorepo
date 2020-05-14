package org.matihost.algorithms;

import java.util.Arrays;

/**
 * For table of integers like [ 3, 9, 6, 0, 1, 2, 5]
 *
 * Order them following the below rule:
 *
 * a1 >= a2 <= a3 >= a4 ...
 */
public class SwappingOrder {

  public static int[] swappingOrder(int[] a) {
    Arrays.sort(a);
    int[] result = new int[a.length];
    for (int i = 0, j = 0; i < a.length / 2; i++) {
      result[j++] = a[a.length - 1 - i];
      result[j++] = a[i];
    }
    if (a.length % 2 == 1) {
      result[a.length - 1] = a[a.length / 2];
    }
    return result;
  }

  public static void main(String args[]) {
    // given
    int[] sample = {3, 9, 6, 0, 1, 2, 5};

    // when
    int[] result = swappingOrder(sample);

    // then
    for (int v : result) {
      System.out.print(v + ", ");
    }
    System.out.println(); // 9, 0, 6, 1, 5, 2, 3,
  }
}
