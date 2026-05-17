package org.matihost.learning.java.playground;

import org.assertj.core.api.Assertions;

import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;

public class Testing {


  public static void main(String[] args) {
    // given
    String value = "doupa";
    // when
    String reversed = reverse(value);
    // then
    assertThat(reversed).isEqualTo("apuod");

    // given
    int[] input = {2, 7, 11, 15, 8 ,8};
    // when
    int[] twoSumResult = twoSum(16, input);
    //then
    assertThat(twoSumResult).containsExactly(4, 5);

    //given
    String str =  "pwwkew";

    //when
    String sub = longestUniqueSubstring(str);

    //then
    Assertions.assertThat(sub).isEqualTo("wke");


    iterate(new ArrayList<>(Arrays.asList("ala", "has", "a", "cat")));
    for (String arg : args){
      Arrays.sort(args);
      System.out.println(arg);
    }
  }

  private static void iterate(List<String> strs) {
    Collections.sort(strs);
    for (Iterator<String> it = strs.iterator(); it.hasNext();){
      System.out.println(it.next());
    }
    for (String str : strs){
      System.out.println(str);
    }
  }

  private static String reverse(String value) {
    char[] valueChars = value.toCharArray();
    int length = valueChars.length;
    for (int i = 0; i < length / 2; i++) {
      char c = valueChars[i];
      valueChars[i] = valueChars[length - i - 1];
      valueChars[length - i - 1] = c;
    }
    return new String(valueChars);
  }


  private static int[] twoSum(int target, int[] input) {
    Map<Integer, Integer> saw = new HashMap<>(); // number, index
    for (int i = 0; i < input.length; i++) {

      int search = target - input[i];
      Integer searchIndex = saw.get(search);

      if (searchIndex != null) {
        return new int[]{searchIndex, i};
      }
      saw.put(input[i], i);
    }
    return null;
  }

  private static String longestUniqueSubstring(String input){
    char[] inputChars = input.toCharArray();
    int left = 0;
    String currentSubstring = "";
    HashMap<Character, Integer> currentPosition = new HashMap<>(); // char, position
    for (int i = 0; i < input.length(); i++) {
      if (currentPosition.containsKey(inputChars[i])){
        int newleft = currentPosition.get(inputChars[i]) + 1;
        for (int j=left;j<newleft;j++){
          currentPosition.remove(inputChars[j]);
        }
        left = newleft;
      }
      currentPosition.put(inputChars[i], i);
      String sub =  input.substring(left, i+1);
      if (currentSubstring.length() < sub.length()){
        currentSubstring = sub;
      }
    }
    return currentSubstring;
  }


  private static void util(){

  }
}
