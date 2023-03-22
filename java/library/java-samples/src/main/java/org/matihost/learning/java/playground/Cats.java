package org.matihost.learning.java.playground;

import java.util.Arrays;

public enum Cats {
  SPHYNX, SIAMESE, BENGAL;

  public static void main(String[] args) {
    Arrays.stream(Cats.values()).forEach(System.out::println);
  }
}
