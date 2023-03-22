package org.matihost.learning.java.playground;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class PlayGround {

  private record Employee(String name) {}

  private static int totalImperative(List<Integer> numbers){
    int total = 0;
    for (Integer x: numbers){
      if (x % 2 == 0){
        total += x * x;
      }
    }
    return total;
  }

  private static int totalDeclarative(List<Integer> numbers){
    return numbers.stream()
      .filter(x -> x % 2 == 0)
      .mapToInt(x -> x * x)
      .sum();
  }
  public static void main(String[] args) {
    var i = 1;
    switch (i) {
      case 0:
        System.out.println("0");
        break;
      case 1:
        System.out.println("1");
      case 2:
        System.out.println("2");
      default:
        System.out.println("d");
    }

    List<Integer> numbers = List.of(1,2,3,4);
    assert totalImperative(numbers) == totalDeclarative(numbers);

    List<Employee> employees = List.of(new Employee("John"), new Employee("Mat"));

    List<String> names = employees.stream().map(Employee::name).collect(Collectors.toList());
    assert names.size() == 2;
    print(names);
    names = names.stream().sorted(Comparator.reverseOrder()).toList();
    print(names);
    weirdPrint();
  }

  private static void print(List<?> list){
    list.stream().forEach(System.out::print);
  }

  private static void weirdPrint(){
    for (int i=0; i<10; i=i++){
      i+=1;
      System.out.println("Hello World!");
    }
  }

}
