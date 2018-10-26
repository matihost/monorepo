package org.matihost.algorithms.euler;

/**
 * A palindromic number reads the same both ways. The largest palindrome made from the product of
 * two 2-digit numbers is 9009 = 91 × 99. Find the largest palindrome made from the product of two
 * 3-digit numbers.
 */
public class Problem4 {


  public static boolean isPalindrome(String input) {
    if (input == null || input.isEmpty())
      return true;
    int halfLength = input.length() / 2;
    for (int i = 0; i < halfLength; i++) {
      if (input.charAt(i) != input.charAt(input.length() - 1 - i))
        return false;
    }
    return true;
  }

  public static int largestPalindromeProduct(int limit) {
    int result = 0;
    for (int i = 100; i < limit; i++)
      for (int j = 100; j < limit; j++) {
        int product = i * j;
        if (isPalindrome(Integer.toString(product)) && product > result) {
          result = product;
        }
      }
    return result;
  }



  public static void main(String[] args) {
    String[] samples = {"", "ala", "abba", "9009", "no"};
    for (String sample : samples) {
      System.out.println(sample + " : " + isPalindrome(sample));
    }
    System.out.println(largestPalindromeProduct(999));
  }
}
