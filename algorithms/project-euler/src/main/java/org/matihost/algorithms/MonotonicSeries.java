package org.matihost.algorithms;

import java.util.LinkedList;

/**
 * Podaj algorytm znajdujacy najdluzszy monotonicznie rosnacy podciag nadego ciagu n liczb
 */
public class MonotonicSeries {

  private static class Result {
    int maxLength;
    int currentMaxValue;
    Result predecessor;
  }

  private static Integer[] longestMonotonicSeries(int... values) {
    int n = values.length;
    Result[][] r = new Result[n][n];
    Result result = null;
    for (int i = 0; i < n; i++) {
      result = longestSeries(0, i, r, values);
    }
    LinkedList<Integer> resultTable = new LinkedList<>();
    while (result != null) {

      if (result.predecessor == null || result.predecessor.maxLength != result.maxLength) {
        resultTable.add(0, result.currentMaxValue);
      }
      result = result.predecessor;
    }
    return resultTable.toArray(new Integer[resultTable.size()]);
  }

  private static Result longestSeries(int i, int j, Result[][] r, int[] values) {
    if (r[i][j] != null) {
      return r[i][j];
    }
    Result result = new Result();
    if (i == j) {
      result.maxLength = 1;
      result.currentMaxValue = values[j];
    } else {
      int k = j - 1;
      do {
        Result predecessor = longestSeries(i, k, r, values);
        if (result.predecessor == null || (predecessor.maxLength > result.maxLength)
            || (predecessor.maxLength == result.maxLength
                && predecessor.currentMaxValue < result.currentMaxValue)
            || (predecessor.currentMaxValue < values[j]
                && predecessor.maxLength + 1 == result.maxLength)) {
          result.maxLength = predecessor.maxLength;
          result.currentMaxValue = predecessor.currentMaxValue;
          result.predecessor = predecessor;
          if (predecessor.currentMaxValue <= values[j]) {
            result.currentMaxValue = values[j];
            result.maxLength = result.maxLength + 1;
          }
        }
        k--;
      } while (k >= i);
      k = i + 1;

      while (k <= j) {
        Result predecessor = longestSeries(k, j, r, values);
        if (predecessor.maxLength > result.maxLength || (predecessor.maxLength == result.maxLength
            && predecessor.currentMaxValue < result.currentMaxValue)) {
          result.maxLength = predecessor.maxLength;
          result.currentMaxValue = predecessor.currentMaxValue;
          result.predecessor = predecessor;
        }
        k++;
      }
    }
    return r[i][j] = result;

  }


  public static void main(String[] args) {
    printTable(longestMonotonicSeries(4, 5, 10, 7, 7, 8, 2, 4, 3, 4, 2, 5, 3, 5, 4, 2, 4, 6));
    printTable(longestMonotonicSeries(2, 3, 8, 2, 5, 6));
  }

  private static void printTable(Integer[] monotonic) {
    System.out.print(monotonic.length + "->");
    for (int v : monotonic) {
      System.out.print(v + ",");
    }
    System.out.println();
  }
}
