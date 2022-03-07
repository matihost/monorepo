package org.matihost.learning.mq.utils;

import org.springframework.boot.ApplicationArguments;

import java.util.List;

import static java.util.Optional.ofNullable;

public class CmdLineUtils {

  public static String getArg(ApplicationArguments appArgs, String argName, String defaultValue) {
    return ofNullable(appArgs.getOptionValues(argName))
      .orElse(List.of()).stream()
      .findFirst()
      .orElse(defaultValue);
  }

  public static void blockCurrentThread(){
    try {
      Thread.currentThread().join();
    } catch (InterruptedException e) {
      // ignore
    }
  }
}
